#ifndef STARBLAST_SPRITE_RENDERER_H
#define STARBLAST_SPRITE_RENDERER_H

#include <GLES3/gl3.h>
#include <cstdint>
#include <vector>

namespace starblast {

struct SpriteVertex {
    float x, y;
    float u, v;
    float r, g, b, a;
};

class SpriteRenderer {
public:
    SpriteRenderer();
    ~SpriteRenderer();

    bool init();
    void destroy();

    void setViewport(int width, int height);
    void begin();
    void end();

    void drawSprite(
        GLuint textureId,
        float screenX, float screenY,
        int atlasX, int atlasY, int spriteW, int spriteH,
        int sheetW, int sheetH,
        int axisX, int axisY,
        int facing,
        float scaleX = 1.0f, float scaleY = 1.0f,
        float r = 1.0f, float g = 1.0f, float b = 1.0f, float a = 1.0f
    );

    void drawRect(float x, float y, float w, float h, float r, float g, float b, float a);

    void flush();

private:
    GLuint m_program;
    GLint m_uMVP;
    GLint m_uTexture;
    GLuint m_vao;
    GLuint m_vbo;
    GLuint m_whiteTex;

    GLuint m_currentTexture;
    std::vector<SpriteVertex> m_vertices;
    static constexpr size_t MAX_SPRITES = 1024;
    static constexpr size_t MAX_VERTICES = MAX_SPRITES * 6;

    int m_vpW;
    int m_vpH;
};

}

#endif
