// Komponen antarmuka perenderan digit angka sprite game.
#ifndef STARBLAST_UI_NUMBER_H
#define STARBLAST_UI_NUMBER_H

#include "ui_node.h"
#include <array>
#include <cstdint>

namespace starblast {

enum class NumberAlign {
    LEFT,
    CENTER,
    RIGHT
};

struct DigitRect {
    int x = 0;
    int y = 0;
    int width = 0;
    int height = 0;
};

class UINumber : public UINode {
public:
    UINumber();
    ~UINumber() override = default;

    void setValue(int value);
    int getValue() const { return m_value; }

    void setDigitAtlas(unsigned int textureId, int atlasW, int atlasH, const std::array<DigitRect, 10>& rects);
    void setDigitGrid(unsigned int textureId, int atlasW, int atlasH, int startX, int startY, int digitW, int digitH, int stepX = 0, int stepY = 0);

    void setMinDigits(int minDigits);
    int getMinDigits() const { return m_minDigits; }

    void setDigitSpacing(float spacing);
    float getDigitSpacing() const { return m_digitSpacing; }

    void setAlignment(NumberAlign align) { m_align = align; }
    NumberAlign getAlignment() const { return m_align; }

    void setTextColor(float r, float g, float b);
    void render(SpriteRenderer* renderer) override;

private:
    void updateDimensions();

    int m_value;
    int m_minDigits;
    float m_digitSpacing;
    NumberAlign m_align;

    unsigned int m_textureId;
    int m_atlasWidth;
    int m_atlasHeight;
    std::array<DigitRect, 10> m_digitRects;

    float m_tintR;
    float m_tintG;
    float m_tintB;
};

}

#endif
