#ifndef STARBLAST_TITLE_STATE_H
#define STARBLAST_TITLE_STATE_H

#include "game_state.h"
#include <memory>

namespace starblast {

class SpriteRenderer;
class PadManager;
class TitlePak;

class TitleState : public IGameState {
public:
    TitleState(SpriteRenderer* renderer, PadManager* pad = nullptr);
    ~TitleState() override;

    void onEnter() override;
    void update(float dt) override;
    void render() override;
    void onExit() override;

private:
    enum class Phase {
        INTRO,
        IDLE,
        OUT_TITLE
    };

    SpriteRenderer* m_renderer;
    PadManager* m_pad;
    std::unique_ptr<TitlePak> m_titlePak;

    Phase m_phase;
    float m_animTime;
    float m_phaseTime;
    float m_scrollY;
    float m_fadeAlpha;
    float m_pressAlpha;
    float m_inputDelay;
};

}

#endif
