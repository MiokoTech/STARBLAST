// Implementasi konversi, manipulasi warna, dan matriks filter antarmuka.
#include "ui_color_transform.h"
#include <algorithm>
#include <cmath>

namespace starblast {

static constexpr float LUM_R = 0.3086f;
static constexpr float LUM_G = 0.6094f;
static constexpr float LUM_B = 0.0820f;

UIColorMatrix::UIColorMatrix() {
    reset();
}

void UIColorMatrix::reset() {
    m.fill(0.0f);
    m[0] = 1.0f;
    m[6] = 1.0f;
    m[12] = 1.0f;
    m[18] = 1.0f;
}

void UIColorMatrix::setBrightness(float val) {
    m[4] = val;
    m[9] = val;
    m[14] = val;
}

void UIColorMatrix::setContrast(float val) {
    float offset = 0.5f * (1.0f - val);
    m[0] = val;
    m[6] = val;
    m[12] = val;
    m[4] = offset;
    m[9] = offset;
    m[14] = offset;
}

void UIColorMatrix::setSaturation(float val) {
    float inv = 1.0f - val;
    m[0] = inv * LUM_R + val;
    m[1] = inv * LUM_G;
    m[2] = inv * LUM_B;

    m[5] = inv * LUM_R;
    m[6] = inv * LUM_G + val;
    m[7] = inv * LUM_B;

    m[10] = inv * LUM_R;
    m[11] = inv * LUM_G;
    m[12] = inv * LUM_B + val;
}

void UIColorMatrix::setHue(float angleDegrees) {
    reset();
    float rad = angleDegrees * (3.14159265359f / 180.0f);
    float cosA = std::cos(rad);
    float sinA = std::sin(rad);

    m[0] = LUM_R + cosA * (1.0f - LUM_R) + sinA * (-LUM_R);
    m[1] = LUM_G + cosA * (-LUM_G) + sinA * (-LUM_G);
    m[2] = LUM_B + cosA * (-LUM_B) + sinA * (1.0f - LUM_B);

    m[5] = LUM_R + cosA * (-LUM_R) + sinA * 0.143f;
    m[6] = LUM_G + cosA * (1.0f - LUM_G) + sinA * 0.140f;
    m[7] = LUM_B + cosA * (-LUM_B) + sinA * (-0.283f);

    m[10] = LUM_R + cosA * (-LUM_R) + sinA * (-(1.0f - LUM_R));
    m[11] = LUM_G + cosA * (-LUM_G) + sinA * LUM_G;
    m[12] = LUM_B + cosA * (1.0f - LUM_B) + sinA * LUM_B;
}

void UIColorMatrix::setInvert() {
    reset();
    m[0] = -1.0f;
    m[6] = -1.0f;
    m[12] = -1.0f;
    m[4] = 1.0f;
    m[9] = 1.0f;
    m[14] = 1.0f;
}

void UIColorMatrix::multiply(const UIColorMatrix& other) {
    std::array<float, 20> res;
    for (int y = 0; y < 4; ++y) {
        for (int x = 0; x < 5; ++x) {
            float sum = (x == 4) ? m[y * 5 + 4] : 0.0f;
            for (int k = 0; k < 4; ++k) {
                sum += m[y * 5 + k] * other.m[k * 5 + x];
            }
            res[y * 5 + x] = sum;
        }
    }
    m = res;
}

UIColor UIColorMatrix::transformColor(const UIColor& in) const {
    UIColor out;
    out.r = std::clamp(m[0] * in.r + m[1] * in.g + m[2] * in.b + m[3] * in.a + m[4], 0.0f, 1.0f);
    out.g = std::clamp(m[5] * in.r + m[6] * in.g + m[7] * in.b + m[8] * in.a + m[9], 0.0f, 1.0f);
    out.b = std::clamp(m[10] * in.r + m[11] * in.g + m[12] * in.b + m[13] * in.a + m[14], 0.0f, 1.0f);
    out.a = std::clamp(m[15] * in.r + m[16] * in.g + m[17] * in.b + m[18] * in.a + m[19], 0.0f, 1.0f);
    return out;
}

UIColorMatrix UIColorMatrix::makeGrayscale() {
    UIColorMatrix mat;
    mat.setSaturation(0.0f);
    return mat;
}

UIColor UIColorTransform::fromHex(uint32_t hex, float alpha) {
    UIColor c;
    c.r = static_cast<float>((hex >> 16) & 0xFF) / 255.0f;
    c.g = static_cast<float>((hex >> 8) & 0xFF) / 255.0f;
    c.b = static_cast<float>(hex & 0xFF) / 255.0f;
    c.a = std::clamp(alpha, 0.0f, 1.0f);
    return c;
}

uint32_t UIColorTransform::toHex(const UIColor& color) {
    uint32_t r = static_cast<uint32_t>(std::clamp(color.r, 0.0f, 1.0f) * 255.0f);
    uint32_t g = static_cast<uint32_t>(std::clamp(color.g, 0.0f, 1.0f) * 255.0f);
    uint32_t b = static_cast<uint32_t>(std::clamp(color.b, 0.0f, 1.0f) * 255.0f);
    return (r << 16) | (g << 8) | b;
}

UIColor UIColorTransform::lerp(const UIColor& from, const UIColor& to, float t) {
    float f = std::clamp(t, 0.0f, 1.0f);
    UIColor c;
    c.r = from.r + (to.r - from.r) * f;
    c.g = from.g + (to.g - from.g) * f;
    c.b = from.b + (to.b - from.b) * f;
    c.a = from.a + (to.a - from.a) * f;
    return c;
}

UIColor UIColorTransform::applyBrightness(const UIColor& base, float factor) {
    UIColor c;
    c.r = std::clamp(base.r * factor, 0.0f, 1.0f);
    c.g = std::clamp(base.g * factor, 0.0f, 1.0f);
    c.b = std::clamp(base.b * factor, 0.0f, 1.0f);
    c.a = base.a;
    return c;
}

UIColor UIColorTransform::applyTint(const UIColor& base, const UIColor& tint, float ratio) {
    float r = std::clamp(ratio, 0.0f, 1.0f);
    UIColor c;
    c.r = base.r * (1.0f - r) + tint.r * r;
    c.g = base.g * (1.0f - r) + tint.g * r;
    c.b = base.b * (1.0f - r) + tint.b * r;
    c.a = base.a;
    return c;
}

UIColor UIColorTransform::toGrayscale(const UIColor& color) {
    float gray = color.r * LUM_R + color.g * LUM_G + color.b * LUM_B;
    return { gray, gray, gray, color.a };
}

UIColor UIColorTransform::shiftHue(const UIColor& color, float angleDegrees) {
    UIColorMatrix mat;
    mat.setHue(angleDegrees);
    return mat.transformColor(color);
}

}
