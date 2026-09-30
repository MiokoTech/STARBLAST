// Mesin interpolasi animasi tween elemen antarmuka game.
#ifndef STARBLAST_UI_TWEEN_H
#define STARBLAST_UI_TWEEN_H

#include <memory>
#include <vector>
#include <string>
#include <functional>

namespace starblast {

class UINode;

enum class Ease {
    LINEAR,
    QUAD_IN,
    QUAD_OUT,
    QUAD_IN_OUT,
    CUBIC_IN,
    CUBIC_OUT,
    CUBIC_IN_OUT,
    BACK_IN,
    BACK_OUT,
    BACK_IN_OUT,
    BOUNCE_IN,
    BOUNCE_OUT,
    BOUNCE_IN_OUT,
    ELASTIC_IN,
    ELASTIC_OUT,
    ELASTIC_IN_OUT,
    EXPO_IN,
    EXPO_OUT,
    EXPO_IN_OUT,
    SINE_IN,
    SINE_OUT,
    SINE_IN_OUT
};

struct UITweenParams {
    float x = 0.0f;
    float y = 0.0f;
    float scaleX = 1.0f;
    float scaleY = 1.0f;
    float alpha = 1.0f;

    bool hasX = false;
    bool hasY = false;
    bool hasScaleX = false;
    bool hasScaleY = false;
    bool hasAlpha = false;

    static UITweenParams makePos(float tx, float ty) {
        UITweenParams p;
        p.x = tx; p.y = ty; p.hasX = true; p.hasY = true;
        return p;
    }

    static UITweenParams makeScale(float sx, float sy) {
        UITweenParams p;
        p.scaleX = sx; p.scaleY = sy; p.hasScaleX = true; p.hasScaleY = true;
        return p;
    }

    static UITweenParams makeAlpha(float a) {
        UITweenParams p;
        p.alpha = a; p.hasAlpha = true;
        return p;
    }
};

class UITween {
public:
    static void to(
        std::shared_ptr<UINode> node,
        float duration,
        const UITweenParams& params,
        Ease ease = Ease::QUAD_OUT,
        float delay = 0.0f,
        std::function<void()> onComplete = nullptr
    );

    static void delayedCall(float delay, std::function<void()> callback);
    static void setInterval(float interval, std::function<bool()> callback);
    static std::string formatTime(int totalSeconds, bool includeMinutes = true);
    static void update(float dt);
    static void killTweensOf(const UINode* node);
    static void clear();

private:
    struct TweenItem {
        std::weak_ptr<UINode> node;
        float duration;
        float elapsed;
        float delay;
        Ease ease;

        float startX, targetX;
        bool hasX;

        float startY, targetY;
        bool hasY;

        float startScaleX, targetScaleX;
        bool hasScaleX;

        float startScaleY, targetScaleY;
        bool hasScaleY;

        float startAlpha, targetAlpha;
        bool hasAlpha;

        std::function<void()> onComplete;
        std::function<bool()> intervalCallback;
        bool started;
        bool isDelayedCall;
        bool isInterval;
    };

    static std::vector<TweenItem> s_tweens;
    static float evaluateEase(Ease ease, float t);
};

class UITimeline {
public:
    UITimeline() : m_totalDuration(0.0f) {}

    UITimeline& append(
        std::shared_ptr<UINode> node,
        float duration,
        const UITweenParams& params,
        Ease ease = Ease::QUAD_OUT,
        float offset = 0.0f
    ) {
        float startTime = m_totalDuration + offset;
        m_steps.push_back({ node, duration, params, ease, startTime });
        m_totalDuration = std::max(m_totalDuration, startTime + duration);
        return *this;
    }

    UITimeline& appendCallback(float offset, std::function<void()> callback) {
        float startTime = m_totalDuration + offset;
        m_callbacks.push_back({ startTime, std::move(callback) });
        m_totalDuration = std::max(m_totalDuration, startTime);
        return *this;
    }

    void play(std::function<void()> onAllComplete = nullptr) {
        for (const auto& step : m_steps) {
            UITween::to(step.node, step.duration, step.params, step.ease, step.startTime);
        }
        for (const auto& cb : m_callbacks) {
            UITween::delayedCall(cb.time, cb.callback);
        }
        if (onAllComplete) {
            UITween::delayedCall(m_totalDuration, std::move(onAllComplete));
        }
    }

    float getTotalDuration() const { return m_totalDuration; }

private:
    struct Step {
        std::shared_ptr<UINode> node;
        float duration;
        UITweenParams params;
        Ease ease;
        float startTime;
    };
    struct CallbackStep {
        float time;
        std::function<void()> callback;
    };
    std::vector<Step> m_steps;
    std::vector<CallbackStep> m_callbacks;
    float m_totalDuration;
};

}

#endif
