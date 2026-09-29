#include "splash_state.h"
#include "title_state.h"
#include "state_manager.h"
#include "sprite_renderer.h"
#include "pad_manager.h"
#include "splash_pak.h"
#include "texture_manager.h"

namespace starblast {

SplashState::SplashState(SpriteRenderer* renderer, PadManager* pad)
    : m_renderer(renderer)
    , m_pad(pad ? pad : &PadManager::getInstance())
    , m_animTime(0.0f)
    , m_currentFrame(0)
    , m_finished(false)
    , m_fadeAlpha(0.0f)
{
    m_splashPak = std::make_unique<SplashPak>();
}

SplashState::~SplashState() = default;

void SplashState::onEnter() {
    m_animTime = 0.0f;
    m_currentFrame = 0;
    m_finished = false;
    m_fadeAlpha = 0.0f;

    if (m_pad) {
        m_pad->setMode(PadMode::MENU);
    }

    m_splashPak->load("data/splash.pak", TextureManager::getInstance().getAssetManager());
}

void SplashState::update(float dt) {
    if (m_finished) {
        m_fadeAlpha += dt * 3.0f;
        if (m_fadeAlpha >= 1.0f) {
            StateManager::getInstance().changeState(std::make_shared<TitleState>(m_renderer, m_pad));
        }
        return;
    }

    m_animTime += dt;
    m_currentFrame = static_cast<int>(m_animTime * 30.0f);

    if (m_pad && (m_pad->isTouched() || m_pad->getMask() != 0) && m_animTime > 0.3f) {
        m_finished = true;
    }

    if (m_currentFrame >= m_splashPak->getTotalFrames() || m_currentFrame >= 151) {
        m_finished = true;
    }
}

void SplashState::render() {
    if (!m_renderer) return;

    m_renderer->begin();

    m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, 1.0f);

    if (m_splashPak) {
        GLuint tex = m_splashPak->getTextureForFrame(m_currentFrame);
        if (tex != 0) {
            m_renderer->drawSprite(
                tex,
                0, 0,
                0, 0, 1280, 720,
                1280, 720,
                0, 0,
                1,
                1.0f, 1.0f,
                1.0f, 1.0f, 1.0f, 1.0f
            );
        }
    }

    if (m_fadeAlpha > 0.0f) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_fadeAlpha);
    }

    m_renderer->end();
}

void SplashState::onExit() {
    if (m_splashPak) {
        m_splashPak->release();
    }
}

}
