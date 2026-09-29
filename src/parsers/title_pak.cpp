#include "title_pak.h"
#include <android/log.h>
#include <fstream>
#include <cstring>
#include "stb_image.h"

#define LOG_TAG "TitlePak"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

#pragma pack(push, 1)
struct TitleHeader {
    char magic[4];
    uint32_t version;
    uint32_t screenWidth;
    uint32_t screenHeight;
    uint32_t numLayers;
    uint32_t reserved;
};

struct TitleLayerRaw {
    uint32_t layerId;
    float posX;
    float posY;
    float dstW;
    float dstH;
    uint32_t offset;
    uint32_t length;
    uint32_t reserved;
};
#pragma pack(pop)

TitlePak::TitlePak()
    : m_screenWidth(1280)
    , m_screenHeight(720)
{}

TitlePak::~TitlePak() {
    release();
}

bool TitlePak::load(const std::string& path, AAssetManager* assetMgr) {
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
                LOGI("Loaded title.pak from APK asset: %s (%zu bytes)", p.c_str(), m_fileBuffer.size());
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

    if (!readSuccess || m_fileBuffer.size() < sizeof(TitleHeader)) {
        LOGE("Failed to load title.pak: %s", path.c_str());
        return false;
    }

    const uint8_t* ptr = m_fileBuffer.data();
    const auto* header = reinterpret_cast<const TitleHeader*>(ptr);

    if (std::memcmp(header->magic, "TIT1", 4) != 0) {
        LOGE("Invalid title.pak magic header");
        return false;
    }

    m_screenWidth = header->screenWidth;
    m_screenHeight = header->screenHeight;
    uint32_t numLayers = header->numLayers;

    ptr += sizeof(TitleHeader);

    m_layers.resize(numLayers);
    for (uint32_t i = 0; i < numLayers; ++i) {
        const auto* raw = reinterpret_cast<const TitleLayerRaw*>(ptr);
        ptr += sizeof(TitleLayerRaw);

        TitleLayerEntry entry;
        entry.layerId = raw->layerId;
        entry.posX = raw->posX;
        entry.posY = raw->posY;
        entry.dstW = raw->dstW;
        entry.dstH = raw->dstH;
        entry.offset = raw->offset;
        entry.length = raw->length;
        entry.srcW = 0;
        entry.srcH = 0;
        entry.textureId = 0;

        m_layers[i] = entry;
    }

    LOGI("title.pak parsed: %dx%d, %u layers", m_screenWidth, m_screenHeight, numLayers);
    return true;
}

void TitlePak::release() {
    for (auto& layer : m_layers) {
        if (layer.textureId != 0) {
            glDeleteTextures(1, &layer.textureId);
            layer.textureId = 0;
        }
    }
    m_layers.clear();
    m_fileBuffer.clear();
}

GLuint TitlePak::loadTextureFromMemory(const uint8_t* data, size_t length, int* outW, int* outH) {
    int w = 0, h = 0, channels = 0;
    stbi_set_flip_vertically_on_load(0);
    unsigned char* decoded = stbi_load_from_memory(data, static_cast<int>(length), &w, &h, &channels, 4);
    if (!decoded) {
        LOGE("Failed to decode image in title.pak: %s", stbi_failure_reason());
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

const TitleLayerEntry* TitlePak::getLayer(int index) const {
    if (index < 0 || index >= static_cast<int>(m_layers.size())) {
        return nullptr;
    }
    return &m_layers[index];
}

GLuint TitlePak::getTexture(int index) {
    if (index < 0 || index >= static_cast<int>(m_layers.size())) {
        return 0;
    }

    auto& layer = m_layers[index];
    if (layer.textureId == 0) {
        if (layer.offset + layer.length <= m_fileBuffer.size()) {
            layer.textureId = loadTextureFromMemory(
                m_fileBuffer.data() + layer.offset,
                layer.length,
                &layer.srcW,
                &layer.srcH
            );
        }
    }

    return layer.textureId;
}

}
