#ifndef STARBLAST_VIRTUAL_PAD_H
#define STARBLAST_VIRTUAL_PAD_H

#include <cstdint>
#include <GLES3/gl3.h>
#include <android/input.h>
#include "command_manager.h"

namespace starblast {

class SpriteRenderer;

constexpr uint32_t BTN_ATTACK = BTN_A;
constexpr uint32_t BTN_JUMP   = BTN_B;
constexpr uint32_t BTN_DASH   = BTN_C;
constexpr uint32_t BTN_SKILL  = BTN_X;
constexpr uint32_t BTN_SUPER  = BTN_Y;
constexpr uint32_t BTN_ASSIST = BTN_Z;

class VirtualPad {
public:
    VirtualPad();

    void setScreenSize(int width, int height);
    bool handleInput(const AInputEvent* event);
    void render(SpriteRenderer* renderer, float alpha = 0.7f);

    uint32_t getMask() const { return m_mask; }
    bool isTouched() const { return m_touching || m_mask != 0; }
    float getTouchX() const { return m_touchX; }
    float getTouchY() const { return m_touchY; }

private:
    void ensureTextures();

    uint32_t m_mask;
    bool m_touching;
    float m_touchX;
    float m_touchY;
    float m_screenW;
    float m_screenH;

    float m_dpadX;
    float m_dpadY;
    float m_dpadRadius;

    struct ActionBtn {
        float x, y, r;
        uint32_t flag;
        GLuint tex;
        int texW, texH;
    };
    ActionBtn m_buttons[7];

    bool m_texturesLoaded;
    GLuint m_dpadTex;
    int m_dpadW, m_dpadH;
    GLuint m_startTex;
    int m_startW, m_startH;
};

}

#endif
