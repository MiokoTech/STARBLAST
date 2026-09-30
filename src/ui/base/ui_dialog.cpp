// Implementasi modal dialog, alert, konfirmasi, dan manajer pop-up game.
#include "ui_dialog.h"

namespace starblast {

UIDialog::UIDialog(float width, float height)
    : dialogWidth_(width), dialogHeight_(height) {
    backdrop_ = std::make_shared<UIBox>(1280.0f, 720.0f, 0x000000, 0.7f);
    backdrop_->setPosition(0.0f, 0.0f);
    addChild(backdrop_);

    float panelX = (1280.0f - dialogWidth_) * 0.5f;
    float panelY = (720.0f - dialogHeight_) * 0.5f;
    panel_ = std::make_shared<UIBox>(dialogWidth_, dialogHeight_, 0x111118, 0.95f, 0x334466, 2.0f);
    panel_->setPosition(panelX, panelY);
    addChild(panel_);
}

void UIDialog::setTitle(const std::string& title, std::shared_ptr<UIBitmapFont> font) {
    if (!font) return;
    if (titleText_) removeChild(titleText_);
    titleText_ = std::make_shared<UIText>(font, title);
    titleText_->setTextAlign(TextAlign::CENTER);
    titleText_->setPosition(panel_->getX() + dialogWidth_ * 0.5f, panel_->getY() + 20.0f);
    addChild(titleText_);
}

void UIDialog::setMessage(const std::string& msg, std::shared_ptr<UIBitmapFont> font) {
    if (!font) return;
    if (messageText_) removeChild(messageText_);
    messageText_ = std::make_shared<UIText>(font, msg);
    messageText_->setTextAlign(TextAlign::CENTER);
    messageText_->setPosition(panel_->getX() + dialogWidth_ * 0.5f, panel_->getY() + 80.0f);
    addChild(messageText_);
}

void UIDialog::setConfirmCallback(std::function<void()> cb) {
    onConfirm_ = std::move(cb);
}

void UIDialog::setCancelCallback(std::function<void()> cb) {
    onCancel_ = std::move(cb);
}

void UIDialog::show() {
    hiding_ = false;
    setVisible(true);
    setAlpha(0.0f);

    float targetY = (720.0f - dialogHeight_) * 0.5f;
    panel_->setPosition((1280.0f - dialogWidth_) * 0.5f, targetY + 30.0f);

    UITweenParams pAlpha = UITweenParams::makeAlpha(1.0f);
    UITween::to(shared_from_this(), 0.25f, pAlpha, Ease::QUAD_OUT);

    UITweenParams pPos = UITweenParams::makePos(panel_->getX(), targetY);
    UITween::to(panel_, 0.25f, pPos, Ease::BACK_OUT);
}

void UIDialog::close() {
    if (hiding_) return;
    hiding_ = true;

    UITweenParams pAlpha = UITweenParams::makeAlpha(0.0f);
    UITween::to(shared_from_this(), 0.2f, pAlpha, Ease::QUAD_IN, 0.0f, [this]() {
        UIDialogManager::getInstance().closeDialog(this);
    });
}

UIAlertDialog::UIAlertDialog(const std::string& title, const std::string& message, std::shared_ptr<UIBitmapFont> font,
                             std::function<void()> onOk, float width, float height)
    : UIDialog(width, height) {
    setTitle(title, font);
    setMessage(message, font);

    float btnW = 120.0f;
    float btnH = 44.0f;
    float btnX = panel_->getX() + (dialogWidth_ - btnW) * 0.5f;
    float btnY = panel_->getY() + dialogHeight_ - btnH - 24.0f;

    confirmBtn_ = std::make_shared<UIButton>(0, btnW, btnH);
    confirmBtn_->setPosition(btnX, btnY);
    confirmBtn_->setOnClick([this, onOk]() {
        if (onOk) onOk();
        close();
    });
    addChild(confirmBtn_);
}

UIConfirmDialog::UIConfirmDialog(const std::string& title, const std::string& message, std::shared_ptr<UIBitmapFont> font,
                                 std::function<void()> onYes, std::function<void()> onNo,
                                 float width, float height)
    : UIDialog(width, height) {
    setTitle(title, font);
    setMessage(message, font);

    float btnW = 120.0f;
    float btnH = 44.0f;
    float spacing = 40.0f;
    float totalW = btnW * 2.0f + spacing;
    float startX = panel_->getX() + (dialogWidth_ - totalW) * 0.5f;
    float btnY = panel_->getY() + dialogHeight_ - btnH - 24.0f;

    confirmBtn_ = std::make_shared<UIButton>(0, btnW, btnH);
    confirmBtn_->setPosition(startX, btnY);
    confirmBtn_->setOnClick([this, onYes]() {
        if (onYes) onYes();
        close();
    });
    addChild(confirmBtn_);

    cancelBtn_ = std::make_shared<UIButton>(0, btnW, btnH);
    cancelBtn_->setPosition(startX + btnW + spacing, btnY);
    cancelBtn_->setOnClick([this, onNo]() {
        if (onNo) onNo();
        close();
    });
    addChild(cancelBtn_);
}

UIDialogManager& UIDialogManager::getInstance() {
    static UIDialogManager instance;
    return instance;
}

void UIDialogManager::showDialog(std::shared_ptr<UIDialog> dialog) {
    if (!dialog) return;
    dialog->show();
    activeDialogs_.push_back(std::move(dialog));
}

void UIDialogManager::closeDialog(UIDialog* dialog) {
    for (auto it = activeDialogs_.begin(); it != activeDialogs_.end(); ++it) {
        if (it->get() == dialog) {
            activeDialogs_.erase(it);
            break;
        }
    }
}

void UIDialogManager::closeTopDialog() {
    if (!activeDialogs_.empty()) {
        activeDialogs_.back()->close();
    }
}

bool UIDialogManager::hasActiveDialog() const {
    return !activeDialogs_.empty();
}

void UIDialogManager::update(float dt) {
    for (auto& dlg : activeDialogs_) {
        dlg->update(dt);
    }
}

void UIDialogManager::render(SpriteRenderer* renderer) {
    for (auto& dlg : activeDialogs_) {
        dlg->render(renderer);
    }
}

bool UIDialogManager::handleTouch(float x, float y, bool down) {
    if (activeDialogs_.empty()) return false;
    return activeDialogs_.back()->handleTouch(x, y, down);
}

} // namespace starblast
