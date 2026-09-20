package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class UpdateShadowFunction implements FREFunction {
    private static final String TAG = "UpdateShadowFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (!(ctx instanceof OpenGLContext)) return null;

            OpenGLContext glCtx = (OpenGLContext) ctx;
            GLShadowRenderer renderer = glCtx.getShadowRenderer();
            if (renderer == null) return null;

            int id = args[0].getAsInt();
            float x = (float) args[1].getAsDouble();
            float y = (float) args[2].getAsDouble();
            float width = (float) args[3].getAsDouble();
            float height = (float) args[4].getAsDouble();
            float scaleX = (float) args[5].getAsDouble();
            float scaleY = (float) args[6].getAsDouble();
            float skewX = (float) args[7].getAsDouble();
            float alpha = args.length > 8 ? (float) args[8].getAsDouble() : 0.5f;
            int color = args.length > 9 ? args[9].getAsInt() : 0x000000;

            renderer.updateShadow(id, x, y, width, height, scaleX, scaleY, skewX, alpha, color);
        } catch (Exception e) {
            Log.e(TAG, "Error updating shadow: " + e.getMessage());
        }
        return null;
    }
}
