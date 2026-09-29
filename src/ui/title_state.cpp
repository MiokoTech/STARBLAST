#include "title_state.h"
#include "menu_state.h"
#include "state_manager.h"
#include "sprite_renderer.h"
#include "pad_manager.h"
#include "audio_engine.h"
#include "texture_manager.h"
#include "title_pak.h"
#include <cmath>

namespace starblast {

TitleState::TitleState(SpriteRenderer* renderer, PadManager* pad)
    : m_renderer(renderer)
    , m_pad(pad ? pad : &PadManager::getInstance())
    , m_phase(Phase::INTRO)
    , m_animTime(0.0f)
    , m_phaseTime(0.0f)
    , m_scrollY(-700.0f)
    , m_fadeAlpha(1.0f)
    , m_pressAlpha(0.0f)
    , m_inputDelay(0.5f)
{
    m_titlePak = std::make_unique<TitlePak>();
}

TitleState::~TitleState() = default;

void TitleState::onEnter() {
    m_phase = Phase::INTRO;
    m_animTime = 0.0f;
    m_phaseTime = 0.0f;
    m_scrollY = -700.0f;
    m_fadeAlpha = 1.0f;
    m_pressAlpha = 0.0f;
    m_inputDelay = 0.5f;

    if (m_pad) {
        m_pad->setMode(PadMode::MENU);
    }

    m_titlePak->load("data/title.pak", TextureManager::getInstance().getAssetManager());
    AudioEngine::getInstance().playBgm("sound/loading.ogg", true);
}

void TitleState::update(float dt) {
    m_animTime += dt;
    m_phaseTime += dt;

    if (m_inputDelay > 0.0f) {
        m_inputDelay -= dt;
    }

    m_scrollY -= 2.0f * (dt * 60.0f);
    if (m_scrollY < -2555.0f) {
        m_scrollY += 2555.0f;
    }

    switch (m_phase) {
        case Phase::INTRO: {
            m_fadeAlpha -= dt * 2.5f;
            if (m_fadeAlpha <= 0.0f) {
                m_fadeAlpha = 0.0f;
                m_phase = Phase::IDLE;
                m_phaseTime = 0.0f;
            }
            break;
        }

        case Phase::IDLE: {
            m_fadeAlpha = 0.0f;
            m_pressAlpha = 0.35f + 0.65f * (0.5f + 0.5f * std::sin(m_animTime * 4.5f));

            if (m_inputDelay <= 0.0f && m_pad && (m_pad->isTouched() || m_pad->getMask() != 0)) {
                m_phase = Phase::OUT_TITLE;
                m_phaseTime = 0.0f;
                m_fadeAlpha = 0.0f;
            }
            break;
        }

        case Phase::OUT_TITLE: {
            m_fadeAlpha += dt * 1.5f;
            if (m_fadeAlpha > 1.0f) {
                m_fadeAlpha = 1.0f;
            }

            if (m_phaseTime >= 1.2f) {
                StateManager::getInstance().changeState(std::make_shared<MenuState>(m_renderer, m_pad));
            }
            break;
        }
    }
}

void TitleState::render() {
    if (!m_renderer) return;

    m_renderer->begin();

    if (m_titlePak && m_titlePak->getNumLayers() >= 8) {

        GLuint tex0 = m_titlePak->getTexture(0);
        if (tex0 != 0) {
            m_renderer->drawSprite(tex0, 0.0f, 0.0f, 0, 0, 1280, 720, 1280, 720, 0, 0, 1);
        }

        GLuint tex1 = m_titlePak->getTexture(1);
        if (tex1 != 0) {
            float sy = m_scrollY;
            while (sy > 0.0f) sy -= 2555.0f;
            while (sy < 720.0f) {
                m_renderer->drawSprite(tex1, 0.0f, sy, 0, 0, 1280, 2555, 1280, 2555, 0, 0, 1);
                sy += 2555.0f;
            }
        }

        GLuint tex2 = m_titlePak->getTexture(2);
        if (tex2 != 0) {
            m_renderer->drawSprite(tex2, 0.0f, 0.0f, 0, 0, 1280, 720, 1280, 720, 0, 0, 1);
        }

        GLuint tex3 = m_titlePak->getTexture(3);
        if (tex3 != 0) {
            m_renderer->drawSprite(tex3, 0.0f, 0.0f, 0, 0, 1280, 720, 1280, 720, 0, 0, 1);
        }

        GLuint tex4 = m_titlePak->getTexture(4);
        if (tex4 != 0) {
            m_renderer->drawSprite(tex4, 0.0f, 0.0f, 0, 0, 1280, 720, 1280, 720, 0, 0, 1);
        }

        GLuint tex5 = m_titlePak->getTexture(5);
        if (tex5 != 0) {
            m_renderer->drawSprite(tex5, 0.0f, 0.0f, 0, 0, 1280, 720, 1280, 720, 0, 0, 1);
        }

        const auto* l6 = m_titlePak->getLayer(6);
        GLuint tex6 = m_titlePak->getTexture(6);
        if (tex6 != 0 && l6 && l6->srcW > 0 && l6->srcH > 0) {
            float sx = l6->dstW / static_cast<float>(l6->srcW);
            float sy = l6->dstH / static_cast<float>(l6->srcH);
            float alpha = (m_phase == Phase::INTRO) ? 0.0f : m_pressAlpha;
            m_renderer->drawSprite(
                tex6,
                l6->posX, l6->posY,
                0, 0, l6->srcW, l6->srcH,
                l6->srcW, l6->srcH,
                0, 0, 1,
                sx, sy,
                1.0f, 1.0f, 1.0f, alpha
            );
        }

        const auto* l7 = m_titlePak->getLayer(7);
        GLuint tex7 = m_titlePak->getTexture(7);
        if (tex7 != 0 && l7 && l7->srcW > 0 && l7->srcH > 0) {
            float sx = l7->dstW / static_cast<float>(l7->srcW);
            float sy = l7->dstH / static_cast<float>(l7->srcH);
            m_renderer->drawSprite(
                tex7,
                l7->posX, l7->posY,
                0, 0, l7->srcW, l7->srcH,
                l7->srcW, l7->srcH,
                0, 0, 1,
                sx, sy,
                1.0f, 1.0f, 1.0f, 0.85f
            );
        }
    } else {
        m_renderer->drawRect(0, 0, 1280, 720, 0.04f, 0.06f, 0.12f, 1.0f);
    }

    if (m_fadeAlpha > 0.001f) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_fadeAlpha);
    }

    m_renderer->end();
}

void TitleState::onExit() {
    if (m_titlePak) {
        m_titlePak->release();
    }
}

}
