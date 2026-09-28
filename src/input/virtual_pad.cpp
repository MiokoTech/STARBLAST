#include "virtual_pad.h"
#include "texture_manager.h"
#include "sprite_renderer.h"
#include <cmath>
#include <algorithm>

namespace starblast {

VirtualPad::VirtualPad()
    : m_mask(0)
    , m_touching(false)
    , m_touchX(-1.0f)
    , m_touchY(-1.0f)
    , m_screenW(1280.0f)
    , m_screenH(720.0f)
    , m_dpadX(135.0f)
    , m_dpadY(585.0f)
    , m_dpadRadius(100.0f)
    , m_texturesLoaded(false)
    , m_dpadTex(0)
    , m_dpadW(0)
    , m_dpadH(0)
    , m_startTex(0)
    , m_startW(0)
    , m_startH(0)
{
    m_buttons[0] = {1105.0f, 605.0f, 36.0f, BTN_ATTACK, 0, 0, 0};
    m_buttons[1] = {1170.0f, 665.0f, 36.0f, BTN_JUMP,   0, 0, 0};
    m_buttons[2] = {1235.0f, 605.0f, 36.0f, BTN_DASH,   0, 0, 0};
    m_buttons[3] = {1170.0f, 545.0f, 36.0f, BTN_SKILL,  0, 0, 0};
    m_buttons[4] = {1230.0f, 395.0f, 34.0f, BTN_SUPER,  0, 0, 0};
    m_buttons[5] = {1090.0f, 395.0f, 34.0f, BTN_ASSIST, 0, 0, 0};
    m_buttons[6] = {1160.0f, 340.0f, 34.0f, BTN_SUPER | BTN_ASSIST, 0, 0, 0};
}

void VirtualPad::setScreenSize(int width, int height) {
    if (width > 0) m_screenW = static_cast<float>(width);
    if (height > 0) m_screenH = static_cast<float>(height);
}

bool VirtualPad::handleInput(const AInputEvent* event) {
    if (AInputEvent_getType(event) != AINPUT_EVENT_TYPE_MOTION) {
        return false;
    }

    int32_t action = AMotionEvent_getAction(event);
    int32_t actionMasked = action & AMOTION_EVENT_ACTION_MASK;
    size_t pointerCount = AMotionEvent_getPointerCount(event);

    if (actionMasked == AMOTION_EVENT_ACTION_UP || actionMasked == AMOTION_EVENT_ACTION_CANCEL) {
        m_touching = false;
        m_mask = 0;
        m_touchX = -1.0f;
        m_touchY = -1.0f;
        return true;
    }

    m_touching = true;

    float scaleX = 1280.0f / m_screenW;
    float scaleY = 720.0f / m_screenH;
    m_touchX = AMotionEvent_getX(event, 0) * scaleX;
    m_touchY = AMotionEvent_getY(event, 0) * scaleY;

    uint32_t newMask = 0;

    for (size_t i = 0; i < pointerCount; i++) {
        if (actionMasked == AMOTION_EVENT_ACTION_POINTER_UP) {
            size_t actionIndex = (action & AMOTION_EVENT_ACTION_POINTER_INDEX_MASK) >> AMOTION_EVENT_ACTION_POINTER_INDEX_SHIFT;
            if (i == actionIndex) continue;
        }
        if (actionMasked == AMOTION_EVENT_ACTION_UP) {
            continue;
        }

        float tx = AMotionEvent_getX(event, i) * scaleX;
        float ty = AMotionEvent_getY(event, i) * scaleY;

        float dx = tx - m_dpadX;
        float dy = ty - m_dpadY;
        float dist = std::sqrt(dx * dx + dy * dy);
        if (dist < m_dpadRadius * 1.5f && dist > 20.0f) {
            float angle = std::atan2(dy, dx) * 180.0f / 3.14159265f;
            if (angle >= -157.5f && angle < -22.5f)  newMask |= BTN_UP;
            if (angle >= 22.5f && angle < 157.5f)    newMask |= BTN_DOWN;
            if (std::abs(angle) >= 112.5f)          newMask |= BTN_LEFT;
            if (std::abs(angle) < 67.5f)            newMask |= BTN_RIGHT;
        }

        for (const auto& btn : m_buttons) {
            float bdx = tx - btn.x;
            float bdy = ty - btn.y;
            if (bdx * bdx + bdy * bdy <= btn.r * btn.r * 1.6f) {
                newMask |= btn.flag;
            }
        }
    }

    m_mask = newMask;
    return true;
}

void VirtualPad::ensureTextures() {
    if (m_texturesLoaded) return;

    auto dpadInfo = TextureManager::getInstance().loadTexture("joy/arrow.png");
    m_dpadTex = dpadInfo.id;
    m_dpadW = dpadInfo.width;
    m_dpadH = dpadInfo.height;

    auto startInfo = TextureManager::getInstance().loadTexture("joy/start.png");
    m_startTex = startInfo.id;
    m_startW = startInfo.width;
    m_startH = startInfo.height;

    const char* btnFiles[7] = {
        "joy/X.png",
        "joy/A.png",
        "joy/B.png",
        "joy/Y.png",
        "joy/L.png",
        "joy/R.png",
        "joy/L2.png"
    };

    for (int i = 0; i < 7; ++i) {
        auto info = TextureManager::getInstance().loadTexture(btnFiles[i]);
        m_buttons[i].tex = info.id;
        m_buttons[i].texW = info.width;
        m_buttons[i].texH = info.height;
    }

    m_texturesLoaded = true;
}

void VirtualPad::render(SpriteRenderer* renderer, float alpha) {
    if (!renderer || alpha <= 0.01f) return;

    ensureTextures();

    if (m_dpadTex != 0) {
        bool dpadPressed = (m_mask & (BTN_UP | BTN_DOWN | BTN_LEFT | BTN_RIGHT)) != 0;
        float dpadScale = dpadPressed ? 1.05f : 1.0f;
        float dpadSize = m_dpadRadius * 2.0f;
        float drawSize = dpadSize * dpadScale;
        float px = m_dpadX - drawSize * 0.5f;
        float py = m_dpadY - drawSize * 0.5f;
        float a = dpadPressed ? std::min(1.0f, alpha * 1.3f) : alpha * 0.75f;
        renderer->drawSprite(
            m_dpadTex,
            px, py,
            0, 0, m_dpadW, m_dpadH,
            drawSize, drawSize,
            0, 0, 1,
            1.0f, 1.0f,
            1.0f, 1.0f, 1.0f, a
        );
    }

    for (const auto& btn : m_buttons) {
        if (btn.tex == 0) continue;

        bool pressed = (m_mask & btn.flag) != 0;
        float btnScale = pressed ? 1.15f : 1.0f;
        float drawSize = btn.r * 2.0f * btnScale;
        float px = btn.x - drawSize * 0.5f;
        float py = btn.y - drawSize * 0.5f;
        float a = pressed ? std::min(1.0f, alpha * 1.35f) : alpha * 0.75f;

        renderer->drawSprite(
            btn.tex,
            px, py,
            0, 0, btn.texW, btn.texH,
            drawSize, drawSize,
            0, 0, 1,
            1.0f, 1.0f,
            1.0f, 1.0f, 1.0f, a
        );
    }

    if (m_startTex != 0) {
        float startW = 50.0f;
        float startH = 50.0f;
        float px = 615.0f;
        float py = 18.0f;
        renderer->drawSprite(
            m_startTex,
            px, py,
            0, 0, m_startW, m_startH,
            startW, startH,
            0, 0, 1,
            1.0f, 1.0f,
            1.0f, 1.0f, 1.0f, alpha * 0.8f
        );
    }
}

}
