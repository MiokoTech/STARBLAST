// Pengelola manipulasi warna, efek tinting, dan filter color matrix antarmuka.
#ifndef STARBLAST_UI_COLOR_TRANSFORM_H
#define STARBLAST_UI_COLOR_TRANSFORM_H

#include <cstdint>
#include <array>

namespace starblast {

struct UIColor {
    float r = 1.0f;
    float g = 1.0f;
    float b = 1.0f;
    float a = 1.0f;
};

struct UIColorMatrix {
    std::array<float, 20> m;

    UIColorMatrix();
    void reset();
    void setBrightness(float val);
    void setContrast(float val);
    void setSaturation(float val);
    void setHue(float angleDegrees);
    void setInvert();
    void multiply(const UIColorMatrix& other);
    UIColor transformColor(const UIColor& in) const;

    static UIColorMatrix makeGrayscale();
};

class UIColorTransform {
public:
    static UIColor fromHex(uint32_t hex, float alpha = 1.0f);
    static uint32_t toHex(const UIColor& color);
    static UIColor lerp(const UIColor& from, const UIColor& to, float t);
    static UIColor applyBrightness(const UIColor& base, float factor);
    static UIColor applyTint(const UIColor& base, const UIColor& tint, float ratio);
    static UIColor toGrayscale(const UIColor& color);
    static UIColor shiftHue(const UIColor& color, float angleDegrees);
};

}

#endif
