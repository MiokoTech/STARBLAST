// Pengelola efek pudar layar dan kilatan transisi antarmuka.
#ifndef STARBLAST_UI_FADE_EFFECT_H
#define STARBLAST_UI_FADE_EFFECT_H

#include <functional>

namespace starblast {

class SpriteRenderer;

enum class FadeMode {
    NONE,
    FADE_IN,
    FADE_OUT,
    FLASH,
    SEQUENCE
};

class UIFadeEffect {
public:
    static UIFadeEffect& getInstance();

    void update(float dt);
    void render(SpriteRenderer* renderer);

    void fadeIn(float duration = 0.35f, std::function<void()> onComplete = nullptr);
    void fadeOut(float duration = 0.35f, std::function<void()> onComplete = nullptr);
    void flash(float r, float g, float b, float duration = 0.2f, std::function<void()> onComplete = nullptr);
    void fadeSequence(float outDuration, float inDuration, std::function<void()> onMidpoint = nullptr, std::function<void()> onComplete = nullptr);

    void setColor(float r, float g, float b);
    void setAlpha(float a);
    float getAlpha() const { return m_currentAlpha; }
    bool isFading() const { return m_mode != FadeMode::NONE; }
    void stop();

private:
    UIFadeEffect();
    ~UIFadeEffect() = default;
    UIFadeEffect(const UIFadeEffect&) = delete;
    UIFadeEffect& operator=(const UIFadeEffect&) = delete;

    FadeMode m_mode;
    float m_colorR;
    float m_colorG;
    float m_colorB;
    float m_startAlpha;
    float m_targetAlpha;
    float m_currentAlpha;
    float m_duration;
    float m_elapsed;

    float m_seqInDuration;
    bool m_seqIsFirstHalf;
    std::function<void()> m_midpointCallback;
    std::function<void()> m_completeCallback;
};

}

#endif
