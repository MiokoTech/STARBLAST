// Sistem modal dialog, alert, konfirmasi, dan manajer pop-up game.
#pragma once

#include "ui_node.h"
#include "ui_box.h"
#include "ui_text.h"
#include "ui_button.h"
#include "ui_tween.h"
#include "ui_bitmap_font.h"
#include <functional>
#include <memory>
#include <vector>
#include <string>

namespace starblast {

class UIDialog : public UINode {
public:
    UIDialog(float width = 600.0f, float height = 300.0f);
    virtual ~UIDialog() = default;

    void setTitle(const std::string& title, std::shared_ptr<UIBitmapFont> font);
    void setMessage(const std::string& msg, std::shared_ptr<UIBitmapFont> font);
    void setConfirmCallback(std::function<void()> cb);
    void setCancelCallback(std::function<void()> cb);

    virtual void show();
    virtual void close();

    bool isHiding() const { return hiding_; }

protected:
    float dialogWidth_{600.0f};
    float dialogHeight_{300.0f};
    bool hiding_{false};

    std::shared_ptr<UIBox> backdrop_;
    std::shared_ptr<UIBox> panel_;
    std::shared_ptr<UIText> titleText_;
    std::shared_ptr<UIText> messageText_;
    std::shared_ptr<UIButton> confirmBtn_;
    std::shared_ptr<UIButton> cancelBtn_;

    std::function<void()> onConfirm_;
    std::function<void()> onCancel_;
};

class UIAlertDialog : public UIDialog {
public:
    UIAlertDialog(const std::string& title, const std::string& message, std::shared_ptr<UIBitmapFont> font,
                  std::function<void()> onOk = nullptr, float width = 560.0f, float height = 260.0f);
};

class UIConfirmDialog : public UIDialog {
public:
    UIConfirmDialog(const std::string& title, const std::string& message, std::shared_ptr<UIBitmapFont> font,
                    std::function<void()> onYes = nullptr, std::function<void()> onNo = nullptr,
                    float width = 600.0f, float height = 280.0f);
};

class UIDialogManager {
public:
    static UIDialogManager& getInstance();

    void showDialog(std::shared_ptr<UIDialog> dialog);
    void closeDialog(UIDialog* dialog);
    void closeTopDialog();
    bool hasActiveDialog() const;

    void update(float dt);
    void render(SpriteRenderer* renderer);
    bool handleTouch(float x, float y, bool down);

private:
    UIDialogManager() = default;
    std::vector<std::shared_ptr<UIDialog>> activeDialogs_;
};

} // namespace starblast
