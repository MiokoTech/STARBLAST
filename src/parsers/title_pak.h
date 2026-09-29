// Layer visual title screen title.pak.
#ifndef STARBLAST_TITLE_PAK_H
#define STARBLAST_TITLE_PAK_H

#include <GLES3/gl3.h>
#include <android/asset_manager.h>
#include <string>
#include <vector>
#include <cstdint>

namespace starblast {

struct TitleLayerEntry {
    uint32_t layerId;
    float posX;
    float posY;
    float dstW;
    float dstH;
    uint32_t offset;
    uint32_t length;
    int srcW;
    int srcH;
    GLuint textureId;
};

class TitlePak {
public:
    TitlePak();
    ~TitlePak();

    bool load(const std::string& path, AAssetManager* assetMgr = nullptr);
    void release();

    int getNumLayers() const { return static_cast<int>(m_layers.size()); }
    int getScreenWidth() const { return m_screenWidth; }
    int getScreenHeight() const { return m_screenHeight; }

    const TitleLayerEntry* getLayer(int index) const;
    GLuint getTexture(int index);

private:
    GLuint loadTextureFromMemory(const uint8_t* data, size_t length, int* outW = nullptr, int* outH = nullptr);

    int m_screenWidth;
    int m_screenHeight;
    std::vector<TitleLayerEntry> m_layers;
    std::vector<uint8_t> m_fileBuffer;
};

}

#endif
