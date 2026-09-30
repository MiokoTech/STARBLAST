// Utilitas matematika, fisika gerak, dan kalkulasi probabilitas acak.
#pragma once

#include <cmath>
#include <cstdint>
#include <vector>
#include <random>
#include <algorithm>
#include <functional>

namespace starblast {

struct UIRect {
    float x{0.0f};
    float y{0.0f};
    float width{0.0f};
    float height{0.0f};
};

struct UIPoint {
    float x{0.0f};
    float y{0.0f};
};

class UIMath {
public:
    static constexpr float PI = 3.14159265358979323846f;
    static constexpr float DEG_TO_RAD = PI / 180.0f;
    static constexpr float RAD_TO_DEG = 180.0f / PI;

    static float fixRange(float val, float minVal, float maxVal);
    static bool inRange(float val, float minVal, float maxVal);
    static float asRadians(float deg);
    static float asDegrees(float rad);
    static float getAngleByPoints(float x1, float y1, float x2, float y2);
    static float getDistanceByPoints(float x1, float y1, float x2, float y2);
    static UIPoint getPointByRadians(float x, float y, float rad, float scaleY = 1.0f);
    static UIPoint velocityFromAngle(float angle, float speed, bool isDegree = true);

    static float numWake(float val, float step);
    static float numStrong(float val, float step);
    static bool rectIsHit(const UIRect& a, const UIRect& b, UIRect* outIntersection = nullptr);
    static float decimal(float val, int decimals);
};

class UIRandom {
public:
    static void setSeed(uint32_t seed);
    static float value();
    static float between(float minVal, float maxVal);
    static int range(int minVal, int maxVal);
    static uint32_t randomColor(uint32_t minColor = 0x000000, uint32_t maxColor = 0xFFFFFF);

    template<typename T>
    static const T* getRandomInVector(const std::vector<T>& list) {
        if (list.empty()) return nullptr;
        int idx = range(0, static_cast<int>(list.size()) - 1);
        return &list[idx];
    }

    template<typename T>
    static bool getRandomAndRemove(std::vector<T>& list, T& outItem) {
        if (list.empty()) return false;
        int idx = range(0, static_cast<int>(list.size()) - 1);
        outItem = list[idx];
        list.erase(list.begin() + idx);
        return true;
    }

    template<typename T>
    static std::vector<T> getRandomSome(const std::vector<T>& list, int count, bool allowDuplicate = false) {
        std::vector<T> result;
        if (list.empty() || count <= 0) return result;
        if (allowDuplicate) {
            for (int i = 0; i < count; ++i) {
                int idx = range(0, static_cast<int>(list.size()) - 1);
                result.push_back(list[idx]);
            }
        } else {
            std::vector<T> copy = list;
            int take = std::min(count, static_cast<int>(copy.size()));
            for (int i = 0; i < take; ++i) {
                int idx = range(0, static_cast<int>(copy.size()) - 1);
                result.push_back(copy[idx]);
                copy.erase(copy.begin() + idx);
            }
        }
        return result;
    }

    template<typename T>
    static void shuffle(std::vector<T>& list) {
        if (list.size() <= 1) return;
        std::shuffle(list.begin(), list.end(), getEngine());
    }

    template<typename T>
    static int getRandomByRate(const std::vector<T>& list, std::function<float(const T&)> getWeight) {
        if (list.empty()) return -1;
        float totalWeight = 0.0f;
        for (const auto& item : list) {
            float w = getWeight(item);
            if (w > 0.0f) totalWeight += w;
        }
        if (totalWeight <= 0.0f) return range(0, static_cast<int>(list.size()) - 1);
        float rnd = value() * totalWeight;
        float current = 0.0f;
        for (size_t i = 0; i < list.size(); ++i) {
            float w = getWeight(list[i]);
            if (w <= 0.0f) continue;
            current += w;
            if (rnd <= current) return static_cast<int>(i);
        }
        return static_cast<int>(list.size()) - 1;
    }

    static std::mt19937& getEngine();
};

} // namespace starblast
