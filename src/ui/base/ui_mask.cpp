// Implementasi pembatasan render viewport berbasis uji gunting OpenGL.
#include "ui_mask.h"
#include "../../render/sprite_renderer.h"
#include <GLES3/gl3.h>
#include <algorithm>

namespace starblast {

UIMask::UIMask()
    : UINode() {
}

UIMask::UIMask(float width, float height)
    : UINode() {
    setSize(width, height);
}

void UIMask::render(SpriteRenderer* renderer) {
    if (!m_visible || !renderer || m_width <= 0.0f || m_height <= 0.0f) {
        return;
    }

    renderer->flush();

    GLint vp[4];
    glGetIntegerv(GL_VIEWPORT, vp);

    float gx = getGlobalX();
    float gy = getGlobalY();
    float gw = m_width * getGlobalScaleX();
    float gh = m_height * getGlobalScaleY();

    float scaleX = static_cast<float>(vp[2]) / 1280.0f;
    float scaleY = static_cast<float>(vp[3]) / 720.0f;

    int scX = vp[0] + static_cast<int>(gx * scaleX);
    int scY = vp[1] + static_cast<int>((720.0f - (gy + gh)) * scaleY);
    int scW = std::max(0, static_cast<int>(gw * scaleX));
    int scH = std::max(0, static_cast<int>(gh * scaleY));

    glEnable(GL_SCISSOR_TEST);
    glScissor(scX, scY, scW, scH);

    UINode::render(renderer);

    renderer->flush();
    glDisable(GL_SCISSOR_TEST);
}

}
