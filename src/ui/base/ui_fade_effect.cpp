// Implementasi animasi transisi layar dan kilatan visual.
#include "ui_fade_effect.h"
#include "../../render/sprite_renderer.h"
#include <algorithm>

namespace starblast {

UIFadeEffect& UIFadeEffect::getInstance() {
    static UIFadeEffect instance;
    return instance;
}

UIFadeEffect::UIFadeEffect()
    : m_mode(FadeMode::NONE)
    , m_colorR(0.0f)
    , m_colorG(0.0f)
    , m_colorB(0.0f)
    , m_startAlpha(0.0f)
    , m_targetAlpha(0.0f)
    , m_currentAlpha(0.0f)
    , m_duration(0.0f)
    , m_elapsed(0.0f)
    , m_seqInDuration(0.0f)
    , m_seqIsFirstHalf(false)
    , m_midpointCallback(nullptr)
    , m_completeCallback(nullptr) {
}

void UIFadeEffect::fadeIn(float duration, std::function<void()> onComplete) {
    m_mode = FadeMode::FADE_IN;
    m_colorR = 0.0f;
    m_colorG = 0.0f;
    m_colorB = 0.0f;
    m_startAlpha = m_currentAlpha;
    m_targetAlpha = 1.0f;
    m_duration = duration > 0.0f ? duration : 0.001f;
    m_elapsed = 0.0f;
    m_completeCallback = onComplete;
}

void UIFadeEffect::fadeOut(float duration, std::function<void()> onComplete) {
    m_mode = FadeMode::FADE_OUT;
    m_colorR = 0.0f;
    m_colorG = 0.0f;
    m_colorB = 0.0f;
    m_startAlpha = (m_currentAlpha > 0.0f) ? m_currentAlpha : 1.0f;
    m_targetAlpha = 0.0f;
    m_currentAlpha = m_startAlpha;
    m_duration = duration > 0.0f ? duration : 0.001f;
    m_elapsed = 0.0f;
    m_completeCallback = onComplete;
}

void UIFadeEffect::flash(float r, float g, float b, float duration, std::function<void()> onComplete) {
    m_mode = FadeMode::FLASH;
    m_colorR = r;
    m_colorG = g;
    m_colorB = b;
    m_startAlpha = 1.0f;
    m_targetAlpha = 0.0f;
    m_currentAlpha = 1.0f;
    m_duration = duration > 0.0f ? duration : 0.001f;
    m_elapsed = 0.0f;
    m_completeCallback = onComplete;
}

void UIFadeEffect::fadeSequence(float outDuration, float inDuration, std::function<void()> onMidpoint, std::function<void()> onComplete) {
    m_mode = FadeMode::SEQUENCE;
    m_colorR = 0.0f;
    m_colorG = 0.0f;
    m_colorB = 0.0f;
    m_startAlpha = m_currentAlpha;
    m_targetAlpha = 1.0f;
    m_duration = outDuration > 0.0f ? outDuration : 0.001f;
    m_seqInDuration = inDuration > 0.0f ? inDuration : 0.001f;
    m_elapsed = 0.0f;
    m_seqIsFirstHalf = true;
    m_midpointCallback = onMidpoint;
    m_completeCallback = onComplete;
}

void UIFadeEffect::setColor(float r, float g, float b) {
    m_colorR = r;
    m_colorG = g;
    m_colorB = b;
}

void UIFadeEffect::setAlpha(float a) {
    m_currentAlpha = std::clamp(a, 0.0f, 1.0f);
}

void UIFadeEffect::stop() {
    m_mode = FadeMode::NONE;
    m_elapsed = 0.0f;
    m_duration = 0.0f;
    m_midpointCallback = nullptr;
    m_completeCallback = nullptr;
}

void UIFadeEffect::update(float dt) {
    if (m_mode == FadeMode::NONE) {
        return;
    }

    m_elapsed += dt;
    float t = m_duration > 0.0f ? (m_elapsed / m_duration) : 1.0f;

    if (t >= 1.0f) {
        m_currentAlpha = m_targetAlpha;

        if (m_mode == FadeMode::SEQUENCE && m_seqIsFirstHalf) {
            m_seqIsFirstHalf = false;
            if (m_midpointCallback) {
                m_midpointCallback();
            }
            m_startAlpha = 1.0f;
            m_targetAlpha = 0.0f;
            m_elapsed = 0.0f;
            m_duration = m_seqInDuration;
            return;
        }

        auto cb = m_completeCallback;
        stop();
        if (cb) {
            cb();
        }
    } else {
        m_currentAlpha = m_startAlpha + (m_targetAlpha - m_startAlpha) * t;
    }
}

void UIFadeEffect::render(SpriteRenderer* renderer) {
    if (m_currentAlpha <= 0.001f || !renderer) {
        return;
    }

    renderer->drawRect(0.0f, 0.0f, 1280.0f, 720.0f, m_colorR, m_colorG, m_colorB, m_currentAlpha);
}

}
