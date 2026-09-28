// Manager cache tekstur OpenGL.
#ifndef STARBLAST_TEXTURE_MANAGER_H
#define STARBLAST_TEXTURE_MANAGER_H

#include <GLES3/gl3.h>
#include <android/asset_manager.h>
#include <string>
#include <unordered_map>

namespace starblast {

struct TextureInfo {
    GLuint id = 0;
    int width = 0;
    int height = 0;
};

class TextureManager {
public:
    static TextureManager& getInstance();

    void setAssetManager(AAssetManager* mgr) { m_assetManager = mgr; }
    AAssetManager* getAssetManager() const { return m_assetManager; }

    TextureInfo loadTexture(const std::string& filepath);
    void releaseTexture(const std::string& filepath);
    void clear();

private:
    TextureManager() = default;
    ~TextureManager();

    AAssetManager* m_assetManager = nullptr;
    std::unordered_map<std::string, TextureInfo> m_cache;
};

}

#endif
