// animasi pembuka splash.pak.
#ifndef STARBLAST_SPLASH_PAK_H
#define STARBLAST_SPLASH_PAK_H

#include <GLES3/gl3.h>
#include <android/asset_manager.h>
#include <string>
#include <vector>
#include <cstdint>

namespace starblast {

struct SplashImageEntry {
    uint32_t offset;
    uint32_t length;
    GLuint textureId;
};

class SplashPak {
public:
    SplashPak();
    ~SplashPak();

    bool load(const std::string& path, AAssetManager* assetMgr = nullptr);
    void release();

    int getTotalFrames() const { return m_totalFrames; }
    int getWidth() const { return m_width; }
    int getHeight() const { return m_height; }
    int getFps() const { return m_fps; }

    GLuint getTextureForFrame(int frameIndex);

private:
    GLuint loadTextureFromMemory(const uint8_t* data, size_t length);

    int m_width;
    int m_height;
    int m_fps;
    int m_totalFrames;
    int m_numImages;

    std::vector<uint16_t> m_frameSequence;
    std::vector<SplashImageEntry> m_images;
    std::vector<uint8_t> m_fileBuffer;
};

}

#endif
