// Komponen visual teks bitmap untuk antarmuka game.
#ifndef STARBLAST_UI_TEXT_H
#define STARBLAST_UI_TEXT_H

#include "ui_node.h"
#include "ui_bitmap_font.h"
#include <string>
#include <memory>

namespace starblast {

enum class TextAlign {
    LEFT,
    CENTER,
    RIGHT
};

class UIText : public UINode {
public:
    UIText();
    explicit UIText(std::shared_ptr<UIBitmapFont> font, const std::string& text = "");
    ~UIText() override = default;

    void setFont(std::shared_ptr<UIBitmapFont> font);
    std::shared_ptr<UIBitmapFont> getFont() const { return m_font; }

    void setText(const std::string& text);
    const std::string& getText() const { return m_text; }

    void setTextAlign(TextAlign align);
    TextAlign getTextAlign() const { return m_align; }

    void setTextColor(float r, float g, float b);
    void getTextColor(float& r, float& g, float& b) const;

    void setLetterSpacing(float spacing);
    float getLetterSpacing() const { return m_letterSpacing; }

    void render(SpriteRenderer* renderer) override;

private:
    void updateDimensions();

    std::shared_ptr<UIBitmapFont> m_font;
    std::string m_text;
    TextAlign m_align;
    float m_tintR;
    float m_tintG;
    float m_tintB;
    float m_letterSpacing;
};

}

#endif
