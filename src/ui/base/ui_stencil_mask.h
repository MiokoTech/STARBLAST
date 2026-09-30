// Komponen masking berbasis uji stensil OpenGL untuk klip poligon arbitrer.
#ifndef STARBLAST_UI_STENCIL_MASK_H
#define STARBLAST_UI_STENCIL_MASK_H

#include "ui_node.h"
#include <vector>

namespace starblast {

struct UIPoint {
    float x;
    float y;
};

class UIStencilMask : public UINode {
public:
    UIStencilMask();
    ~UIStencilMask() override = default;

    void setMaskPolygon(const std::vector<UIPoint>& points);
    void setMaskPolygon(const std::vector<float>& xyPairs);
    void setTriangles(const std::vector<float>& xyCoords);
    void clearMask();

    const std::vector<UIPoint>& getMaskPolygon() const { return m_polygon; }

    void render(SpriteRenderer* renderer) override;

private:
    std::vector<UIPoint> m_polygon;
    std::vector<float> m_triangles;
    bool m_useDirectTriangles;
};

}

#endif
