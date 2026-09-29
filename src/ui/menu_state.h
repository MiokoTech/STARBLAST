#ifndef STARBLAST_MENU_STATE_H
#define STARBLAST_MENU_STATE_H

#include "game_state.h"
#include <GLES3/gl3.h>
#include <memory>
#include <vector>
#include <string>

namespace starblast {

class SpriteRenderer;
class PadManager;
class MenuPak;

struct SubmenuItem {
    std::string title;
    std::string subtitle;
    int gameMode;
};

class MenuState : public IGameState {
public:
    MenuState(SpriteRenderer* renderer, PadManager* pad = nullptr);
    ~MenuState() override;

    void onEnter() override;
    void update(float dt) override;
    void render() override;
    void onExit() override;

private:
    void setMode(int newMode, bool isDown);
    void confirmSelection();
    void goBack();

    void loadOptionsConfig();
    void saveOptionsConfig();

    void openSubmenu(int mode);
    void closeSubmenu();
    void confirmSubmenu();

    void openOptions();
    void closeOptions();

    void openCredits();
    void closeCredits();

    void openExitDialog();
    void closeExitDialog();

    SpriteRenderer* m_renderer;
    PadManager* m_pad;
    std::unique_ptr<MenuPak> m_menuPak;

    int m_curMode;
    int m_prevMode;

    float m_animTime;
    float m_inputCooldown;
    uint32_t m_lastMask;
    bool m_lastTouched;

    float m_titleBreathTimer;
    float m_arrowFloatTimer;
    float m_arrowUpScale;
    float m_arrowDnScale;

    float m_titleSlideY;
    float m_titleAlpha;
    float m_prevTitleSlideY;
    float m_prevTitleAlpha;

    float m_previewSlideX;
    float m_previewAlpha;
    float m_prevPreviewAlpha;

    bool m_inSubmenu;
    int m_subCursor;
    float m_subSlideX;
    float m_subAlpha;
    std::vector<SubmenuItem> m_subItems;

    bool m_inOptions;
    int m_optCursor;
    float m_optAlpha;
    float m_bgmVol;
    float m_sfxVol;
    int m_difficulty;
    int m_fightTime;
    int m_rounds;

    bool m_inCredits;
    float m_creditsAlpha;

    bool m_inExitDialog;
    int m_exitCursor;
    float m_exitAlpha;
    bool m_transitioning;
    bool m_transitionToTitle;
    int m_targetGameMode;
    float m_fadeAlpha;
};

}

#endif
