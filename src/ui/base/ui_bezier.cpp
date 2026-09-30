// Implementasi kalkulasi kurva Bézier dan lintasan gerak animasi (motion path).
#include "ui_bezier.h"
#include <algorithm>

namespace starblast {

UIPoint UIBezierSegment::evaluate(float t) const {
    t = std::max(0.0f, std::min(1.0f, t));
    float u = 1.0f - t;

    if (!isCubic) {
        float tt = t * t;
        float uu = u * u;
        float ut2 = 2.0f * u * t;
        return {
            uu * p0.x + ut2 * p1.x + tt * p2.x,
            uu * p0.y + ut2 * p1.y + tt * p2.y
        };
    }

    float tt = t * t;
    float uu = u * u;
    float uuu = uu * u;
    float ttt = tt * t;

    return {
        uuu * p0.x + 3.0f * uu * t * p1.x + 3.0f * u * tt * p2.x + ttt * p3.x,
        uuu * p0.y + 3.0f * uu * t * p1.y + 3.0f * u * tt * p2.y + ttt * p3.y
    };
}

float UIBezierSegment::evaluateAngle(float t) const {
    t = std::max(0.0f, std::min(1.0f, t));
    float u = 1.0f - t;
    float dx = 0.0f;
    float dy = 0.0f;

    if (!isCubic) {
        dx = 2.0f * u * (p1.x - p0.x) + 2.0f * t * (p2.x - p1.x);
        dy = 2.0f * u * (p1.y - p0.y) + 2.0f * t * (p2.y - p1.y);
    } else {
        float uu3 = 3.0f * u * u;
        float ut6 = 6.0f * u * t;
        float tt3 = 3.0f * t * t;
        dx = uu3 * (p1.x - p0.x) + ut6 * (p2.x - p1.x) + tt3 * (p3.x - p2.x);
        dy = uu3 * (p1.y - p0.y) + ut6 * (p2.y - p1.y) + tt3 * (p3.y - p2.y);
    }

    return std::atan2(dy, dx) * UIMath::RAD_TO_DEG;
}

float UIBezierSegment::computeLength(int steps) {
    if (steps < 2) steps = 2;
    length = 0.0f;
    UIPoint prev = evaluate(0.0f);
    float stepInv = 1.0f / static_cast<float>(steps);

    for (int i = 1; i <= steps; ++i) {
        UIPoint curr = evaluate(static_cast<float>(i) * stepInv);
        length += UIMath::getDistanceByPoints(prev.x, prev.y, curr.x, curr.y);
        prev = curr;
    }
    return length;
}

void UIBezierPath::clear() {
    m_segments.clear();
    m_segmentLengths.clear();
    m_totalLength = 0.0f;
}

void UIBezierPath::addQuadraticSegment(const UIPoint& p0, const UIPoint& p1, const UIPoint& p2) {
    UIBezierSegment seg;
    seg.p0 = p0;
    seg.p1 = p1;
    seg.p2 = p2;
    seg.isCubic = false;
    seg.computeLength();
    m_segments.push_back(seg);
    updateLength();
}

void UIBezierPath::addCubicSegment(const UIPoint& p0, const UIPoint& p1, const UIPoint& p2, const UIPoint& p3) {
    UIBezierSegment seg;
    seg.p0 = p0;
    seg.p1 = p1;
    seg.p2 = p2;
    seg.p3 = p3;
    seg.isCubic = true;
    seg.computeLength();
    m_segments.push_back(seg);
    updateLength();
}

UIBezierPath UIBezierPath::createThroughPoints(const std::vector<UIPoint>& points, float curviness) {
    UIBezierPath path;
    if (points.size() < 2) return path;

    if (points.size() == 2) {
        path.addCubicSegment(points[0], points[0], points[1], points[1]);
        return path;
    }

    float tension = (curviness <= 0.0f) ? 0.0f : (curviness / 6.0f);
    size_t n = points.size();

    for (size_t i = 0; i < n - 1; ++i) {
        UIPoint p0 = (i == 0) ? points[0] : points[i - 1];
        UIPoint p1 = points[i];
        UIPoint p2 = points[i + 1];
        UIPoint p3 = (i + 2 < n) ? points[i + 2] : points[i + 1];

        UIPoint cp1 = {
            p1.x + (p2.x - p0.x) * tension,
            p1.y + (p2.y - p0.y) * tension
        };
        UIPoint cp2 = {
            p2.x - (p3.x - p1.x) * tension,
            p2.y - (p3.y - p1.y) * tension
        };

        path.addCubicSegment(p1, cp1, cp2, p2);
    }

    return path;
}

UIBezierPath UIBezierPath::createCircle(float cx, float cy, float radius, float startAngleDeg, float endAngleDeg) {
    UIBezierPath path;
    float startRad = UIMath::asRadians(startAngleDeg);
    float endRad = UIMath::asRadians(endAngleDeg);
    float sweep = endRad - startRad;

    int numSegments = std::max(1, static_cast<int>(std::ceil(std::abs(sweep) / (UIMath::PI * 0.5f))));
    float segAngle = sweep / static_cast<float>(numSegments);
    float k = 4.0f / 3.0f * std::tan(segAngle * 0.25f);

    float currentAngle = startRad;
    for (int i = 0; i < numSegments; ++i) {
        float nextAngle = currentAngle + segAngle;

        float cos0 = std::cos(currentAngle);
        float sin0 = std::sin(currentAngle);
        float cos1 = std::cos(nextAngle);
        float sin1 = std::sin(nextAngle);

        UIPoint p0 = { cx + radius * cos0, cy + radius * sin0 };
        UIPoint p3 = { cx + radius * cos1, cy + radius * sin1 };

        UIPoint p1 = { p0.x - k * radius * sin0, p0.y + k * radius * cos0 };
        UIPoint p2 = { p3.x + k * radius * sin1, p3.y - k * radius * cos1 };

        path.addCubicSegment(p0, p1, p2, p3);
        currentAngle = nextAngle;
    }

    return path;
}

UIBezierPath UIBezierPath::createLine(float x1, float y1, float x2, float y2) {
    UIBezierPath path;
    UIPoint p0 = { x1, y1 };
    UIPoint p3 = { x2, y2 };
    path.addCubicSegment(p0, p0, p3, p3);
    return path;
}

void UIBezierPath::updateLength() {
    m_segmentLengths.clear();
    m_totalLength = 0.0f;

    for (auto& seg : m_segments) {
        m_totalLength += seg.length;
        m_segmentLengths.push_back(m_totalLength);
    }
}

UIPoint UIBezierPath::getPoint(float progress) const {
    if (m_segments.empty()) return { 0.0f, 0.0f };
    progress = std::max(0.0f, std::min(1.0f, progress));

    if (m_totalLength <= 0.0f) {
        return m_segments.front().p0;
    }

    float targetDist = progress * m_totalLength;

    for (size_t i = 0; i < m_segments.size(); ++i) {
        if (targetDist <= m_segmentLengths[i] || i == m_segments.size() - 1) {
            float prevDist = (i == 0) ? 0.0f : m_segmentLengths[i - 1];
            float segLen = m_segments[i].length;
            float localT = (segLen > 0.0f) ? ((targetDist - prevDist) / segLen) : 0.0f;
            return m_segments[i].evaluate(localT);
        }
    }

    return m_segments.back().p3;
}

float UIBezierPath::getAngle(float progress) const {
    if (m_segments.empty()) return 0.0f;
    progress = std::max(0.0f, std::min(1.0f, progress));

    if (m_totalLength <= 0.0f) {
        return 0.0f;
    }

    float targetDist = progress * m_totalLength;

    for (size_t i = 0; i < m_segments.size(); ++i) {
        if (targetDist <= m_segmentLengths[i] || i == m_segments.size() - 1) {
            float prevDist = (i == 0) ? 0.0f : m_segmentLengths[i - 1];
            float segLen = m_segments[i].length;
            float localT = (segLen > 0.0f) ? ((targetDist - prevDist) / segLen) : 0.0f;
            return m_segments[i].evaluateAngle(localT);
        }
    }

    return m_segments.back().evaluateAngle(1.0f);
}

} // namespace starblast
