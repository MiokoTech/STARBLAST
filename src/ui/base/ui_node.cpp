// Implementasi pohon elemen antarmuka grafis game.
#include "ui_node.h"
#include "sprite_renderer.h"

namespace starblast {

UINode::UINode()
    : m_parent(nullptr)
    , m_x(0.0f)
    , m_y(0.0f)
    , m_width(0.0f)
    , m_height(0.0f)
    , m_scaleX(1.0f)
    , m_scaleY(1.0f)
    , m_alpha(1.0f)
    , m_visible(true)
{}

void UINode::addChild(std::shared_ptr<UINode> child) {
    if (!child || child.get() == this) return;
    if (child->m_parent) {
        child->m_parent->removeChild(child);
    }
    child->m_parent = this;
    m_children.push_back(child);
}

void UINode::removeChild(std::shared_ptr<UINode> child) {
    if (!child) return;
    auto it = std::find(m_children.begin(), m_children.end(), child);
    if (it != m_children.end()) {
        (*it)->m_parent = nullptr;
        m_children.erase(it);
    }
}

void UINode::removeAllChildren() {
    for (auto& child : m_children) {
        if (child) child->m_parent = nullptr;
    }
    m_children.clear();
}

float UINode::getGlobalX() const {
    float gx = m_x;
    const UINode* p = m_parent;
    while (p) {
        gx = p->m_x + gx * p->m_scaleX;
        p = p->m_parent;
    }
    return gx;
}

float UINode::getGlobalY() const {
    float gy = m_y;
    const UINode* p = m_parent;
    while (p) {
        gy = p->m_y + gy * p->m_scaleY;
        p = p->m_parent;
    }
    return gy;
}

float UINode::getGlobalAlpha() const {
    float a = m_alpha;
    const UINode* p = m_parent;
    while (p) {
        a *= p->m_alpha;
        p = p->m_parent;
    }
    return a;
}

float UINode::getGlobalScaleX() const {
    float s = m_scaleX;
    const UINode* p = m_parent;
    while (p) {
        s *= p->m_scaleX;
        p = p->m_parent;
    }
    return s;
}

float UINode::getGlobalScaleY() const {
    float s = m_scaleY;
    const UINode* p = m_parent;
    while (p) {
        s *= p->m_scaleY;
        p = p->m_parent;
    }
    return s;
}

bool UINode::hitTest(float gx, float gy) const {
    if (!m_visible || m_alpha <= 0.001f) return false;
    float myGx = getGlobalX();
    float myGy = getGlobalY();
    float myGw = m_width * getGlobalScaleX();
    float myGh = m_height * getGlobalScaleY();
    return (gx >= myGx && gx <= myGx + myGw && gy >= myGy && gy <= myGy + myGh);
}

bool UINode::handleTouch(float tx, float ty, bool isDown) {
    if (!m_visible || m_alpha <= 0.001f) return false;
    for (auto it = m_children.rbegin(); it != m_children.rend(); ++it) {
        if ((*it)->handleTouch(tx, ty, isDown)) return true;
    }
    return false;
}

void UINode::update(float dt) {
    if (!m_visible) return;
    for (auto& child : m_children) {
        child->update(dt);
    }
}

void UINode::render(SpriteRenderer* renderer) {
    if (!m_visible || m_alpha <= 0.001f || !renderer) return;
    for (auto& child : m_children) {
        child->render(renderer);
    }
}

}
