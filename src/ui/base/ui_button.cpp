// Implementasi tombol interaktif antarmuka pengguna.
#include "ui_button.h"
#include <cmath>

namespace starblast {

UIButton::UIButton()
    : UISprite()
    , m_state(ButtonState::NORMAL)
    , m_isPressed(false)
    , m_normalTexture(0)
    , m_pressedTexture(0)
    , m_onClick(nullptr)
    , m_targetScale(1.0f)
    , m_currentScale(1.0f)
{}

UIButton::UIButton(GLuint normalTex, float w, float h)
    : UISprite(normalTex, w, h)
    , m_state(ButtonState::NORMAL)
    , m_isPressed(false)
    , m_normalTexture(normalTex)
    , m_pressedTexture(0)
    , m_onClick(nullptr)
    , m_targetScale(1.0f)
    , m_currentScale(1.0f)
{}

bool UIButton::handleTouch(float tx, float ty, bool isDown) {
    if (!m_visible || m_alpha <= 0.001f) return false;

    if (UINode::handleTouch(tx, ty, isDown)) {
        return true;
    }

    bool inside = hitTest(tx, ty);

    if (isDown) {
        if (inside) {
            m_isPressed = true;
            m_state = ButtonState::PRESSED;
            m_targetScale = 0.94f;
            if (m_pressedTexture != 0) {
                m_texture = m_pressedTexture;
            }
            return true;
        }
    } else {
        if (m_isPressed) {
            m_isPressed = false;
            m_state = inside ? ButtonState::HOVER : ButtonState::NORMAL;
            m_targetScale = 1.0f;
            if (m_normalTexture != 0) {
                m_texture = m_normalTexture;
            }
            if (inside && m_onClick) {
                m_onClick();
            }
            return true;
        }
    }

    return false;
}

void UIButton::update(float dt) {
    UISprite::update(dt);

    if (m_currentScale != m_targetScale) {
        float speed = 18.0f * dt;
        if (std::abs(m_targetScale - m_currentScale) < speed) {
            m_currentScale = m_targetScale;
        } else if (m_currentScale < m_targetScale) {
            m_currentScale += speed;
        } else {
            m_currentScale -= speed;
        }
        setScale(m_currentScale);
    }
}

}
