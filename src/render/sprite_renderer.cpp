// Render batching quad dan tekstur pake VAO/VBO.
#include "sprite_renderer.h"
#include <android/log.h>

#define LOG_TAG "SpriteRenderer"
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

static const char* SPRITE_VS =
    "#version 300 es\n"
    "layout(location = 0) in vec2 aPos;\n"
    "layout(location = 1) in vec2 aTexCoord;\n"
    "layout(location = 2) in vec4 aColor;\n"
    "uniform mat4 uMVP;\n"
    "out vec2 vTexCoord;\n"
    "out vec4 vColor;\n"
    "void main() {\n"
    "    gl_Position = uMVP * vec4(aPos, 0.0, 1.0);\n"
    "    vTexCoord = aTexCoord;\n"
    "    vColor = aColor;\n"
    "}\n";

static const char* SPRITE_FS =
    "#version 300 es\n"
    "precision mediump float;\n"
    "in vec2 vTexCoord;\n"
    "in vec4 vColor;\n"
    "uniform sampler2D uTexture;\n"
    "out vec4 fragColor;\n"
    "void main() {\n"
    "    vec4 tex = texture(uTexture, vTexCoord);\n"
    "    fragColor = tex * vColor;\n"
    "}\n";

SpriteRenderer::SpriteRenderer()
    : m_program(0)
    , m_uMVP(-1)
    , m_uTexture(-1)
    , m_vao(0)
    , m_vbo(0)
    , m_whiteTex(0)
    , m_currentTexture(0)
    , m_vpW(1280)
    , m_vpH(720)
{
    m_vertices.reserve(MAX_VERTICES);
}

SpriteRenderer::~SpriteRenderer() {
    destroy();
}

static GLuint compile(GLenum type, const char* src) {
    GLuint s = glCreateShader(type);
    glShaderSource(s, 1, &src, nullptr);
    glCompileShader(s);
    GLint ok;
    glGetShaderiv(s, GL_COMPILE_STATUS, &ok);
    if (!ok) {
        char buf[512];
        glGetShaderInfoLog(s, sizeof(buf), nullptr, buf);
        LOGE("Shader err: %s", buf);
        glDeleteShader(s);
        return 0;
    }
    return s;
}

bool SpriteRenderer::init() {
    GLuint vs = compile(GL_VERTEX_SHADER, SPRITE_VS);
    GLuint fs = compile(GL_FRAGMENT_SHADER, SPRITE_FS);
    m_program = glCreateProgram();
    glAttachShader(m_program, vs);
    glAttachShader(m_program, fs);
    glLinkProgram(m_program);
    glDeleteShader(vs);
    glDeleteShader(fs);

    m_uMVP = glGetUniformLocation(m_program, "uMVP");
    m_uTexture = glGetUniformLocation(m_program, "uTexture");

    glGenVertexArrays(1, &m_vao);
    glGenBuffers(1, &m_vbo);

    glBindVertexArray(m_vao);
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
    glBufferData(GL_ARRAY_BUFFER, MAX_VERTICES * sizeof(SpriteVertex), nullptr, GL_DYNAMIC_DRAW);

    glEnableVertexAttribArray(0);
    glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (void*)offsetof(SpriteVertex, x));

    glEnableVertexAttribArray(1);
    glVertexAttribPointer(1, 2, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (void*)offsetof(SpriteVertex, u));

    glEnableVertexAttribArray(2);
    glVertexAttribPointer(2, 4, GL_FLOAT, GL_FALSE, sizeof(SpriteVertex), (void*)offsetof(SpriteVertex, r));

    glBindVertexArray(0);
    glBindBuffer(GL_ARRAY_BUFFER, 0);

    glGenTextures(1, &m_whiteTex);
    glBindTexture(GL_TEXTURE_2D, m_whiteTex);
    uint32_t whitePixel = 0xFFFFFFFF;
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, 1, 1, 0, GL_RGBA, GL_UNSIGNED_BYTE, &whitePixel);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glBindTexture(GL_TEXTURE_2D, 0);

    return true;
}

