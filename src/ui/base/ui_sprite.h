// Komponen visual sprite antarmuka game.
#ifndef STARBLAST_UI_SPRITE_H
#define STARBLAST_UI_SPRITE_H

#include "ui_node.h"
#include <GLES3/gl3.h>

namespace starblast {

class UISprite : public UINode {
public:
    UISprite();
    explicit UISprite(GLuint texture, float w = 0.0f, float h = 0.0f);
    ~UISprite() override = default;

    void setTexture(GLuint tex, float w = 0.0f, float h = 0.0f);
    GLuint getTexture() const { return m_texture; }

    void setAtlasRect(int x, int y, int w, int h, int sheetW, int sheetH);
    void setColorTint(float r, float g, float b) { m_r = r; m_g = g; m_b = b; }
    void setFacing(int facing) { m_facing = facing; }
    int getFacing() const { return m_facing; }

    void setGradientAlpha(bool enabled, float leftA = 1.0f, float rightA = 1.0f);

    void render(SpriteRenderer* renderer) override;

protected:
    GLuint m_texture;
    int m_srcX;
    int m_srcY;
    int m_srcW;
    int m_srcH;
    int m_sheetW;
    int m_sheetH;
    int m_facing;

    float m_r;
    float m_g;
    float m_b;

    bool m_useGradient;
    float m_leftAlpha;
    float m_rightAlpha;
};

}

#endif
