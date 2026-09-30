// Implementasi perenderan dan perataan teks antarmuka.
#include "ui_text.h"
#include "../../render/sprite_renderer.h"
#include <sstream>
#include <vector>

namespace starblast {

UIText::UIText()
    : UINode()
    , m_font(nullptr)
    , m_text("")
    , m_align(TextAlign::LEFT)
    , m_tintR(1.0f)
    , m_tintG(1.0f)
    , m_tintB(1.0f)
    , m_letterSpacing(0.0f) {
}

UIText::UIText(std::shared_ptr<UIBitmapFont> font, const std::string& text)
    : UINode()
    , m_font(font)
    , m_text(text)
    , m_align(TextAlign::LEFT)
    , m_tintR(1.0f)
    , m_tintG(1.0f)
    , m_tintB(1.0f)
    , m_letterSpacing(0.0f) {
    updateDimensions();
}

void UIText::setFont(std::shared_ptr<UIBitmapFont> font) {
    m_font = font;
    updateDimensions();
}

void UIText::setText(const std::string& text) {
    m_text = text;
    updateDimensions();
}

void UIText::setTextAlign(TextAlign align) {
    m_align = align;
}

void UIText::setTextColor(float r, float g, float b) {
    m_tintR = r;
    m_tintG = g;
    m_tintB = b;
}

void UIText::getTextColor(float& r, float& g, float& b) const {
    r = m_tintR;
    g = m_tintG;
    b = m_tintB;
}

void UIText::setLetterSpacing(float spacing) {
    m_letterSpacing = spacing;
    updateDimensions();
}

void UIText::updateDimensions() {
    if (!m_font || m_text.empty()) {
        m_width = 0.0f;
        m_height = 0.0f;
        return;
    }

    float maxLineWidth = 0.0f;
    int lineCount = 1;
    std::string currentLine;

    for (char c : m_text) {
        if (c == '\n') {
            float lw = m_font->measureTextWidth(currentLine, m_letterSpacing);
            if (lw > maxLineWidth) {
                maxLineWidth = lw;
            }
            currentLine.clear();
            lineCount++;
        } else {
            currentLine.push_back(c);
        }
    }

    if (!currentLine.empty()) {
        float lw = m_font->measureTextWidth(currentLine, m_letterSpacing);
        if (lw > maxLineWidth) {
            maxLineWidth = lw;
        }
    }

    m_width = maxLineWidth;
    m_height = lineCount * m_font->getLineHeight();
}

void UIText::render(SpriteRenderer* renderer) {
    if (!m_visible || m_text.empty() || !m_font || !renderer) {
        return;
    }

    GLuint texId = m_font->getTextureId();
    if (texId == 0) {
        return;
    }

    int atlasW = m_font->getAtlasWidth();
    int atlasH = m_font->getAtlasHeight();
    float gx = getGlobalX();
    float gy = getGlobalY();
    float gAlpha = getGlobalAlpha();
    float gScaleX = getGlobalScaleX();
    float gScaleY = getGlobalScaleY();
    float lineHeight = m_font->getLineHeight() * gScaleY;

    std::vector<std::string> lines;
    std::string currentLine;
    for (char c : m_text) {
        if (c == '\n') {
            lines.push_back(currentLine);
            currentLine.clear();
        } else {
            currentLine.push_back(c);
        }
    }
    lines.push_back(currentLine);

    float currentY = gy;
    for (const auto& line : lines) {
        float lineWidth = m_font->measureTextWidth(line, m_letterSpacing) * gScaleX;
        float lineStartX = gx;

        if (m_align == TextAlign::CENTER) {
            lineStartX = gx - (lineWidth * 0.5f);
        } else if (m_align == TextAlign::RIGHT) {
            lineStartX = gx - lineWidth;
        }

        float cursorX = lineStartX;
        for (char c : line) {
            if (c == ' ') {
                float spaceAdvance = (m_font->getSpaceGap() > 0.0f ? m_font->getSpaceGap() : (m_font->getFontSize() * 0.5f));
                cursorX += (spaceAdvance + m_font->getCharGap() + m_letterSpacing) * gScaleX;
                continue;
            }

            const FontGlyph* glyph = m_font->getGlyph(static_cast<unsigned char>(c));
            if (glyph) {
                float charScreenX = cursorX + (glyph->xoffset * gScaleX);
                float charScreenY = currentY + ((glyph->yoffset + m_font->getOffsetY()) * gScaleY);

                renderer->drawSprite(
                    texId,
                    charScreenX,
                    charScreenY,
                    static_cast<int>(glyph->x),
                    static_cast<int>(glyph->y),
                    static_cast<int>(glyph->width),
                    static_cast<int>(glyph->height),
                    atlasW,
                    atlasH,
                    0,
                    0,
                    1,
                    gScaleX,
                    gScaleY,
                    m_tintR,
                    m_tintG,
                    m_tintB,
                    gAlpha
                );

                float advance = glyph->xadvance > 0.0f ? glyph->xadvance : glyph->width;
                cursorX += (advance + m_font->getCharGap() + m_letterSpacing) * gScaleX;
            } else {
                cursorX += ((m_font->getFontSize() * 0.5f) + m_font->getCharGap() + m_letterSpacing) * gScaleX;
            }
        }

        currentY += lineHeight;
    }

    UINode::render(renderer);
}

}
