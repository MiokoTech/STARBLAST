// Pembaca layer visual menu utama menu.pak.
#ifndef STARBLAST_MENU_PAK_H
#define STARBLAST_MENU_PAK_H

#include <GLES3/gl3.h>
#include <android/asset_manager.h>
#include <string>
#include <vector>
#include <cstdint>

namespace starblast {

struct MenuEntry {
    uint32_t id;
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

class MenuPak {
public:
    MenuPak();
    ~MenuPak();

    bool load(const std::string& path, AAssetManager* assetMgr = nullptr);
    void release();

    int getNumEntries() const { return static_cast<int>(m_entries.size()); }
    const MenuEntry* getEntry(int id) const;
    GLuint getTexture(int id);

private:
    GLuint loadTextureFromMemory(const uint8_t* data, size_t length, int* outW = nullptr, int* outH = nullptr);

    int m_screenWidth;
    int m_screenHeight;
    std::vector<MenuEntry> m_entries;
    std::vector<uint8_t> m_fileBuffer;
};

}

#endif
