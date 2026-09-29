#include "select_pak.h"
#include <android/log.h>
#include <fstream>
#include <cstring>
#include "stb_image.h"

#define LOG_TAG "SelectPak"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

#pragma pack(push, 1)
struct SelectHeader {
    char magic[4];
    uint32_t version;
    uint32_t screenWidth;
    uint32_t screenHeight;
    uint32_t numEntries;
    uint32_t reserved;
};

struct SelectEntryRaw {
    uint32_t id;
    float posX;
    float posY;
    float dstW;
    float dstH;
    uint32_t offset;
    uint32_t length;
    uint32_t reserved;
};
#pragma pack(pop)

SelectPak::SelectPak()
    : m_screenWidth(1280)
    , m_screenHeight(720)
{}

SelectPak::~SelectPak() {
    release();
}

bool SelectPak::load(const std::string& path, AAssetManager* assetMgr) {
    release();

    bool readSuccess = false;

    if (assetMgr) {
        std::vector<std::string> tryPaths = {path};
        if (path.rfind("assets/", 0) == 0) {
            tryPaths.push_back(path.substr(7));
        } else {
            tryPaths.push_back("assets/" + path);
        }

        for (const auto& p : tryPaths) {
            AAsset* asset = AAssetManager_open(assetMgr, p.c_str(), AASSET_MODE_BUFFER);
            if (asset) {
                off_t length = AAsset_getLength(asset);
                m_fileBuffer.resize(length);
                AAsset_read(asset, m_fileBuffer.data(), length);
                AAsset_close(asset);
                readSuccess = true;
                LOGI("Loaded select.pak from APK asset: %s (%zu bytes)", p.c_str(), m_fileBuffer.size());
                break;
            }
        }
    }

    if (!readSuccess) {
        std::ifstream file(path, std::ios::binary | std::ios::ate);
        if (!file.is_open()) {
            std::string sdPath = "/sdcard/MiokoTech/STARBLAST/" + path;
            file.open(sdPath, std::ios::binary | std::ios::ate);
        }
        if (file.is_open()) {
            std::streamsize size = file.tellg();
            file.seekg(0, std::ios::beg);
            m_fileBuffer.resize(size);
            if (file.read(reinterpret_cast<char*>(m_fileBuffer.data()), size)) {
                readSuccess = true;
            }
        }
    }

    if (!readSuccess || m_fileBuffer.size() < sizeof(SelectHeader)) {
        LOGE("Failed to load select.pak: %s", path.c_str());
        return false;
    }

    const uint8_t* ptr = m_fileBuffer.data();
    const auto* header = reinterpret_cast<const SelectHeader*>(ptr);

    if (std::memcmp(header->magic, "SEL1", 4) != 0) {
        LOGE("Invalid select.pak magic header");
        return false;
    }

    m_screenWidth = header->screenWidth;
    m_screenHeight = header->screenHeight;
    uint32_t numEntries = header->numEntries;

    ptr += sizeof(SelectHeader);

    m_entries.resize(numEntries);
    for (uint32_t i = 0; i < numEntries; ++i) {
        const auto* raw = reinterpret_cast<const SelectEntryRaw*>(ptr);
        ptr += sizeof(SelectEntryRaw);

        SelectEntry entry;
        entry.id = raw->id;
        entry.posX = raw->posX;
        entry.posY = raw->posY;
        entry.dstW = raw->dstW;
        entry.dstH = raw->dstH;
        entry.offset = raw->offset;
        entry.length = raw->length;
        entry.srcW = 0;
        entry.srcH = 0;
        entry.textureId = 0;

        m_entries[i] = entry;
    }

    LOGI("select.pak parsed: %dx%d, %u entries", m_screenWidth, m_screenHeight, numEntries);
    return true;
}

void SelectPak::release() {
    for (auto& entry : m_entries) {
        if (entry.textureId != 0) {
            glDeleteTextures(1, &entry.textureId);
            entry.textureId = 0;
        }
    }
    m_entries.clear();
    m_fileBuffer.clear();
}

GLuint SelectPak::loadTextureFromMemory(const uint8_t* data, size_t length, int* outW, int* outH) {
    int w = 0, h = 0, channels = 0;
    stbi_set_flip_vertically_on_load(0);
    unsigned char* decoded = stbi_load_from_memory(data, static_cast<int>(length), &w, &h, &channels, 4);
    if (!decoded) {
        LOGE("Failed to decode image in select.pak: %s", stbi_failure_reason());
        return 0;
    }

    GLuint texId = 0;
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, decoded);
    glBindTexture(GL_TEXTURE_2D, 0);

    stbi_image_free(decoded);

    if (outW) *outW = w;
    if (outH) *outH = h;
    return texId;
}

const SelectEntry* SelectPak::getEntry(int id) const {
    if (id < 0 || id >= static_cast<int>(m_entries.size())) {
        return nullptr;
    }
    return &m_entries[id];
}

GLuint SelectPak::getTexture(int id) {
    if (id < 0 || id >= static_cast<int>(m_entries.size())) {
        return 0;
    }

    auto& entry = m_entries[id];
    if (entry.textureId == 0) {
        if (entry.offset + entry.length <= m_fileBuffer.size()) {
            entry.textureId = loadTextureFromMemory(
                m_fileBuffer.data() + entry.offset,
                entry.length,
                &entry.srcW,
                &entry.srcH
            );
        }
    }

    return entry.textureId;
}

}
