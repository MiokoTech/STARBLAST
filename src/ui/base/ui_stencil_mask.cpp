// Implementasi masking poligon menggunakan OpenGL Stencil Buffer.
#include "ui_stencil_mask.h"
#include "sprite_renderer.h"
#include <GLES3/gl3.h>

namespace starblast {

UIStencilMask::UIStencilMask()
    : UINode()
    , m_useDirectTriangles(false) {
}

void UIStencilMask::setMaskPolygon(const std::vector<UIPoint>& points) {
    m_polygon = points;
    m_useDirectTriangles = false;
}

void UIStencilMask::setMaskPolygon(const std::vector<float>& xyPairs) {
    m_polygon.clear();
    for (size_t i = 0; i + 1 < xyPairs.size(); i += 2) {
        m_polygon.push_back({xyPairs[i], xyPairs[i + 1]});
    }
    m_useDirectTriangles = false;
}

void UIStencilMask::setTriangles(const std::vector<float>& xyCoords) {
    m_triangles = xyCoords;
    m_useDirectTriangles = true;
}

void UIStencilMask::clearMask() {
    m_polygon.clear();
    m_triangles.clear();
    m_useDirectTriangles = false;
}

void UIStencilMask::render(SpriteRenderer* renderer) {
    if (!m_visible || !renderer) {
        return;
    }

    if (!m_useDirectTriangles && m_polygon.size() < 3) {
        UINode::render(renderer);
        return;
    }
    if (m_useDirectTriangles && m_triangles.size() < 6) {
        UINode::render(renderer);
        return;
    }

    renderer->flush();

    float gx = getGlobalX();
    float gy = getGlobalY();
    float gScaleX = getGlobalScaleX();
    float gScaleY = getGlobalScaleY();

    glEnable(GL_STENCIL_TEST);

    glStencilMask(0xFF);
    glClear(GL_STENCIL_BUFFER_BIT);

    glStencilFunc(GL_ALWAYS, 1, 0xFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_REPLACE);

    glColorMask(GL_FALSE, GL_FALSE, GL_FALSE, GL_FALSE);

    std::vector<float> worldTriangles;

    if (m_useDirectTriangles) {
        worldTriangles.reserve(m_triangles.size());
        for (size_t i = 0; i + 1 < m_triangles.size(); i += 2) {
            worldTriangles.push_back(gx + m_triangles[i] * gScaleX);
            worldTriangles.push_back(gy + m_triangles[i + 1] * gScaleY);
        }
    } else {
        UIPoint p0 = { gx + m_polygon[0].x * gScaleX, gy + m_polygon[0].y * gScaleY };
        for (size_t i = 1; i + 1 < m_polygon.size(); ++i) {
            UIPoint p1 = { gx + m_polygon[i].x * gScaleX, gy + m_polygon[i].y * gScaleY };
            UIPoint p2 = { gx + m_polygon[i + 1].x * gScaleX, gy + m_polygon[i + 1].y * gScaleY };
            worldTriangles.push_back(p0.x);
            worldTriangles.push_back(p0.y);
            worldTriangles.push_back(p1.x);
            worldTriangles.push_back(p1.y);
            worldTriangles.push_back(p2.x);
            worldTriangles.push_back(p2.y);
        }
    }

    renderer->drawPolygonTriangles(worldTriangles, 1.0f, 1.0f, 1.0f, 1.0f);
    renderer->flush();

    glColorMask(GL_TRUE, GL_TRUE, GL_TRUE, GL_TRUE);

    glStencilMask(0x00);
    glStencilFunc(GL_EQUAL, 1, 0xFF);
    glStencilOp(GL_KEEP, GL_KEEP, GL_KEEP);

    UINode::render(renderer);

    renderer->flush();

    glDisable(GL_STENCIL_TEST);
}

}
