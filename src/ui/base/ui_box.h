// Komponen antarmuka panel dan bentuk kotak persegi dasar.
#ifndef STARBLAST_UI_BOX_H
#define STARBLAST_UI_BOX_H

#include "ui_node.h"
#include <cstdint>

namespace starblast {

class UIBox : public UINode {
public:
    UIBox();
    UIBox(float width, float height, float r = 0.0f, float g = 0.0f, float b = 0.0f, float a = 1.0f);
    ~UIBox() override = default;

    void setColor(float r, float g, float b);
    void setColorHex(uint32_t rgb);

    void setBorder(float thickness, float r, float g, float b, float a = 1.0f);
    void clearBorder();

    void render(SpriteRenderer* renderer) override;

private:
    float m_fillR;
    float m_fillG;
    float m_fillB;

    bool m_hasBorder;
    float m_borderThickness;
    float m_borderR;
    float m_borderG;
    float m_borderB;
    float m_borderA;
};

}

#endif
