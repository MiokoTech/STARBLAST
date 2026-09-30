// Komponen tombol menu dan grup navigasi antarmuka bertingkat.
#pragma once

#include "ui_node.h"
#include "ui_box.h"
#include "ui_text.h"
#include "ui_tween.h"
#include "ui_bitmap_font.h"
#include <string>
#include <vector>
#include <memory>
#include <functional>

namespace starblast {

class UIMenuBtn : public UINode {
public:
    UIMenuBtn(const std::string& label, std::shared_ptr<UIBitmapFont> font, std::function<void()> clickFunc = nullptr);
    ~UIMenuBtn() override = default;

    const std::string& getLabel() const { return m_label; }
    void addChildBtn(std::shared_ptr<UIMenuBtn> child);
    const std::vector<std::shared_ptr<UIMenuBtn>>& getChildButtons() const { return m_childrenBtns; }
    bool hasChildren() const { return !m_childrenBtns.empty(); }

    void hover();
    void normal();
    void select();

    void openChild();
    void closeChild();
    bool isOpen() const { return m_isOpen; }

    void setTopLevelMode(bool topLevel);
    bool isTopLevel() const { return m_isTopLevel; }

    void setClickCallback(std::function<void()> cb) { m_func = std::move(cb); }
    void render(SpriteRenderer* renderer) override;
    bool handleTouch(float tx, float ty, bool isDown) override;

private:
    std::string m_label;
    std::shared_ptr<UIBitmapFont> m_font;
    std::shared_ptr<UIText> m_text;
    std::shared_ptr<UIBox> m_highlightBg;
    std::vector<std::shared_ptr<UIMenuBtn>> m_childrenBtns;
    std::function<void()> m_func;
    bool m_isTopLevel{false};
    bool m_isOpen{false};
    bool m_isHovered{false};
};

class UIMenuGroup : public UINode {
public:
    UIMenuGroup();
    ~UIMenuGroup() override = default;

    void addButton(std::shared_ptr<UIMenuBtn> btn);
    void clearButtons();

    void prev();
    void next();
    void selectCurrent();
    void back();

    void hoverIndex(int index);
    int getCurrentIndex() const { return m_currentIndex; }
    std::shared_ptr<UIMenuBtn> getCurrentButton() const;

    void layoutVertical(float startX, float startY, float gapY = 50.0f);
    void fadeIn(float duration = 0.4f, float itemDelay = 0.05f);

    void setOnHoverChange(std::function<void(int index, UIMenuBtn* btn)> cb) { m_onHoverChange = std::move(cb); }
    void setOnBack(std::function<void()> cb) { m_onBack = std::move(cb); }

    void update(float dt) override;
    void render(SpriteRenderer* renderer) override;
    bool handleTouch(float tx, float ty, bool isDown) override;

private:
    void toggleChildren(std::shared_ptr<UIMenuBtn> btn);
    void closeChildren();

    std::vector<std::shared_ptr<UIMenuBtn>> m_buttons;
    std::shared_ptr<UIMenuBtn> m_showingChildBtn;
    int m_currentIndex{0};
    bool m_enabled{true};

    std::function<void(int index, UIMenuBtn* btn)> m_onHoverChange;
    std::function<void()> m_onBack;
};

} // namespace starblast
