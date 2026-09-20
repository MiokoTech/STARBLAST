package com.miokotech.opengl;

import android.app.Activity;
import android.opengl.GLSurfaceView;
import android.util.Log;
import android.view.ViewGroup;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;

import java.util.HashMap;
import java.util.Map;

public class OpenGLContext extends FREContext {
    private static final String TAG = "OpenGLContext";

    private GLSurfaceView glSurfaceView;
    private GLShadowRenderer shadowRenderer;

    public GLShadowRenderer getShadowRenderer() {
        return shadowRenderer;
    }

    public GLSurfaceView getGLSurfaceView() {
        return glSurfaceView;
    }

    public boolean createShadowView() {
        final Activity activity = getActivity();
        if (activity == null) return false;

        if (glSurfaceView != null) {
            return true;
        }

        try {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    shadowRenderer = new GLShadowRenderer();
                    glSurfaceView = GLShadowRenderer.createTransparentGLView(activity, shadowRenderer);

                    ViewGroup.LayoutParams params = new ViewGroup.LayoutParams(
                        ViewGroup.LayoutParams.MATCH_PARENT,
                        ViewGroup.LayoutParams.MATCH_PARENT
                    );
                    activity.addContentView(glSurfaceView, params);
                    Log.d(TAG, "Transparent GLSurfaceView attached successfully");
                }
            });
            return true;
        } catch (Exception e) {
            Log.e(TAG, "Error creating GLSurfaceView: " + e.getMessage());
            return false;
        }
    }

    @Override
    public void dispose() {
        final Activity activity = getActivity();
        if (activity != null && glSurfaceView != null) {
            activity.runOnUiThread(new Runnable() {
                @Override
                public void run() {
                    if (glSurfaceView.getParent() instanceof ViewGroup) {
                        ((ViewGroup) glSurfaceView.getParent()).removeView(glSurfaceView);
                    }
                    glSurfaceView = null;
                    shadowRenderer = null;
                    Log.d(TAG, "GLSurfaceView removed and disposed");
                }
            });
        }
    }

    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> map = new HashMap<String, FREFunction>();
        map.put("isSupported", new IsSupportedFunction());
        map.put("initGL", new InitGLFunction());
        map.put("getGLInfo", new GetGLInfoFunction());
        map.put("createShadowView", new CreateShadowViewFunction());
        map.put("updateShadow", new UpdateShadowFunction());
        map.put("setShadowConfig", new SetShadowConfigFunction());
        map.put("clearShadows", new ClearShadowsFunction());
        map.put("disposeGL", new DisposeGLFunction());
        return map;
    }
}
