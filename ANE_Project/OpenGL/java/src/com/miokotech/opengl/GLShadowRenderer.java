package com.miokotech.opengl;

import android.content.Context;
import android.graphics.PixelFormat;
import android.opengl.GLES20;
import android.opengl.GLSurfaceView;
import android.opengl.Matrix;
import android.util.Log;

import java.nio.ByteBuffer;
import java.nio.ByteOrder;
import java.nio.FloatBuffer;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

import javax.microedition.khronos.egl.EGLConfig;
import javax.microedition.khronos.opengles.GL10;

public class GLShadowRenderer implements GLSurfaceView.Renderer {
    private static final String TAG = "GLShadowRenderer";

    public static class ShadowData {
        public int id;
        public float x;
        public float y;
        public float width;
        public float height;
        public float scaleX;
        public float scaleY;
        public float skewX;
        public float alpha;
        public float r, g, b;
        public boolean active;
    }

    private final Map<Integer, ShadowData> shadowMap = new ConcurrentHashMap<Integer, ShadowData>();
    private float groundY = 600.0f;
    private float lightAngle = 0.0f;
    private int surfaceWidth = 1280;
    private int surfaceHeight = 720;

    private int programId = 0;
    private int aPosHandle = -1;
    private int aTexHandle = -1;
    private int uMVPHandle = -1;
    private int uColorHandle = -1;

    private FloatBuffer vertexBuffer;
    private FloatBuffer texBuffer;

    private final float[] projMatrix = new float[16];
    private final float[] mvpMatrix = new float[16];
    private final float[] modelMatrix = new float[16];

    private static final float[] QUAD_VERTICES = {
        -0.5f, -0.5f,
         0.5f, -0.5f,
        -0.5f,  0.5f,
         0.5f,  0.5f
    };

    private static final float[] QUAD_TEXCOORDS = {
        -1.0f, -1.0f,
         1.0f, -1.0f,
        -1.0f,  1.0f,
         1.0f,  1.0f
    };

    private static final String VERTEX_SHADER =
        "attribute vec2 aPosition;\n" +
        "attribute vec2 aTexCoord;\n" +
        "uniform mat4 uMVPMatrix;\n" +
        "varying vec2 vTexCoord;\n" +
        "void main() {\n" +
        "    vTexCoord = aTexCoord;\n" +
        "    gl_Position = uMVPMatrix * vec4(aPosition, 0.0, 1.0);\n" +
        "}\n";

    private static final String FRAGMENT_SHADER =
        "precision mediump float;\n" +
        "varying vec2 vTexCoord;\n" +
        "uniform vec4 uColor;\n" +
        "void main() {\n" +
        "    float dist = length(vTexCoord);\n" +
        "    if (dist > 1.0) {\n" +
        "        discard;\n" +
        "    }\n" +
        "    float softAlpha = uColor.a * (1.0 - smoothstep(0.5, 1.0, dist));\n" +
        "    gl_FragColor = vec4(uColor.rgb, softAlpha);\n" +
        "}\n";

    public GLShadowRenderer() {
        ByteBuffer bb = ByteBuffer.allocateDirect(QUAD_VERTICES.length * 4);
        bb.order(ByteOrder.nativeOrder());
        vertexBuffer = bb.asFloatBuffer();
        vertexBuffer.put(QUAD_VERTICES);
        vertexBuffer.position(0);

        ByteBuffer tb = ByteBuffer.allocateDirect(QUAD_TEXCOORDS.length * 4);
        tb.order(ByteOrder.nativeOrder());
        texBuffer = tb.asFloatBuffer();
        texBuffer.put(QUAD_TEXCOORDS);
        texBuffer.position(0);
    }

    public static GLSurfaceView createTransparentGLView(Context context, GLShadowRenderer renderer) {
        GLSurfaceView glView = new GLSurfaceView(context);
        glView.setEGLContextClientVersion(2);
        glView.setEGLConfigChooser(8, 8, 8, 8, 16, 0);
        glView.getHolder().setFormat(PixelFormat.TRANSLUCENT);
        glView.setRenderer(renderer);
        glView.setRenderMode(GLSurfaceView.RENDERMODE_CONTINUOUSLY);
        glView.setZOrderOnTop(true);
        return glView;
    }

    public void updateShadow(int id, float x, float y, float width, float height, float scaleX, float scaleY, float skewX, float alpha, int colorHex) {
        ShadowData data = shadowMap.get(id);
        if (data == null) {
            data = new ShadowData();
            data.id = id;
            shadowMap.put(id, data);
        }
        data.x = x;
        data.y = y;
        data.width = width > 0 ? width : 120.0f;
        data.height = height > 0 ? height : 40.0f;
        data.scaleX = scaleX;
        data.scaleY = scaleY;
        data.skewX = skewX;
        data.alpha = alpha;
        data.r = ((colorHex >> 16) & 0xFF) / 255.0f;
        data.g = ((colorHex >> 8) & 0xFF) / 255.0f;
        data.b = (colorHex & 0xFF) / 255.0f;
        data.active = true;
    }

