// Implementasi mesin interpolasi animasi tween antarmuka.
#include "ui_tween.h"
#include "ui_node.h"
#include <cmath>
#include <algorithm>
#include <string>
#include <cstdio>

namespace starblast {

std::vector<UITween::TweenItem> UITween::s_tweens;

void UITween::to(
    std::shared_ptr<UINode> node,
    float duration,
    const UITweenParams& params,
    Ease ease,
    float delay,
    std::function<void()> onComplete
) {
    if (!node || duration <= 0.0f) {
        if (node) {
            if (params.hasX) node->setX(params.x);
            if (params.hasY) node->setY(params.y);
            if (params.hasScaleX) node->setScale(params.scaleX, node->getScaleY());
            if (params.hasScaleY) node->setScale(node->getScaleX(), params.scaleY);
            if (params.hasAlpha) node->setAlpha(params.alpha);
        }
        if (onComplete) onComplete();
        return;
    }

    killTweensOf(node.get());

    TweenItem item;
    item.node = node;
    item.duration = duration;
    item.elapsed = 0.0f;
    item.delay = delay;
    item.ease = ease;
    item.started = false;
    item.isDelayedCall = false;
    item.isInterval = false;

    item.startX = node->getX();
    item.targetX = params.x;
    item.hasX = params.hasX;

    item.startY = node->getY();
    item.targetY = params.y;
    item.hasY = params.hasY;

    item.startScaleX = node->getScaleX();
    item.targetScaleX = params.scaleX;
    item.hasScaleX = params.hasScaleX;

    item.startScaleY = node->getScaleY();
    item.targetScaleY = params.scaleY;
    item.hasScaleY = params.hasScaleY;

    item.startAlpha = node->getAlpha();
    item.targetAlpha = params.alpha;
    item.hasAlpha = params.hasAlpha;

    item.onComplete = std::move(onComplete);

    s_tweens.push_back(std::move(item));
}

void UITween::delayedCall(float delay, std::function<void()> callback) {
    if (delay <= 0.0f) {
        if (callback) callback();
        return;
    }

    TweenItem item;
    item.duration = delay;
    item.elapsed = 0.0f;
    item.delay = 0.0f;
    item.ease = Ease::LINEAR;
    item.started = true;
    item.isDelayedCall = true;
    item.isInterval = false;
    item.hasX = false;
    item.hasY = false;
    item.hasScaleX = false;
    item.hasScaleY = false;
    item.hasAlpha = false;
    item.onComplete = std::move(callback);

    s_tweens.push_back(std::move(item));
}

void UITween::setInterval(float interval, std::function<bool()> callback) {
    if (interval <= 0.0f || !callback) return;

    TweenItem item;
    item.duration = interval;
    item.elapsed = 0.0f;
    item.delay = 0.0f;
    item.ease = Ease::LINEAR;
    item.started = true;
    item.isDelayedCall = false;
    item.isInterval = true;
    item.hasX = false;
    item.hasY = false;
    item.hasScaleX = false;
    item.hasScaleY = false;
    item.hasAlpha = false;
    item.intervalCallback = std::move(callback);

    s_tweens.push_back(std::move(item));
}

std::string UITween::formatTime(int totalSeconds, bool includeMinutes) {
    if (totalSeconds < 0) totalSeconds = 0;
    char buf[16];
    if (includeMinutes) {
        int m = totalSeconds / 60;
        int s = totalSeconds % 60;
        snprintf(buf, sizeof(buf), "%02d:%02d", m, s);
    } else {
        snprintf(buf, sizeof(buf), "%02d", totalSeconds);
    }
    return std::string(buf);
}

void UITween::killTweensOf(const UINode* node) {
    if (!node) return;
    s_tweens.erase(
        std::remove_if(s_tweens.begin(), s_tweens.end(), [node](const TweenItem& item) {
            if (item.isDelayedCall || item.isInterval) return false;
            auto sp = item.node.lock();
            return !sp || sp.get() == node;
        }),
        s_tweens.end()
    );
}

void UITween::clear() {
    s_tweens.clear();
}

static float bounceOut(float p) {
    if (p < (1.0f / 2.75f)) {
        return 7.5625f * p * p;
    } else if (p < (2.0f / 2.75f)) {
        float p2 = p - (1.5f / 2.75f);
        return 7.5625f * p2 * p2 + 0.75f;
    } else if (p < (2.5f / 2.75f)) {
        float p2 = p - (2.25f / 2.75f);
        return 7.5625f * p2 * p2 + 0.9375f;
    } else {
        float p2 = p - (2.625f / 2.75f);
        return 7.5625f * p2 * p2 + 0.984375f;
    }
}

static float bounceIn(float p) {
    return 1.0f - bounceOut(1.0f - p);
}

static float bounceInOut(float p) {
    if (p < 0.5f) {
        return bounceIn(p * 2.0f) * 0.5f;
    }
    return bounceOut(p * 2.0f - 1.0f) * 0.5f + 0.5f;
}

static float elasticOut(float p) {
    if (p <= 0.0f) return 0.0f;
    if (p >= 1.0f) return 1.0f;
    constexpr float p2 = 0.3f;
    constexpr float pi2 = 6.28318530718f;
    constexpr float s = p2 / 4.0f;
    return std::pow(2.0f, -10.0f * p) * std::sin((p - s) * pi2 / p2) + 1.0f;
}

static float elasticIn(float p) {
    if (p <= 0.0f) return 0.0f;
    if (p >= 1.0f) return 1.0f;
    constexpr float p2 = 0.3f;
    constexpr float pi2 = 6.28318530718f;
    constexpr float s = p2 / 4.0f;
    float p1 = p - 1.0f;
    return -(std::pow(2.0f, 10.0f * p1) * std::sin((p1 - s) * pi2 / p2));
}

static float elasticInOut(float p) {
    if (p < 0.5f) {
        return elasticIn(p * 2.0f) * 0.5f;
    }
    return elasticOut(p * 2.0f - 1.0f) * 0.5f + 0.5f;
}

float UITween::evaluateEase(Ease ease, float t) {
    t = std::max(0.0f, std::min(1.0f, t));
    switch (ease) {
        case Ease::LINEAR:
            return t;
        case Ease::QUAD_IN:
            return t * t;
        case Ease::QUAD_OUT:
            return t * (2.0f - t);
        case Ease::QUAD_IN_OUT:
            return (t < 0.5f) ? (2.0f * t * t) : (-1.0f + (4.0f - 2.0f * t) * t);
        case Ease::CUBIC_IN:
            return t * t * t;
        case Ease::CUBIC_OUT: {
            float t1 = t - 1.0f;
            return t1 * t1 * t1 + 1.0f;
        }
        case Ease::CUBIC_IN_OUT:
            return (t < 0.5f) ? (4.0f * t * t * t) : (0.5f * std::pow(2.0f * t - 2.0f, 3.0f) + 1.0f);
        case Ease::BACK_IN: {
            float s = 1.70158f;
            return t * t * ((s + 1.0f) * t - s);
        }
        case Ease::BACK_OUT: {
            float s = 1.70158f;
            float t1 = t - 1.0f;
            return (t1 * t1 * ((s + 1.0f) * t1 + s) + 1.0f);
        }
        case Ease::BACK_IN_OUT: {
            float s = 1.70158f * 1.525f;
            float t2 = t * 2.0f;
            if (t2 < 1.0f) {
                return 0.5f * (t2 * t2 * ((s + 1.0f) * t2 - s));
            }
            float t3 = t2 - 2.0f;
            return 0.5f * (t3 * t3 * ((s + 1.0f) * t3 + s) + 2.0f);
        }
        case Ease::BOUNCE_IN:
            return bounceIn(t);
        case Ease::BOUNCE_OUT:
            return bounceOut(t);
        case Ease::BOUNCE_IN_OUT:
            return bounceInOut(t);
        case Ease::ELASTIC_IN:
            return elasticIn(t);
        case Ease::ELASTIC_OUT:
            return elasticOut(t);
        case Ease::ELASTIC_IN_OUT:
            return elasticInOut(t);
        case Ease::EXPO_IN:
            return (t <= 0.0f) ? 0.0f : std::pow(2.0f, 10.0f * (t - 1.0f));
        case Ease::EXPO_OUT:
            return (t >= 1.0f) ? 1.0f : (1.0f - std::pow(2.0f, -10.0f * t));
        case Ease::EXPO_IN_OUT:
            if (t <= 0.0f) return 0.0f;
            if (t >= 1.0f) return 1.0f;
            if (t < 0.5f) return 0.5f * std::pow(2.0f, 20.0f * t - 10.0f);
            return 1.0f - 0.5f * std::pow(2.0f, -20.0f * t + 10.0f);
        case Ease::SINE_IN:
            return 1.0f - std::cos(t * 1.57079632679f);
        case Ease::SINE_OUT:
            return std::sin(t * 1.57079632679f);
        case Ease::SINE_IN_OUT:
            return -0.5f * (std::cos(3.14159265359f * t) - 1.0f);
        default:
            return t;
    }
}

void UITween::update(float dt) {
    if (s_tweens.empty()) return;

    for (size_t i = 0; i < s_tweens.size();) {
        auto& item = s_tweens[i];

        if (item.isDelayedCall) {
            item.elapsed += dt;
            if (item.elapsed >= item.duration) {
                auto cb = std::move(item.onComplete);
                s_tweens.erase(s_tweens.begin() + i);
                if (cb) {
                    cb();
                }
            } else {
                ++i;
            }
            continue;
        }

        if (item.isInterval) {
            item.elapsed += dt;
            if (item.elapsed >= item.duration) {
                bool keep = item.intervalCallback ? item.intervalCallback() : false;
                if (!keep) {
                    s_tweens.erase(s_tweens.begin() + i);
                } else {
                    item.elapsed -= item.duration;
                    ++i;
                }
            } else {
                ++i;
            }
            continue;
        }

        auto node = item.node.lock();
        if (!node) {
            s_tweens.erase(s_tweens.begin() + i);
            continue;
        }

        if (item.delay > 0.0f) {
            item.delay -= dt;
            if (item.delay > 0.0f) {
                ++i;
                continue;
            }
        }

        if (!item.started) {
            item.started = true;
            item.startX = node->getX();
            item.startY = node->getY();
            item.startScaleX = node->getScaleX();
            item.startScaleY = node->getScaleY();
            item.startAlpha = node->getAlpha();
        }

        item.elapsed += dt;
        float progress = std::min(1.0f, item.elapsed / item.duration);
        float factor = evaluateEase(item.ease, progress);

        if (item.hasX) {
            node->setX(item.startX + (item.targetX - item.startX) * factor);
        }
        if (item.hasY) {
            node->setY(item.startY + (item.targetY - item.startY) * factor);
        }
        if (item.hasScaleX || item.hasScaleY) {
            float sx = item.hasScaleX ? (item.startScaleX + (item.targetScaleX - item.startScaleX) * factor) : node->getScaleX();
            float sy = item.hasScaleY ? (item.startScaleY + (item.targetScaleY - item.startScaleY) * factor) : node->getScaleY();
            node->setScale(sx, sy);
        }
        if (item.hasAlpha) {
            node->setAlpha(item.startAlpha + (item.targetAlpha - item.startAlpha) * factor);
        }

        if (progress >= 1.0f) {
            auto cb = std::move(item.onComplete);
            s_tweens.erase(s_tweens.begin() + i);
            if (cb) {
                cb();
            }
        } else {
            ++i;
        }
    }
}

}
