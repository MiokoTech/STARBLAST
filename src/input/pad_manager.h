// Manager kontrol touch screen dan layout virtual pad.
#ifndef STARBLAST_PAD_MANAGER_H
#define STARBLAST_PAD_MANAGER_H

#include <cstdint>
#include <GLES3/gl3.h>
#include <android/input.h>
#include "command_manager.h"

namespace starblast {

class SpriteRenderer;

constexpr uint32_t BTN_ATTACK = 1 << 4;
constexpr uint32_t BTN_JUMP   = 1 << 5;
constexpr uint32_t BTN_DASH   = 1 << 6;
constexpr uint32_t BTN_SKILL  = 1 << 7;
constexpr uint32_t BTN_SUPER  = 1 << 8;
constexpr uint32_t BTN_ASSIST = 1 << 9;
constexpr uint32_t BTN_BURST  = 1 << 11;

enum class PadMode {
    HIDDEN = 0,
    MENU = 1,
    BATTLE = 2
};

class PadManager {
public:
    static PadManager& getInstance();

    void setScreenSize(int width, int height);
    void setMode(PadMode mode) {
        m_mode = mode;
        if (m_mode == PadMode::HIDDEN) m_mask = 0;
    }
    PadMode getMode() const { return m_mode; }

    bool handleInput(const AInputEvent* event);
    void render(SpriteRenderer* renderer, float alpha = 0.75f);

    uint32_t getMask() const { return m_mask; }
    bool isTouched() const { return m_touching; }
    float getTouchX() const { return m_touchX; }
    float getTouchY() const { return m_touchY; }

private:
    PadManager();
    ~PadManager() = default;
    PadManager(const PadManager&) = delete;
    PadManager& operator=(const PadManager&) = delete;

    void ensureTextures();

    PadMode m_mode;
    uint32_t m_mask;
    bool m_touching;
    float m_touchX;
    float m_touchY;
    float m_screenW;
    float m_screenH;
    float m_vpX;
    float m_vpY;
    float m_vpW;
    float m_vpH;

    float m_dpadDrawX;
    float m_dpadDrawY;
    float m_dpadDrawSize;
    float m_dpadCenterX;
    float m_dpadCenterY;
    float m_dpadTouchRadius;

    struct ActionBtn {
        float drawX, drawY, size;
        float centerX, centerY, touchRadius;
        uint32_t flag;
        GLuint tex;
        int texW, texH;
        bool inMenu;
    };
    ActionBtn m_buttons[7];

    float m_startDrawX;
    float m_startDrawY;
    float m_startDrawSize;
    float m_startCenterX;
    float m_startCenterY;
    float m_startTouchRadius;

    bool m_texturesLoaded;
    GLuint m_dpadTex;
    int m_dpadW, m_dpadH;
    GLuint m_startTex;
    int m_startW, m_startH;
};

}

#endif
