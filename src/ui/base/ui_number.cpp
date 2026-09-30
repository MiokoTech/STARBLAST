// Implementasi perenderan digit angka grafis antarmuka.
#include "ui_number.h"
#include "../../render/sprite_renderer.h"
#include <cstdlib>
#include <algorithm>

namespace starblast {

UINumber::UINumber()
    : UINode()
    , m_value(0)
    , m_minDigits(1)
    , m_digitSpacing(0.0f)
    , m_align(NumberAlign::LEFT)
    , m_textureId(0)
    , m_atlasWidth(1)
    , m_atlasHeight(1)
    , m_tintR(1.0f)
    , m_tintG(1.0f)
    , m_tintB(1.0f) {
    m_digitRects.fill(DigitRect{0, 0, 0, 0});
}

void UINumber::setValue(int value) {
    m_value = value;
    updateDimensions();
}

void UINumber::setDigitAtlas(unsigned int textureId, int atlasW, int atlasH, const std::array<DigitRect, 10>& rects) {
    m_textureId = textureId;
    m_atlasWidth = atlasW > 0 ? atlasW : 1;
    m_atlasHeight = atlasH > 0 ? atlasH : 1;
    m_digitRects = rects;
    updateDimensions();
}

void UINumber::setDigitGrid(
    unsigned int textureId,
    int atlasW,
    int atlasH,
    int startX,
    int startY,
    int digitW,
    int digitH,
    int stepX,
    int stepY
) {
    m_textureId = textureId;
    m_atlasWidth = atlasW > 0 ? atlasW : 1;
    m_atlasHeight = atlasH > 0 ? atlasH : 1;

    int effStepX = stepX != 0 ? stepX : digitW;
    int effStepY = stepY;

    for (int i = 0; i < 10; ++i) {
        m_digitRects[i] = DigitRect{
            startX + i * effStepX,
            startY + i * effStepY,
            digitW,
            digitH
        };
    }
    updateDimensions();
}

void UINumber::setMinDigits(int minDigits) {
    m_minDigits = std::max(1, minDigits);
    updateDimensions();
}

void UINumber::setDigitSpacing(float spacing) {
    m_digitSpacing = spacing;
    updateDimensions();
}

void UINumber::setTextColor(float r, float g, float b) {
    m_tintR = r;
    m_tintG = g;
    m_tintB = b;
}

void UINumber::updateDimensions() {
    int v = std::abs(m_value);
    int count = 0;
    if (v == 0) {
        count = 1;
    } else {
        int temp = v;
        while (temp > 0) {
            count++;
            temp /= 10;
        }
    }
    count = std::max(count, m_minDigits);

    float totalW = 0.0f;
    float maxH = 0.0f;

    for (int i = 0; i < count; ++i) {
        totalW += static_cast<float>(m_digitRects[0].width);
        if (i < count - 1) {
            totalW += m_digitSpacing;
        }
    }

    for (int i = 0; i < 10; ++i) {
        maxH = std::max(maxH, static_cast<float>(m_digitRects[i].height));
    }

    m_width = totalW;
    m_height = maxH;
}

void UINumber::render(SpriteRenderer* renderer) {
    if (!m_visible || m_textureId == 0 || !renderer) {
        return;
    }

    int digits[16];
    int len = 0;

    int v = std::abs(m_value);
    if (v == 0) {
        digits[len++] = 0;
    } else {
        while (v > 0 && len < 15) {
            digits[len++] = v % 10;
            v /= 10;
        }
    }

    while (len < m_minDigits && len < 15) {
        digits[len++] = 0;
    }

    for (int i = 0; i < len / 2; ++i) {
        std::swap(digits[i], digits[len - 1 - i]);
    }

    float gx = getGlobalX();
    float gy = getGlobalY();
    float gAlpha = getGlobalAlpha();
    float gScaleX = getGlobalScaleX();
    float gScaleY = getGlobalScaleY();

    float totalWidth = 0.0f;
    for (int i = 0; i < len; ++i) {
        int d = digits[i];
        if (d >= 0 && d <= 9) {
            totalWidth += m_digitRects[d].width * gScaleX;
        }
        if (i < len - 1) {
            totalWidth += m_digitSpacing * gScaleX;
        }
    }

    float startX = gx;
    if (m_align == NumberAlign::CENTER) {
        startX = gx - (totalWidth * 0.5f);
    } else if (m_align == NumberAlign::RIGHT) {
        startX = gx - totalWidth;
    }

    float cursorX = startX;
    for (int i = 0; i < len; ++i) {
        int d = digits[i];
        if (d >= 0 && d <= 9) {
            const auto& r = m_digitRects[d];
            renderer->drawSprite(
                m_textureId,
                cursorX,
                gy,
                r.x,
                r.y,
                r.width,
                r.height,
                m_atlasWidth,
                m_atlasHeight,
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
            cursorX += (r.width + m_digitSpacing) * gScaleX;
        }
    }

    UINode::render(renderer);
}

}