    public void setShadowConfig(float groundY, float lightAngle) {
        this.groundY = groundY;
        this.lightAngle = lightAngle;
    }

    public void clearShadows() {
        shadowMap.clear();
    }

    @Override
    public void onSurfaceCreated(GL10 gl, EGLConfig config) {
        GLES20.glClearColor(0.0f, 0.0f, 0.0f, 0.0f);
        GLES20.glEnable(GLES20.GL_BLEND);
        GLES20.glBlendFunc(GLES20.GL_SRC_ALPHA, GLES20.GL_ONE_MINUS_SRC_ALPHA);
        GLES20.glDisable(GLES20.GL_DEPTH_TEST);

        programId = createProgram(VERTEX_SHADER, FRAGMENT_SHADER);
        if (programId != 0) {
            aPosHandle = GLES20.glGetAttribLocation(programId, "aPosition");
            aTexHandle = GLES20.glGetAttribLocation(programId, "aTexCoord");
            uMVPHandle = GLES20.glGetUniformLocation(programId, "uMVPMatrix");
            uColorHandle = GLES20.glGetUniformLocation(programId, "uColor");
        }
    }

    @Override
    public void onSurfaceChanged(GL10 gl, int width, int height) {
        surfaceWidth = width;
        surfaceHeight = height;
        GLES20.glViewport(0, 0, width, height);
        Matrix.orthoM(projMatrix, 0, 0, (float) width, (float) height, 0, -1.0f, 1.0f);
    }

    @Override
    public void onDrawFrame(GL10 gl) {
        GLES20.glClear(GLES20.GL_COLOR_BUFFER_BIT);

        if (programId == 0 || shadowMap.isEmpty()) {
            return;
        }

        GLES20.glUseProgram(programId);
        GLES20.glEnableVertexAttribArray(aPosHandle);
        GLES20.glVertexAttribPointer(aPosHandle, 2, GLES20.GL_FLOAT, false, 0, vertexBuffer);

        GLES20.glEnableVertexAttribArray(aTexHandle);
        GLES20.glVertexAttribPointer(aTexHandle, 2, GLES20.GL_FLOAT, false, 0, texBuffer);

        for (ShadowData shadow : shadowMap.values()) {
            if (!shadow.active) continue;

            Matrix.setIdentityM(modelMatrix, 0);
            Matrix.translateM(modelMatrix, 0, shadow.x, shadow.y, 0.0f);

            float effScaleX = shadow.width * Math.abs(shadow.scaleX);
            float effScaleY = shadow.height * Math.abs(shadow.scaleY);
            Matrix.scaleM(modelMatrix, 0, effScaleX, effScaleY, 1.0f);

            float[] skewMatrix = new float[16];
            Matrix.setIdentityM(skewMatrix, 0);
            skewMatrix[4] = shadow.skewX;

            float[] skewedModel = new float[16];
            Matrix.multiplyMM(skewedModel, 0, modelMatrix, 0, skewMatrix, 0);

            Matrix.multiplyMM(mvpMatrix, 0, projMatrix, 0, skewedModel, 0);
            GLES20.glUniformMatrix4fv(uMVPHandle, 1, false, mvpMatrix, 0);
            GLES20.glUniform4f(uColorHandle, shadow.r, shadow.g, shadow.b, shadow.alpha);

            GLES20.glDrawArrays(GLES20.GL_TRIANGLE_STRIP, 0, 4);
        }

        GLES20.glDisableVertexAttribArray(aPosHandle);
        GLES20.glDisableVertexAttribArray(aTexHandle);
    }

    private int loadShader(int type, String shaderCode) {
        int shader = GLES20.glCreateShader(type);
        GLES20.glShaderSource(shader, shaderCode);
        GLES20.glCompileShader(shader);
        int[] compiled = new int[1];
        GLES20.glGetShaderiv(shader, GLES20.GL_COMPILE_STATUS, compiled, 0);
        if (compiled[0] == 0) {
            Log.e(TAG, "Shader compilation error: " + GLES20.glGetShaderInfoLog(shader));
            GLES20.glDeleteShader(shader);
            return 0;
        }
        return shader;
    }

    private int createProgram(String vertexSource, String fragmentSource) {
        int vertexShader = loadShader(GLES20.GL_VERTEX_SHADER, vertexSource);
        int fragmentShader = loadShader(GLES20.GL_FRAGMENT_SHADER, fragmentSource);
        if (vertexShader == 0 || fragmentShader == 0) return 0;

        int program = GLES20.glCreateProgram();
        GLES20.glAttachShader(program, vertexShader);
        GLES20.glAttachShader(program, fragmentShader);
        GLES20.glLinkProgram(program);

        int[] linkStatus = new int[1];
        GLES20.glGetProgramiv(program, GLES20.GL_LINK_STATUS, linkStatus, 0);
        if (linkStatus[0] != GLES20.GL_TRUE) {
            Log.e(TAG, "Program link error: " + GLES20.glGetProgramInfoLog(program));
            GLES20.glDeleteProgram(program);
            return 0;
        }
        return program;
    }
}
