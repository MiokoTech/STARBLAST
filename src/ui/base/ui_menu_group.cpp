// Implementasi tombol menu dan grup navigasi antarmuka bertingkat.
#include "ui_menu_group.h"

namespace starblast {

UIMenuBtn::UIMenuBtn(const std::string& label, std::shared_ptr<UIBitmapFont> font, std::function<void()> clickFunc)
    : m_label(label), m_font(font), m_func(std::move(clickFunc)) {
    m_width = 300.0f;
    m_height = 45.0f;

    m_highlightBg = std::make_shared<UIBox>(m_width, m_height, 0x1A4068, 0.75f, 0x4896E0, 1.5f);
    m_highlightBg->setVisible(false);
    addChild(m_highlightBg);

    if (m_font) {
        m_text = std::make_shared<UIText>(m_font, m_label);
        m_text->setPosition(15.0f, 10.0f);
        m_text->setTextAlign(TextAlign::LEFT);
        addChild(m_text);
    }
}

void UIMenuBtn::addChildBtn(std::shared_ptr<UIMenuBtn> child) {
    if (child) {
        m_childrenBtns.push_back(child);
    }
}

void UIMenuBtn::setTopLevelMode(bool topLevel) {
    m_isTopLevel = topLevel;
    if (m_isTopLevel) {
        m_height = 40.0f;
    }
}

void UIMenuBtn::hover() {
    if (m_isOpen) return;
    m_isHovered = true;

    if (!m_isTopLevel && m_highlightBg) {
        m_highlightBg->setVisible(true);
        m_highlightBg->setScale(0.01f, 1.0f);

        UITweenParams pScale = UITweenParams::makeScale(1.0f, 1.0f);
        UITween::to(m_highlightBg, 0.18f, pScale, Ease::BACK_OUT);
    }

    if (m_text) {
        m_text->setTextColor(1.0f, 1.0f, 0.3f);
    }
}

void UIMenuBtn::normal() {
    if (m_isOpen) return;
    m_isHovered = false;

    if (m_highlightBg) {
        m_highlightBg->setVisible(false);
    }

    if (m_text) {
        m_text->setTextColor(1.0f, 1.0f, 1.0f);
    }
}

void UIMenuBtn::select() {
    if (m_func) {
        m_func();
    }
}

void UIMenuBtn::openChild() {
    if (m_isOpen) return;
    m_isOpen = true;

    if (m_highlightBg) {
        m_highlightBg->setVisible(true);
        m_highlightBg->setScale(1.0f, 1.0f);
    }

    if (m_text) {
        m_text->setTextColor(0.2f, 0.7f, 1.0f);
    }
}

void UIMenuBtn::closeChild() {
    if (!m_isOpen) return;
    m_isOpen = false;

    if (m_highlightBg) {
        m_highlightBg->setVisible(false);
    }

    if (m_text) {
        m_text->setTextColor(1.0f, 1.0f, 1.0f);
    }
}

void UIMenuBtn::render(SpriteRenderer* renderer) {
    if (!m_visible || m_alpha <= 0.0f) return;
    UINode::render(renderer);
}

bool UIMenuBtn::handleTouch(float tx, float ty, bool isDown) {
    if (!m_visible || m_alpha <= 0.0f) return false;

    if (hitTest(tx, ty)) {
        if (!isDown) {
            hover();
            select();
        }
        return true;
    }
    return false;
}

UIMenuGroup::UIMenuGroup() = default;

void UIMenuGroup::addButton(std::shared_ptr<UIMenuBtn> btn) {
    if (!btn) return;
    m_buttons.push_back(btn);
    addChild(btn);
}

void UIMenuGroup::clearButtons() {
    removeAllChildren();
    m_buttons.clear();
    m_showingChildBtn = nullptr;
    m_currentIndex = 0;
}

void UIMenuGroup::prev() {
    if (!m_enabled) return;
    const auto& list = m_showingChildBtn ? m_showingChildBtn->getChildButtons() : m_buttons;
    if (list.empty()) return;

    --m_currentIndex;
    if (m_currentIndex < 0) {
        m_currentIndex = static_cast<int>(list.size()) - 1;
    }
    hoverIndex(m_currentIndex);
}

void UIMenuGroup::next() {
    if (!m_enabled) return;
    const auto& list = m_showingChildBtn ? m_showingChildBtn->getChildButtons() : m_buttons;
    if (list.empty()) return;

    ++m_currentIndex;
    if (m_currentIndex >= static_cast<int>(list.size())) {
        m_currentIndex = 0;
    }
    hoverIndex(m_currentIndex);
}

void UIMenuGroup::selectCurrent() {
    if (!m_enabled) return;
    auto btn = getCurrentButton();
    if (!btn) return;

    if (btn->hasChildren()) {
        toggleChildren(btn);
    } else {
        btn->select();
    }
}

void UIMenuGroup::back() {
    if (!m_enabled) return;
    if (m_showingChildBtn) {
        closeChildren();
    } else if (m_onBack) {
        m_onBack();
    }
}

void UIMenuGroup::hoverIndex(int index) {
    const auto& list = m_showingChildBtn ? m_showingChildBtn->getChildButtons() : m_buttons;
    if (list.empty()) return;

    m_currentIndex = std::max(0, std::min(index, static_cast<int>(list.size()) - 1));

    for (size_t i = 0; i < list.size(); ++i) {
        if (static_cast<int>(i) == m_currentIndex) {
            list[i]->hover();
        } else {
            list[i]->normal();
        }
    }

    if (m_onHoverChange) {
        m_onHoverChange(m_currentIndex, list[m_currentIndex].get());
    }
}

std::shared_ptr<UIMenuBtn> UIMenuGroup::getCurrentButton() const {
    const auto& list = m_showingChildBtn ? m_showingChildBtn->getChildButtons() : m_buttons;
    if (list.empty() || m_currentIndex < 0 || m_currentIndex >= static_cast<int>(list.size())) {
        return nullptr;
    }
    return list[m_currentIndex];
}

void UIMenuGroup::layoutVertical(float startX, float startY, float gapY) {
    float curY = startY;
    for (auto& btn : m_buttons) {
        btn->setPosition(startX, curY);
        curY += gapY;
    }
}

void UIMenuGroup::fadeIn(float duration, float itemDelay) {
    for (size_t i = 0; i < m_buttons.size(); ++i) {
        auto& btn = m_buttons[i];
        btn->setAlpha(0.0f);
        btn->setScale(0.01f, 1.0f);

        UITweenParams pAlpha = UITweenParams::makeAlpha(1.0f);
        UITween::to(btn, duration, pAlpha, Ease::QUAD_OUT, static_cast<float>(i) * itemDelay);

        UITweenParams pScale = UITweenParams::makeScale(1.0f, 1.0f);
        UITween::to(btn, duration, pScale, Ease::BACK_OUT, static_cast<float>(i) * itemDelay);
    }
}

void UIMenuGroup::toggleChildren(std::shared_ptr<UIMenuBtn> btn) {
    if (m_showingChildBtn == btn) {
        closeChildren();
        return;
    }

    if (m_showingChildBtn) {
        closeChildren();
    }

    m_showingChildBtn = btn;
    m_showingChildBtn->openChild();

    for (auto& topBtn : m_buttons) {
        if (topBtn != m_showingChildBtn) {
            topBtn->setVisible(false);
        }
    }

    float curY = m_showingChildBtn->getY() + m_showingChildBtn->getHeight() + 10.0f;
    for (auto& childBtn : m_showingChildBtn->getChildButtons()) {
        childBtn->setPosition(m_showingChildBtn->getX() + 20.0f, curY);
        childBtn->setVisible(true);
        addChild(childBtn);
        curY += 50.0f;
    }

    m_currentIndex = 0;
    hoverIndex(0);
}

void UIMenuGroup::closeChildren() {
    if (!m_showingChildBtn) return;

    for (auto& childBtn : m_showingChildBtn->getChildButtons()) {
        removeChild(childBtn);
        childBtn->setVisible(false);
    }

    m_showingChildBtn->closeChild();
    m_showingChildBtn = nullptr;

    for (auto& topBtn : m_buttons) {
        topBtn->setVisible(true);
    }

    m_currentIndex = 0;
    hoverIndex(0);
}

void UIMenuGroup::update(float dt) {
    if (!m_visible) return;
    UINode::update(dt);
}

void UIMenuGroup::render(SpriteRenderer* renderer) {
    if (!m_visible || m_alpha <= 0.0f) return;
    UINode::render(renderer);
}

bool UIMenuGroup::handleTouch(float tx, float ty, bool isDown) {
    if (!m_visible || !m_enabled) return false;
    return UINode::handleTouch(tx, ty, isDown);
}

} // namespace starblast
