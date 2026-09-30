// Implementasi pemetaan glyph dan parser font bitmap.
#include "ui_bitmap_font.h"
#include <cstring>
#include <cstdlib>
#include <sstream>
#include <algorithm>

namespace starblast {

UIBitmapFont::UIBitmapFont()
    : m_textureId(0)
    , m_atlasWidth(1)
    , m_atlasHeight(1)
    , m_fontSize(24.0f)
    , m_lineHeight(28.0f)
    , m_charGap(0.0f)
    , m_spaceGap(10.0f)
    , m_offsetY(0.0f) {
}

void UIBitmapFont::setTexture(unsigned int textureId, int atlasWidth, int atlasHeight) {
    m_textureId = textureId;
    m_atlasWidth = atlasWidth > 0 ? atlasWidth : 1;
    m_atlasHeight = atlasHeight > 0 ? atlasHeight : 1;
}

void UIBitmapFont::addGlyph(const FontGlyph& glyph) {
    m_glyphs[glyph.id] = glyph;
}

const FontGlyph* UIBitmapFont::getGlyph(int charCode) const {
    auto it = m_glyphs.find(charCode);
    if (it != m_glyphs.end()) {
        return &(it->second);
    }
    return nullptr;
}

static float parseAttributeValue(const std::string& line, const std::string& key) {
    size_t pos = line.find(key);
    if (pos == std::string::npos) {
        return 0.0f;
    }
    pos += key.length();
    while (pos < line.length() && (line[pos] == ' ' || line[pos] == '=' || line[pos] == '\"')) {
        pos++;
    }
    return std::strtof(line.c_str() + pos, nullptr);
}

bool UIBitmapFont::loadFromBMFontText(const char* textData, unsigned int textureId, int atlasWidth, int atlasHeight) {
    if (!textData) {
        return false;
    }

    setTexture(textureId, atlasWidth, atlasHeight);
    m_glyphs.clear();

    std::istringstream stream(textData);
    std::string line;

    while (std::getline(stream, line)) {
        if (line.find("info") != std::string::npos) {
            float size = parseAttributeValue(line, "size");
            if (size > 0.0f) {
                m_fontSize = size;
            }
        } else if (line.find("common") != std::string::npos) {
            float lh = parseAttributeValue(line, "lineHeight");
            if (lh > 0.0f) {
                m_lineHeight = lh;
            }
        } else if (line.find("char ") != std::string::npos || line.find("<char ") != std::string::npos) {
            FontGlyph glyph;
            glyph.id = static_cast<int>(parseAttributeValue(line, "id"));
            glyph.x = parseAttributeValue(line, "x");
            glyph.y = parseAttributeValue(line, "y");
            glyph.width = parseAttributeValue(line, "width");
            glyph.height = parseAttributeValue(line, "height");
            glyph.xoffset = parseAttributeValue(line, "xoffset");
            glyph.yoffset = parseAttributeValue(line, "yoffset");
            glyph.xadvance = parseAttributeValue(line, "xadvance");

            if (glyph.xadvance <= 0.0f && glyph.width > 0.0f) {
                glyph.xadvance = glyph.width;
            }

            m_glyphs[glyph.id] = glyph;
        }
    }

    if (m_glyphs.find(32) != m_glyphs.end()) {
        m_spaceGap = m_glyphs[32].xadvance;
    }

    return !m_glyphs.empty();
}

float UIBitmapFont::measureTextWidth(const std::string& text, float letterSpacing) const {
    float maxWidth = 0.0f;
    float currentLineWidth = 0.0f;

    for (size_t i = 0; i < text.length(); ++i) {
        char c = text[i];
        if (c == '\n') {
            maxWidth = std::max(maxWidth, currentLineWidth);
            currentLineWidth = 0.0f;
            continue;
        }

        if (c == ' ') {
            currentLineWidth += (m_spaceGap > 0.0f ? m_spaceGap : (m_fontSize * 0.5f)) + m_charGap + letterSpacing;
            continue;
        }

        const FontGlyph* glyph = getGlyph(static_cast<unsigned char>(c));
        if (glyph) {
            float adv = glyph->xadvance > 0.0f ? glyph->xadvance : glyph->width;
            currentLineWidth += adv + m_charGap + letterSpacing;
        } else {
            currentLineWidth += (m_fontSize * 0.5f) + m_charGap + letterSpacing;
        }
    }

    return std::max(maxWidth, currentLineWidth);
}

std::shared_ptr<UIBitmapFont> UIBitmapFont::createDefaultFont() {
    auto font = std::make_shared<UIBitmapFont>();
    font->setFontSize(20.0f);
    font->setLineHeight(24.0f);
    font->setSpaceGap(10.0f);
    font->setCharGap(1.0f);

    for (int i = 33; i <= 126; ++i) {
        FontGlyph glyph;
        glyph.id = i;
        glyph.width = 12.0f;
        glyph.height = 18.0f;
        glyph.xoffset = 0.0f;
        glyph.yoffset = 0.0f;
        glyph.xadvance = 13.0f;
        font->addGlyph(glyph);
    }

    return font;
}

}
