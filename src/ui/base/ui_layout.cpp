// Implementasi pengatur tata letak linier dan area penyesuaian otomatis.
#include "ui_layout.h"
#include <algorithm>

namespace starblast {

UIHBox::UIHBox(float spacing, UIAlign align)
    : UINode()
    , m_spacing(spacing)
    , m_align(align)
{}

void UIHBox::relayout() {
    if (m_children.empty()) return;

    float totalW = 0.0f;
    float maxH = 0.0f;

    for (size_t i = 0; i < m_children.size(); ++i) {
        float cw = m_children[i]->getWidth() * m_children[i]->getScaleX();
        float ch = m_children[i]->getHeight() * m_children[i]->getScaleY();
        totalW += cw;
        if (i + 1 < m_children.size()) totalW += m_spacing;
        if (ch > maxH) maxH = ch;
    }

    m_width = totalW;
    m_height = maxH;

    float curX = 0.0f;
    if (m_align == UIAlign::CENTER) {
        curX = -totalW * 0.5f;
    } else if (m_align == UIAlign::END) {
        curX = -totalW;
    }

    for (auto& child : m_children) {
        child->setPosition(curX, 0.0f);
        curX += child->getWidth() * child->getScaleX() + m_spacing;
    }
}

UIVBox::UIVBox(float spacing, UIAlign align)
    : UINode()
    , m_spacing(spacing)
    , m_align(align)
{}

void UIVBox::relayout() {
    if (m_children.empty()) return;

    float totalH = 0.0f;
    float maxW = 0.0f;

    for (size_t i = 0; i < m_children.size(); ++i) {
        float cw = m_children[i]->getWidth() * m_children[i]->getScaleX();
        float ch = m_children[i]->getHeight() * m_children[i]->getScaleY();
        totalH += ch;
        if (i + 1 < m_children.size()) totalH += m_spacing;
        if (cw > maxW) maxW = cw;
    }

    m_width = maxW;
    m_height = totalH;

    float curY = 0.0f;
    if (m_align == UIAlign::CENTER) {
        curY = -totalH * 0.5f;
    } else if (m_align == UIAlign::END) {
        curY = -totalH;
    }

    for (auto& child : m_children) {
        child->setPosition(0.0f, curY);
        curY += child->getHeight() * child->getScaleY() + m_spacing;
    }
}

UIAutoFitArea::UIAutoFitArea(float x, float y, float width, float height,
                             ScaleMode scaleMode, AlignMode hAlign, AlignMode vAlign)
    : m_scaleMode(scaleMode)
    , m_hAlign(hAlign)
    , m_vAlign(vAlign) {
    m_x = x;
    m_y = y;
    m_width = width;
    m_height = height;
}

void UIAutoFitArea::attach(std::shared_ptr<UINode> target) {
    if (!target) return;
    m_attached.push_back(target);
    addChild(target);
    fit();
}

void UIAutoFitArea::detach(std::shared_ptr<UINode> target) {
    if (!target) return;
    auto it = std::find(m_attached.begin(), m_attached.end(), target);
    if (it != m_attached.end()) {
        m_attached.erase(it);
        removeChild(target);
    }
}

void UIAutoFitArea::fit() {
    if (m_attached.empty() || m_width <= 0.0f || m_height <= 0.0f) return;

    for (auto& target : m_attached) {
        float tw = target->getWidth();
        float th = target->getHeight();
        if (tw <= 0.0f || th <= 0.0f) continue;

        float sx = 1.0f;
        float sy = 1.0f;

        switch (m_scaleMode) {
            case ScaleMode::STRETCH:
                sx = m_width / tw;
                sy = m_height / th;
                break;
            case ScaleMode::PROPORTIONAL_INSIDE: {
                float s = std::min(m_width / tw, m_height / th);
                sx = s;
                sy = s;
                break;
            }
            case ScaleMode::PROPORTIONAL_OUTSIDE: {
                float s = std::max(m_width / tw, m_height / th);
                sx = s;
                sy = s;
                break;
            }
            case ScaleMode::WIDTH_ONLY:
                sx = m_width / tw;
                sy = sx;
                break;
            case ScaleMode::HEIGHT_ONLY:
                sy = m_height / th;
                sx = sy;
                break;
            case ScaleMode::NONE:
                sx = 1.0f;
                sy = 1.0f;
                break;
        }

        target->setScale(sx, sy);

        float finalW = tw * sx;
        float finalH = th * sy;
        float posX = 0.0f;
        float posY = 0.0f;

        switch (m_hAlign) {
            case AlignMode::LEFT:
                posX = 0.0f;
                break;
            case AlignMode::CENTER:
                posX = (m_width - finalW) * 0.5f;
                break;
            case AlignMode::RIGHT:
                posX = m_width - finalW;
                break;
            default:
                break;
        }

        switch (m_vAlign) {
            case AlignMode::TOP:
                posY = 0.0f;
                break;
            case AlignMode::CENTER:
                posY = (m_height - finalH) * 0.5f;
                break;
            case AlignMode::BOTTOM:
                posY = m_height - finalH;
                break;
            default:
                break;
        }

        target->setPosition(posX, posY);
    }
}

}