void SpriteRenderer::destroy() {
    if (m_whiteTex != 0) { glDeleteTextures(1, &m_whiteTex); m_whiteTex = 0; }
    if (m_vao != 0) { glDeleteVertexArrays(1, &m_vao); m_vao = 0; }
    if (m_vbo != 0) { glDeleteBuffers(1, &m_vbo); m_vbo = 0; }
    if (m_program != 0) { glDeleteProgram(m_program); m_program = 0; }
}

void SpriteRenderer::setViewport(int width, int height) {
    m_vpW = width;
    m_vpH = height;
}

void SpriteRenderer::begin() {
    glUseProgram(m_program);

    float mvp[16] = {
        2.0f / 1280.0f, 0.0f,           0.0f, 0.0f,
        0.0f,          -2.0f / 720.0f,  0.0f, 0.0f,
        0.0f,           0.0f,           1.0f, 0.0f,
       -1.0f,           1.0f,           0.0f, 1.0f
    };
    glUniformMatrix4fv(m_uMVP, 1, GL_FALSE, mvp);
    glUniform1i(m_uTexture, 0);

    glEnable(GL_BLEND);
    glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

    m_currentTexture = 0;
    m_vertices.clear();
}

void SpriteRenderer::end() {
    flush();
    glBindVertexArray(0);
}

void SpriteRenderer::flush() {
    if (m_vertices.empty() || m_currentTexture == 0) return;

    glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, m_currentTexture);

    glBindVertexArray(m_vao);
    glBindBuffer(GL_ARRAY_BUFFER, m_vbo);
    glBufferSubData(GL_ARRAY_BUFFER, 0, m_vertices.size() * sizeof(SpriteVertex), m_vertices.data());

    glDrawArrays(GL_TRIANGLES, 0, static_cast<GLsizei>(m_vertices.size()));

    m_vertices.clear();
}

void SpriteRenderer::drawSprite(
    GLuint textureId,
    float screenX, float screenY,
    int atlasX, int atlasY, int spriteW, int spriteH,
    int sheetW, int sheetH,
    int axisX, int axisY,
    int facing,
    float scaleX, float scaleY,
    float r, float g, float b, float a
) {
    if (textureId == 0 || spriteW <= 0 || spriteH <= 0) return;

    if (textureId != m_currentTexture || m_vertices.size() + 6 > MAX_VERTICES) {
        flush();
        m_currentTexture = textureId;
    }

    float u0 = static_cast<float>(atlasX) / static_cast<float>(sheetW);
    float v0 = static_cast<float>(atlasY) / static_cast<float>(sheetH);
    float u1 = static_cast<float>(atlasX + spriteW) / static_cast<float>(sheetW);
    float v1 = static_cast<float>(atlasY + spriteH) / static_cast<float>(sheetH);

    if (facing < 0) {
        std::swap(u0, u1);
    }

    float x0, x1, y0, y1;
    if (facing >= 0) {
        x0 = screenX - axisX * scaleX;
        x1 = x0 + spriteW * scaleX;
    } else {
        x0 = screenX - (spriteW - axisX) * scaleX;
        x1 = x0 + spriteW * scaleX;
    }
    y0 = screenY - axisY * scaleY;
    y1 = y0 + spriteH * scaleY;

    m_vertices.push_back({x0, y0, u0, v0, r, g, b, a});
    m_vertices.push_back({x1, y0, u1, v0, r, g, b, a});
    m_vertices.push_back({x0, y1, u0, v1, r, g, b, a});

    m_vertices.push_back({x1, y0, u1, v0, r, g, b, a});
    m_vertices.push_back({x1, y1, u1, v1, r, g, b, a});
    m_vertices.push_back({x0, y1, u0, v1, r, g, b, a});
}

void SpriteRenderer::drawRect(float x, float y, float w, float h, float r, float g, float b, float a) {
    if (m_whiteTex == 0) return;
    drawSprite(m_whiteTex, x, y, 0, 0, 1, 1, 1, 1, 0, 0, 1, w, h, r, g, b, a);
}

}
