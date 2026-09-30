// Implementasi perenderan panel dan kotak persegi antarmuka.
#include "ui_box.h"
#include "../../render/sprite_renderer.h"

namespace starblast {

UIBox::UIBox()
    : UINode()
    , m_fillR(0.0f)
    , m_fillG(0.0f)
    , m_fillB(0.0f)
    , m_hasBorder(false)
    , m_borderThickness(0.0f)
    , m_borderR(1.0f)
    , m_borderG(1.0f)
    , m_borderB(1.0f)
    , m_borderA(1.0f) {
}

UIBox::UIBox(float width, float height, float r, float g, float b, float a)
    : UINode()
    , m_fillR(r)
    , m_fillG(g)
    , m_fillB(b)
    , m_hasBorder(false)
    , m_borderThickness(0.0f)
    , m_borderR(1.0f)
    , m_borderG(1.0f)
    , m_borderB(1.0f)
    , m_borderA(1.0f) {
    setSize(width, height);
    setAlpha(a);
}

void UIBox::setColor(float r, float g, float b) {
    m_fillR = r;
    m_fillG = g;
    m_fillB = b;
}

void UIBox::setColorHex(uint32_t rgb) {
    m_fillR = ((rgb >> 16) & 0xFF) / 255.0f;
    m_fillG = ((rgb >> 8) & 0xFF) / 255.0f;
    m_fillB = (rgb & 0xFF) / 255.0f;
}

void UIBox::setBorder(float thickness, float r, float g, float b, float a) {
    m_hasBorder = thickness > 0.0f;
    m_borderThickness = thickness;
    m_borderR = r;
    m_borderG = g;
    m_borderB = b;
    m_borderA = a;
}

void UIBox::clearBorder() {
    m_hasBorder = false;
    m_borderThickness = 0.0f;
}

void UIBox::render(SpriteRenderer* renderer) {
    if (!m_visible || !renderer || m_width <= 0.0f || m_height <= 0.0f) {
        return;
    }

    float gx = getGlobalX();
    float gy = getGlobalY();
    float gScaleX = getGlobalScaleX();
    float gScaleY = getGlobalScaleY();
    float gAlpha = getGlobalAlpha();

    float sw = m_width * gScaleX;
    float sh = m_height * gScaleY;

    if (gAlpha > 0.001f) {
        renderer->drawRect(gx, gy, sw, sh, m_fillR, m_fillG, m_fillB, gAlpha);
    }

    if (m_hasBorder && m_borderThickness > 0.0f) {
        float btX = m_borderThickness * gScaleX;
        float btY = m_borderThickness * gScaleY;
        float bAlpha = m_borderA * gAlpha;

        renderer->drawRect(gx, gy, sw, btY, m_borderR, m_borderG, m_borderB, bAlpha);
        renderer->drawRect(gx, gy + sh - btY, sw, btY, m_borderR, m_borderG, m_borderB, bAlpha);
        renderer->drawRect(gx, gy + btY, btX, sh - (2.0f * btY), m_borderR, m_borderG, m_borderB, bAlpha);
        renderer->drawRect(gx + sw - btX, gy + btY, btX, sh - (2.0f * btY), m_borderR, m_borderG, m_borderB, bAlpha);
    }

    UINode::render(renderer);
}

}
