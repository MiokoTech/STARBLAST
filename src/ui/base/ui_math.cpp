// Implementasi utilitas matematika, fisika gerak, dan kalkulasi probabilitas acak.
#include "ui_math.h"

namespace starblast {

float UIMath::fixRange(float val, float minVal, float maxVal) {
    if (val < minVal) return minVal;
    if (val > maxVal) return maxVal;
    return val;
}

bool UIMath::inRange(float val, float minVal, float maxVal) {
    return val >= minVal && val <= maxVal;
}

float UIMath::asRadians(float deg) {
    return deg * DEG_TO_RAD;
}

float UIMath::asDegrees(float rad) {
    return rad * RAD_TO_DEG;
}

float UIMath::getAngleByPoints(float x1, float y1, float x2, float y2) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    return std::atan2(dy, dx) * RAD_TO_DEG;
}

float UIMath::getDistanceByPoints(float x1, float y1, float x2, float y2) {
    float dx = x2 - x1;
    float dy = y2 - y1;
    return std::sqrt(dx * dx + dy * dy);
}

UIPoint UIMath::getPointByRadians(float x, float y, float rad, float scaleY) {
    float c = std::cos(rad);
    float s = std::sin(rad);
    return { x * c - y * s * scaleY, x * s + y * c * scaleY };
}

UIPoint UIMath::velocityFromAngle(float angle, float speed, bool isDegree) {
    float rad = isDegree ? asRadians(angle) : angle;
    return { std::cos(rad) * speed, std::sin(rad) * speed };
}

float UIMath::numWake(float val, float step) {
    if (val > 0.0f) {
        val -= step;
        if (val < 0.0f) val = 0.0f;
    } else if (val < 0.0f) {
        val += step;
        if (val > 0.0f) val = 0.0f;
    }
    return val;
}

float UIMath::numStrong(float val, float step) {
    if (val < 0.0f) return val - step;
    return val + step;
}

bool UIMath::rectIsHit(const UIRect& a, const UIRect& b, UIRect* outIntersection) {
    float ax1 = a.width >= 0.0f ? a.x : a.x + a.width;
    float ax2 = a.width >= 0.0f ? a.x + a.width : a.x;
    float ay1 = a.height >= 0.0f ? a.y : a.y + a.height;
    float ay2 = a.height >= 0.0f ? a.y + a.height : a.y;

    float bx1 = b.width >= 0.0f ? b.x : b.x + b.width;
    float bx2 = b.width >= 0.0f ? b.x + b.width : b.x;
    float by1 = b.height >= 0.0f ? b.y : b.y + b.height;
    float by2 = b.height >= 0.0f ? b.y + b.height : b.y;

    float ix1 = std::max(ax1, bx1);
    float iy1 = std::max(ay1, by1);
    float ix2 = std::min(ax2, bx2);
    float iy2 = std::min(ay2, by2);

    if (ix1 < ix2 && iy1 < iy2) {
        if (outIntersection) {
            outIntersection->x = ix1;
            outIntersection->y = iy1;
            outIntersection->width = ix2 - ix1;
            outIntersection->height = iy2 - iy1;
        }
        return true;
    }
    return false;
}

float UIMath::decimal(float val, int decimals) {
    float p = std::pow(10.0f, static_cast<float>(decimals));
    return std::round(val * p) / p;
}

std::mt19937& UIRandom::getEngine() {
    static std::mt19937 engine(1337);
    return engine;
}

void UIRandom::setSeed(uint32_t seed) {
    getEngine().seed(seed);
}

float UIRandom::value() {
    static std::uniform_real_distribution<float> dist(0.0f, 1.0f);
    return dist(getEngine());
}

float UIRandom::between(float minVal, float maxVal) {
    if (minVal > maxVal) std::swap(minVal, maxVal);
    return minVal + value() * (maxVal - minVal);
}

int UIRandom::range(int minVal, int maxVal) {
    if (minVal > maxVal) std::swap(minVal, maxVal);
    std::uniform_int_distribution<int> dist(minVal, maxVal);
    return dist(getEngine());
}

uint32_t UIRandom::randomColor(uint32_t minColor, uint32_t maxColor) {
    if (minColor > maxColor) std::swap(minColor, maxColor);
    uint32_t diff = maxColor - minColor;
    return minColor + static_cast<uint32_t>(value() * static_cast<float>(diff));
}

} // namespace starblast
