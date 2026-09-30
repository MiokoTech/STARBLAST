// Node hierarki elemen antarmuka game STARBLAST.
#ifndef STARBLAST_UI_NODE_H
#define STARBLAST_UI_NODE_H

#include <vector>
#include <memory>
#include <algorithm>

namespace starblast {

class SpriteRenderer;

class UINode : public std::enable_shared_from_this<UINode> {
public:
    UINode();
    virtual ~UINode() = default;

    void addChild(std::shared_ptr<UINode> child);
    void removeChild(std::shared_ptr<UINode> child);
    void removeAllChildren();
    UINode* getParent() const { return m_parent; }
    const std::vector<std::shared_ptr<UINode>>& getChildren() const { return m_children; }

    void setPosition(float x, float y) { m_x = x; m_y = y; }
    void setX(float x) { m_x = x; }
    void setY(float y) { m_y = y; }
    float getX() const { return m_x; }
    float getY() const { return m_y; }

    void setSize(float w, float h) { m_width = w; m_height = h; }
    float getWidth() const { return m_width; }
    float getHeight() const { return m_height; }

    void setScale(float sx, float sy) { m_scaleX = sx; m_scaleY = sy; }
    void setScale(float s) { m_scaleX = s; m_scaleY = s; }
    float getScaleX() const { return m_scaleX; }
    float getScaleY() const { return m_scaleY; }

    void setAlpha(float a) { m_alpha = a; }
    float getAlpha() const { return m_alpha; }

    void setVisible(bool v) { m_visible = v; }
    bool isVisible() const { return m_visible; }

    float getGlobalX() const;
    float getGlobalY() const;
    float getGlobalAlpha() const;
    float getGlobalScaleX() const;
    float getGlobalScaleY() const;

    virtual bool hitTest(float gx, float gy) const;
    virtual bool handleTouch(float tx, float ty, bool isDown);

    virtual void update(float dt);
    virtual void render(SpriteRenderer* renderer);

protected:
    UINode* m_parent;
    std::vector<std::shared_ptr<UINode>> m_children;

    float m_x;
    float m_y;
    float m_width;
    float m_height;
    float m_scaleX;
    float m_scaleY;
    float m_alpha;
    bool m_visible;
};

}

#endif
