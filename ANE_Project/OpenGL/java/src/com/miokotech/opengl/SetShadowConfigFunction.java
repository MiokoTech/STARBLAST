package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class SetShadowConfigFunction implements FREFunction {
    private static final String TAG = "SetShadowConfigFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (!(ctx instanceof OpenGLContext)) return null;

            OpenGLContext glCtx = (OpenGLContext) ctx;
            GLShadowRenderer renderer = glCtx.getShadowRenderer();
            if (renderer == null) return null;

            float groundY = (float) args[0].getAsDouble();
            float lightAngle = args.length > 1 ? (float) args[1].getAsDouble() : 0.0f;

            renderer.setShadowConfig(groundY, lightAngle);
        } catch (Exception e) {
            Log.e(TAG, "Error setting shadow config: " + e.getMessage());
        }
        return null;
    }
}
