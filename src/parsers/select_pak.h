// Layer visual antarmuka select karakter select.pak.
#ifndef STARBLAST_SELECT_PAK_H
#define STARBLAST_SELECT_PAK_H

#include <GLES3/gl3.h>
#include <android/asset_manager.h>
#include <string>
#include <vector>
#include <cstdint>

namespace starblast {

enum SelectAssetId {
    SEL_BG_ATMOSPHERE = 0,
    SEL_BG_DARK = 1,
    SEL_BG_GRADIENT = 2,
    SEL_BOTTOM_BAR = 3,
    SEL_HEADER_BAR = 4,
    SEL_CARD_BORDER = 5,
    SEL_CARD_BG = 6,
    SEL_P1_CURSOR_0 = 7,
    SEL_P1_CURSOR_1 = 8,
    SEL_P1_CURSOR_2 = 9,
    SEL_P1_CURSOR_3 = 10,
    SEL_P2_CURSOR_0 = 11,
    SEL_P2_CURSOR_1 = 12,
    SEL_ARROW_LEFT = 13,
    SEL_ARROW_RIGHT = 14,
    SEL_BTN_CONFIRM = 15,
    SEL_BTN_BACK = 16,
    SEL_IC_A = 17,
    SEL_IC_B = 18,
    SEL_BG_ACCENT = 19,
    SEL_BG_VIGNETTE = 20,
    SEL_EMBLEM_CIRCLE = 21,
    SEL_EMBLEM_CREST = 22,
    SEL_ANIM103_START = 23,
    SEL_ANIM103_COUNT = 41,
    SEL_ANIM124_START = 64,
    SEL_ANIM124_COUNT = 21,
    SEL_FONT_MBTL = 85,
    SEL_CARD_DONE_P1 = 86,
    SEL_CARD_DONE_P2 = 87,
};

struct SelectEntry {
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

class SelectPak {
public:
    SelectPak();
    ~SelectPak();

    bool load(const std::string& path, AAssetManager* assetMgr = nullptr);
    void release();

    int getNumEntries() const { return static_cast<int>(m_entries.size()); }
    const SelectEntry* getEntry(int id) const;
    GLuint getTexture(int id);

private:
    GLuint loadTextureFromMemory(const uint8_t* data, size_t length, int* outW = nullptr, int* outH = nullptr);

    int m_screenWidth;
    int m_screenHeight;
    std::vector<SelectEntry> m_entries;
    std::vector<uint8_t> m_fileBuffer;
};

}

#endif
