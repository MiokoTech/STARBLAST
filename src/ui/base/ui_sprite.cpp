// Implementasi komponen visual sprite antarmuka game.
#include "ui_sprite.h"
#include "sprite_renderer.h"

namespace starblast {

UISprite::UISprite()
    : UINode()
    , m_texture(0)
    , m_srcX(0)
    , m_srcY(0)
    , m_srcW(0)
    , m_srcH(0)
    , m_sheetW(0)
    , m_sheetH(0)
    , m_facing(1)
    , m_r(1.0f)
    , m_g(1.0f)
    , m_b(1.0f)
    , m_useGradient(false)
    , m_leftAlpha(1.0f)
    , m_rightAlpha(1.0f)
{}

UISprite::UISprite(GLuint texture, float w, float h)
    : UINode()
    , m_texture(texture)
    , m_srcX(0)
    , m_srcY(0)
    , m_srcW(static_cast<int>(w))
    , m_srcH(static_cast<int>(h))
    , m_sheetW(static_cast<int>(w))
    , m_sheetH(static_cast<int>(h))
    , m_facing(1)
    , m_r(1.0f)
    , m_g(1.0f)
    , m_b(1.0f)
    , m_useGradient(false)
    , m_leftAlpha(1.0f)
    , m_rightAlpha(1.0f)
{
    m_width = w;
    m_height = h;
}

void UISprite::setTexture(GLuint tex, float w, float h) {
    m_texture = tex;
    if (w > 0.0f) m_width = w;
    if (h > 0.0f) m_height = h;
    if (m_srcW == 0 && w > 0.0f) {
        m_srcW = static_cast<int>(w);
        m_sheetW = static_cast<int>(w);
    }
    if (m_srcH == 0 && h > 0.0f) {
        m_srcH = static_cast<int>(h);
        m_sheetH = static_cast<int>(h);
    }
}

void UISprite::setAtlasRect(int x, int y, int w, int h, int sheetW, int sheetH) {
    m_srcX = x;
    m_srcY = y;
    m_srcW = w;
    m_srcH = h;
    m_sheetW = sheetW;
    m_sheetH = sheetH;
    if (m_width == 0.0f) m_width = static_cast<float>(w);
    if (m_height == 0.0f) m_height = static_cast<float>(h);
}

void UISprite::setGradientAlpha(bool enabled, float leftA, float rightA) {
    m_useGradient = enabled;
    m_leftAlpha = leftA;
    m_rightAlpha = rightA;
}

void UISprite::render(SpriteRenderer* renderer) {
    if (!m_visible || !renderer) return;
    float ga = getGlobalAlpha();
    if (ga <= 0.001f) return;

    if (m_texture != 0 && m_srcW > 0 && m_srcH > 0) {
        float gx = getGlobalX();
        float gy = getGlobalY();
        float gsx = getGlobalScaleX();
        float gsy = getGlobalScaleY();

        int shW = m_sheetW > 0 ? m_sheetW : m_srcW;
        int shH = m_sheetH > 0 ? m_sheetH : m_srcH;

        float scaleW = (m_width > 0.0f) ? (m_width / static_cast<float>(m_srcW)) * gsx : gsx;
        float scaleH = (m_height > 0.0f) ? (m_height / static_cast<float>(m_srcH)) * gsy : gsy;

        if (m_useGradient) {
            renderer->drawSpriteGradientH(
                m_texture,
                gx, gy,
                m_srcX, m_srcY, m_srcW, m_srcH,
                shW, shH,
                0, 0, m_facing,
                scaleW, scaleH,
                m_leftAlpha * ga, m_rightAlpha * ga,
                m_r, m_g, m_b
            );
        } else {
            renderer->drawSprite(
                m_texture,
                gx, gy,
                m_srcX, m_srcY, m_srcW, m_srcH,
                shW, shH,
                0, 0, m_facing,
                scaleW, scaleH,
                m_r, m_g, m_b, ga
            );
        }
    }

    UINode::render(renderer);
}

}
