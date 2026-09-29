// data frame dan tekstur animasi splash.
#include "splash_pak.h"
#include <android/log.h>
#include <fstream>
#include <cstring>
#include "stb_image.h"

#define LOG_TAG "SplashPak"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

#pragma pack(push, 1)
struct SplashHeader {
    char magic[4];
    uint32_t version;
    uint32_t width;
    uint32_t height;
    uint32_t fps;
    uint32_t totalFrames;
    uint32_t numImages;
    uint32_t reserved;
};
#pragma pack(pop)

SplashPak::SplashPak()
    : m_width(1280)
    , m_height(720)
    , m_fps(30)
    , m_totalFrames(0)
    , m_numImages(0)
{}

SplashPak::~SplashPak() {
    release();
}

bool SplashPak::load(const std::string& path, AAssetManager* assetMgr) {
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
                LOGI("Loaded splash.pak from APK asset: %s (%zu bytes)", p.c_str(), m_fileBuffer.size());
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

    if (!readSuccess || m_fileBuffer.size() < sizeof(SplashHeader)) {
        LOGE("Failed to load splash.pak: %s", path.c_str());
        return false;
    }

    const uint8_t* ptr = m_fileBuffer.data();
    const auto* header = reinterpret_cast<const SplashHeader*>(ptr);

    if (std::memcmp(header->magic, "SPL1", 4) != 0) {
        LOGE("Invalid splash.pak magic header");
        return false;
    }

    m_width = header->width;
    m_height = header->height;
    m_fps = header->fps;
    m_totalFrames = header->totalFrames;
    m_numImages = header->numImages;

    ptr += sizeof(SplashHeader);

    m_frameSequence.resize(m_totalFrames);
    std::memcpy(m_frameSequence.data(), ptr, m_totalFrames * sizeof(uint16_t));
    ptr += m_totalFrames * sizeof(uint16_t);

    m_images.resize(m_numImages);
    for (int i = 0; i < m_numImages; ++i) {
        uint32_t off = 0, len = 0;
        std::memcpy(&off, ptr, sizeof(uint32_t));
        ptr += sizeof(uint32_t);
        std::memcpy(&len, ptr, sizeof(uint32_t));
        ptr += sizeof(uint32_t);

        m_images[i] = {off, len, 0};
    }

    LOGI("splash.pak parsed: %dx%d, %d frames, %d unique images", m_width, m_height, m_totalFrames, m_numImages);
    return true;
}

void SplashPak::release() {
    for (auto& img : m_images) {
        if (img.textureId != 0) {
            glDeleteTextures(1, &img.textureId);
            img.textureId = 0;
        }
    }
    m_images.clear();
    m_frameSequence.clear();
    m_fileBuffer.clear();
    m_totalFrames = 0;
    m_numImages = 0;
}

GLuint SplashPak::loadTextureFromMemory(const uint8_t* data, size_t length) {
    int w = 0, h = 0, channels = 0;
    stbi_set_flip_vertically_on_load(0);
    unsigned char* decoded = stbi_load_from_memory(data, static_cast<int>(length), &w, &h, &channels, 4);
    if (!decoded) {
        LOGE("Failed to decode PNG in splash.pak: %s", stbi_failure_reason());
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
    return texId;
}

GLuint SplashPak::getTextureForFrame(int frameIndex) {
    if (frameIndex < 0 || frameIndex >= static_cast<int>(m_frameSequence.size())) {
        return 0;
    }

    uint16_t imgIdx = m_frameSequence[frameIndex];
    if (imgIdx >= m_images.size()) {
        return 0;
    }

    auto& img = m_images[imgIdx];
    if (img.textureId == 0) {
        if (img.offset + img.length <= m_fileBuffer.size()) {
            img.textureId = loadTextureFromMemory(m_fileBuffer.data() + img.offset, img.length);
        }
    }

    return img.textureId;
}

}
