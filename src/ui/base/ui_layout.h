// Pengatur tata letak linier horizontal, vertikal, dan area penyesuaian otomatis.
#ifndef STARBLAST_UI_LAYOUT_H
#define STARBLAST_UI_LAYOUT_H

#include "ui_node.h"
#include <memory>
#include <vector>

namespace starblast {

enum class UIAlign {
    START,
    CENTER,
    END
};

enum class ScaleMode {
    STRETCH,
    PROPORTIONAL_INSIDE,
    PROPORTIONAL_OUTSIDE,
    WIDTH_ONLY,
    HEIGHT_ONLY,
    NONE
};

enum class AlignMode {
    LEFT,
    CENTER,
    RIGHT,
    TOP,
    BOTTOM
};

class UIHBox : public UINode {
public:
    explicit UIHBox(float spacing = 0.0f, UIAlign align = UIAlign::START);
    ~UIHBox() override = default;

    void setSpacing(float spacing) { m_spacing = spacing; relayout(); }
    float getSpacing() const { return m_spacing; }

    void setAlignment(UIAlign align) { m_align = align; relayout(); }
    UIAlign getAlignment() const { return m_align; }

    void relayout();

private:
    float m_spacing;
    UIAlign m_align;
};

class UIVBox : public UINode {
public:
    explicit UIVBox(float spacing = 0.0f, UIAlign align = UIAlign::START);
    ~UIVBox() override = default;

    void setSpacing(float spacing) { m_spacing = spacing; relayout(); }
    float getSpacing() const { return m_spacing; }

    void setAlignment(UIAlign align) { m_align = align; relayout(); }
    UIAlign getAlignment() const { return m_align; }

    void relayout();

private:
    float m_spacing;
    UIAlign m_align;
};

class UIAutoFitArea : public UINode {
public:
    UIAutoFitArea(float x, float y, float width, float height,
                  ScaleMode scaleMode = ScaleMode::PROPORTIONAL_INSIDE,
                  AlignMode hAlign = AlignMode::CENTER,
                  AlignMode vAlign = AlignMode::CENTER);
    ~UIAutoFitArea() override = default;

    void setScaleMode(ScaleMode mode) { m_scaleMode = mode; fit(); }
    void setHAlign(AlignMode align) { m_hAlign = align; fit(); }
    void setVAlign(AlignMode align) { m_vAlign = align; fit(); }

    void attach(std::shared_ptr<UINode> target);
    void detach(std::shared_ptr<UINode> target);
    void fit();

private:
    ScaleMode m_scaleMode;
    AlignMode m_hAlign;
    AlignMode m_vAlign;
    std::vector<std::shared_ptr<UINode>> m_attached;
};

}

#endif
