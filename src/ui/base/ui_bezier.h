// Kalkulasi kurva Bézier dan lintasan gerak animasi (motion path).
#pragma once

#include "ui_math.h"
#include <vector>
#include <cmath>

namespace starblast {

struct UIBezierSegment {
    UIPoint p0;
    UIPoint p1;
    UIPoint p2;
    UIPoint p3;
    bool isCubic{true};
    float length{0.0f};

    UIPoint evaluate(float t) const;
    float evaluateAngle(float t) const;
    float computeLength(int steps = 10);
};

class UIBezierPath {
public:
    UIBezierPath() = default;

    void clear();
    void addQuadraticSegment(const UIPoint& p0, const UIPoint& p1, const UIPoint& p2);
    void addCubicSegment(const UIPoint& p0, const UIPoint& p1, const UIPoint& p2, const UIPoint& p3);

    static UIBezierPath createThroughPoints(const std::vector<UIPoint>& points, float curviness = 1.0f);
    static UIBezierPath createCircle(float cx, float cy, float radius, float startAngleDeg = 0.0f, float endAngleDeg = 360.0f);
    static UIBezierPath createLine(float x1, float y1, float x2, float y2);

    UIPoint getPoint(float progress) const;
    float getAngle(float progress) const;
    float getTotalLength() const { return m_totalLength; }
    size_t getSegmentCount() const { return m_segments.size(); }

    void updateLength();

private:
    std::vector<UIBezierSegment> m_segments;
    std::vector<float> m_segmentLengths;
    float m_totalLength{0.0f};
};

} // namespace starblast
