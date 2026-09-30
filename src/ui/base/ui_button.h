// Komponen tombol interaktif antarmuka pengguna.
#ifndef STARBLAST_UI_BUTTON_H
#define STARBLAST_UI_BUTTON_H

#include "ui_sprite.h"
#include <functional>

namespace starblast {

enum class ButtonState {
    NORMAL,
    PRESSED,
    HOVER
};

class UIButton : public UISprite {
public:
    UIButton();
    explicit UIButton(GLuint normalTex, float w = 0.0f, float h = 0.0f);
    ~UIButton() override = default;

    void setPressedTexture(GLuint pressedTex) { m_pressedTexture = pressedTex; }
    void setOnClick(std::function<void()> onClick) { m_onClick = std::move(onClick); }

    ButtonState getState() const { return m_state; }

    bool handleTouch(float tx, float ty, bool isDown) override;
    void update(float dt) override;

private:
    ButtonState m_state;
    bool m_isPressed;
    GLuint m_normalTexture;
    GLuint m_pressedTexture;
    std::function<void()> m_onClick;
    float m_targetScale;
    float m_currentScale;
};

}

#endif
