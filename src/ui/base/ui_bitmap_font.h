// Pengelola font bitmap dan koleksi glyph antarmuka.
#ifndef STARBLAST_UI_BITMAP_FONT_H
#define STARBLAST_UI_BITMAP_FONT_H

#include <unordered_map>
#include <string>
#include <memory>
#include <cstdint>

namespace starblast {

struct FontGlyph {
    int id = 0;
    float x = 0.0f;
    float y = 0.0f;
    float width = 0.0f;
    float height = 0.0f;
    float xoffset = 0.0f;
    float yoffset = 0.0f;
    float xadvance = 0.0f;
};

class UIBitmapFont {
public:
    UIBitmapFont();
    ~UIBitmapFont() = default;

    void setTexture(unsigned int textureId, int atlasWidth, int atlasHeight);
    unsigned int getTextureId() const { return m_textureId; }
    int getAtlasWidth() const { return m_atlasWidth; }
    int getAtlasHeight() const { return m_atlasHeight; }

    void setFontSize(float size) { m_fontSize = size; }
    float getFontSize() const { return m_fontSize; }

    void setLineHeight(float height) { m_lineHeight = height; }
    float getLineHeight() const { return m_lineHeight; }

    void setCharGap(float gap) { m_charGap = gap; }
    float getCharGap() const { return m_charGap; }

    void setSpaceGap(float gap) { m_spaceGap = gap; }
    float getSpaceGap() const { return m_spaceGap; }

    void setOffsetY(float offset) { m_offsetY = offset; }
    float getOffsetY() const { return m_offsetY; }

    void addGlyph(const FontGlyph& glyph);
    const FontGlyph* getGlyph(int charCode) const;

    bool loadFromBMFontText(const char* textData, unsigned int textureId, int atlasWidth, int atlasHeight);
    float measureTextWidth(const std::string& text, float letterSpacing = 0.0f) const;

    static std::shared_ptr<UIBitmapFont> createDefaultFont();

private:
    unsigned int m_textureId;
    int m_atlasWidth;
    int m_atlasHeight;
    float m_fontSize;
    float m_lineHeight;
    float m_charGap;
    float m_spaceGap;
    float m_offsetY;
    std::unordered_map<int, FontGlyph> m_glyphs;
};

}

#endif
