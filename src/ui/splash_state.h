#ifndef STARBLAST_SPLASH_STATE_H
#define STARBLAST_SPLASH_STATE_H

#include "game_state.h"
#include <memory>

namespace starblast {

class SpriteRenderer;
class PadManager;
class SplashPak;

class SplashState : public IGameState {
public:
    SplashState(SpriteRenderer* renderer, PadManager* pad = nullptr);
    ~SplashState() override;

    void onEnter() override;
    void update(float dt) override;
    void render() override;
    void onExit() override;

private:
    SpriteRenderer* m_renderer;
    PadManager* m_pad;
    std::unique_ptr<SplashPak> m_splashPak;

    float m_animTime;
    int m_currentFrame;
    bool m_finished;
    float m_fadeAlpha;
};

}

#endif
