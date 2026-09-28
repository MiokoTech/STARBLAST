// Load ffie gambar ke tekstur GPU.
#include "texture_manager.h"
#include <android/log.h>
#include <vector>

#define STB_IMAGE_IMPLEMENTATION
#include "stb_image.h"

#define LOG_TAG "TextureManager"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

TextureManager& TextureManager::getInstance() {
    static TextureManager instance;
    return instance;
}

TextureManager::~TextureManager() {
    clear();
}

TextureInfo TextureManager::loadTexture(const std::string& filepath) {
    auto it = m_cache.find(filepath);
    if (it != m_cache.end()) {
        return it->second;
    }

    int w = 0, h = 0, channels = 0;
    stbi_set_flip_vertically_on_load(0);
    unsigned char* data = nullptr;

    if (m_assetManager) {
        std::vector<std::string> tryPaths = {filepath};
        if (filepath.rfind("assets/", 0) == 0) {
            tryPaths.push_back(filepath.substr(7));
        } else {
            tryPaths.push_back("assets/" + filepath);
        }

        for (const auto& p : tryPaths) {
            AAsset* asset = AAssetManager_open(m_assetManager, p.c_str(), AASSET_MODE_BUFFER);
            if (asset) {
                off_t length = AAsset_getLength(asset);
                const void* buffer = AAsset_getBuffer(asset);
                if (buffer) {
                    data = stbi_load_from_memory(static_cast<const unsigned char*>(buffer), length, &w, &h, &channels, 4);
                } else {
                    std::vector<unsigned char> temp(length);
                    AAsset_read(asset, temp.data(), length);
                    data = stbi_load_from_memory(temp.data(), length, &w, &h, &channels, 4);
                }
                AAsset_close(asset);
                if (data) {
                    LOGI("Loaded texture from APK asset: %s (%dx%d)", p.c_str(), w, h);
                    break;
                }
            }
        }
    }

    if (!data) {
        std::vector<std::string> fsPaths = {
            filepath,
            "assets/" + filepath,
            "/sdcard/MiokoTech/STARBLAST/" + filepath,
            "/sdcard/MiokoTech/STARBLAST/assets/" + filepath,
            "/sdcard/MiokoTech/STARBLAST/android_app/" + filepath,
            "/sdcard/MiokoTech/STARBLAST/android_app/drawable/" + filepath
        };
        for (const auto& fp : fsPaths) {
            data = stbi_load(fp.c_str(), &w, &h, &channels, 4);
            if (data) break;
        }
    }

    if (!data) {
        LOGE("Failed to load image: %s (reason: %s)", filepath.c_str(), stbi_failure_reason());
        return {0, 0, 0};
    }

    GLuint texId;
    glGenTextures(1, &texId);
    glBindTexture(GL_TEXTURE_2D, texId);

    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);

    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
    glBindTexture(GL_TEXTURE_2D, 0);

    stbi_image_free(data);

    TextureInfo info{texId, w, h};
    m_cache[filepath] = info;
    return info;
}

void TextureManager::releaseTexture(const std::string& filepath) {
    auto it = m_cache.find(filepath);
    if (it != m_cache.end()) {
        if (it->second.id != 0) {
            glDeleteTextures(1, &it->second.id);
        }
        m_cache.erase(it);
    }
}

void TextureManager::clear() {
    for (auto& pair : m_cache) {
        if (pair.second.id != 0) {
            glDeleteTextures(1, &pair.second.id);
        }
    }
    m_cache.clear();
}

}
