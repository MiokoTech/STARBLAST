// Komponen pembatas area render viewport antarmuka.
#ifndef STARBLAST_UI_MASK_H
#define STARBLAST_UI_MASK_H

#include "ui_node.h"

namespace starblast {

class UIMask : public UINode {
public:
    UIMask();
    UIMask(float width, float height);
    ~UIMask() override = default;

    void render(SpriteRenderer* renderer) override;
};

}

#endif
