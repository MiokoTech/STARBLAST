// Dekompresi dan reader data sprite atlas SBS.
#include "sbs_reader.h"
#include "texture_manager.h"
#include "stb_image.h"
#include <android/log.h>
#include <zlib.h>
#include <fstream>
#include <cstring>
#include <vector>

#define LOG_TAG "SbsReader"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

SbsReader::SbsReader() {
    std::memset(&header_, 0, sizeof(header_));
}

SbsReader::~SbsReader() {
    unload();
}

void SbsReader::unload() {
    for (GLuint texId : texture_ids_) {
        if (texId != 0) {
            glDeleteTextures(1, &texId);
        }
    }
    texture_ids_.clear();
    sheets_.clear();
    entries_.clear();
    sprite_map_.clear();
    std::memset(&header_, 0, sizeof(header_));
}

bool SbsReader::load(const std::string& filepath, AAssetManager* assetMgr) {
    unload();

    if (!assetMgr) {
        assetMgr = TextureManager::getInstance().getAssetManager();
    }

    std::vector<uint8_t> buffer;
    bool readSuccess = false;

    if (assetMgr) {
        std::vector<std::string> tryPaths = {filepath};
        if (filepath.rfind("assets/", 0) == 0) {
            tryPaths.push_back(filepath.substr(7));
        } else {
            tryPaths.push_back("assets/" + filepath);
        }

        for (const auto& p : tryPaths) {
            AAsset* asset = AAssetManager_open(assetMgr, p.c_str(), AASSET_MODE_BUFFER);
            if (asset) {
                off_t length = AAsset_getLength(asset);
                buffer.resize(length);
                AAsset_read(asset, buffer.data(), length);
                AAsset_close(asset);
                readSuccess = true;
                break;
            }
        }
    }

    if (!readSuccess) {
        std::ifstream file(filepath, std::ios::binary | std::ios::ate);
        if (!file.is_open()) {
            std::string sdPath = "/sdcard/MiokoTech/STARBLAST/" + filepath;
            file.open(sdPath, std::ios::binary | std::ios::ate);
        }
        if (file.is_open()) {
            std::streamsize size = file.tellg();
            file.seekg(0, std::ios::beg);
            buffer.resize(size);
            if (file.read(reinterpret_cast<char*>(buffer.data()), size)) {
                readSuccess = true;
            }
        }
    }

    if (!readSuccess || buffer.size() < sizeof(SbsHeaderRaw)) {
        LOGE("Gagal membaca file SBS: %s", filepath.c_str());
        return false;
    }

    std::memcpy(&header_, buffer.data(), sizeof(SbsHeaderRaw));
    if (std::memcmp(header_.magic, "SBS1", 4) != 0) {
        LOGE("Magic SBS tidak valid: %s", filepath.c_str());
        return false;
    }

    size_t spriteTableEnd = header_.sprite_table_offset + static_cast<size_t>(header_.total_sprites) * sizeof(SbsSpriteEntryRaw);
    if (spriteTableEnd > buffer.size()) {
        LOGE("Tabel sprite melebihi ukuran file: %s", filepath.c_str());
        return false;
    }

    entries_.resize(header_.total_sprites);
    std::memcpy(entries_.data(), buffer.data() + header_.sprite_table_offset, header_.total_sprites * sizeof(SbsSpriteEntryRaw));

    sprite_map_.clear();
    sprite_map_.reserve(header_.total_sprites);
    for (size_t i = 0; i < entries_.size(); ++i) {
        const auto& entry = entries_[i];
        uint64_t key = (static_cast<uint64_t>(entry.group) << 32) | static_cast<uint32_t>(entry.number);
        sprite_map_[key] = i;
    }

    if (header_.atlas_table_offset > buffer.size()) {
        LOGE("Offset atlas table di luar ukuran buffer: %s", filepath.c_str());
        return false;
    }

    sheets_.clear();
    sheets_.reserve(header_.total_sheets);
    texture_ids_.clear();
    texture_ids_.reserve(header_.total_sheets);

    size_t curOffset = header_.atlas_table_offset;
    for (uint16_t i = 0; i < header_.total_sheets; ++i) {
        if (curOffset + 8 > buffer.size()) {
            break;
        }

        uint16_t w = 0, h = 0;
        uint32_t data_size = 0;
        std::memcpy(&w, buffer.data() + curOffset, 2);
        std::memcpy(&h, buffer.data() + curOffset + 2, 2);
        std::memcpy(&data_size, buffer.data() + curOffset + 4, 4);
        curOffset += 8;

        if (curOffset + data_size > buffer.size()) {
            break;
        }

        const uint8_t* sheetBytes = buffer.data() + curOffset;
        curOffset += data_size;

        GLuint texId = 0;
        if (header_.atlas_format == 1) {
            int imgW = 0, imgH = 0, comp = 0;
            unsigned char* pixels = stbi_load_from_memory(sheetBytes, static_cast<int>(data_size), &imgW, &imgH, &comp, 4);
            if (pixels) {
                glGenTextures(1, &texId);
                glBindTexture(GL_TEXTURE_2D, texId);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, imgW, imgH, 0, GL_RGBA, GL_UNSIGNED_BYTE, pixels);
                glBindTexture(GL_TEXTURE_2D, 0);
                stbi_image_free(pixels);
            }
        } else if (header_.atlas_format == 2) {
            uLongf destLen = static_cast<uLongf>(w) * h * 4;
            std::vector<uint8_t> rawPixels(destLen);
            int zres = uncompress(rawPixels.data(), &destLen, sheetBytes, data_size);
            if (zres == Z_OK) {
                glGenTextures(1, &texId);
                glBindTexture(GL_TEXTURE_2D, texId);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
                glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
                glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, rawPixels.data());
                glBindTexture(GL_TEXTURE_2D, 0);
            }
        }

        SbsSheetInfo sheet;
        sheet.width = w;
        sheet.height = h;
        sheet.data_offset = static_cast<uint32_t>(curOffset - data_size);
        sheet.data_size = data_size;
        sheet.texture_id = texId;
        sheets_.push_back(sheet);
        texture_ids_.push_back(texId);
    }

    LOGI("Berhasil memuat SBS: %s (%u sprite, %u sheet)", filepath.c_str(), header_.total_sprites, header_.total_sheets);
    return true;
}

const SbsSpriteEntryRaw* SbsReader::getSprite(int32_t group, int32_t number) const {
    uint64_t key = (static_cast<uint64_t>(group) << 32) | static_cast<uint32_t>(number);
    auto it = sprite_map_.find(key);
    if (it != sprite_map_.end()) {
        return &entries_[it->second];
    }
    return nullptr;
}

GLuint SbsReader::getSheetTexture(uint16_t sheet_id) const {
    if (sheet_id < sheets_.size()) {
        return sheets_[sheet_id].texture_id;
    }
    return 0;
}

const SbsSheetInfo* SbsReader::getSheetInfo(uint16_t sheet_id) const {
    if (sheet_id < sheets_.size()) {
        return &sheets_[sheet_id];
    }
    return nullptr;
}

}
