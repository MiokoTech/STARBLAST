package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class ClearShadowsFunction implements FREFunction {
    private static final String TAG = "ClearShadowsFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (ctx instanceof OpenGLContext) {
                GLShadowRenderer renderer = ((OpenGLContext) ctx).getShadowRenderer();
                if (renderer != null) {
                    renderer.clearShadows();
                }
            }
        } catch (Exception e) {
            Log.e(TAG, "Error clearing shadows: " + e.getMessage());
        }
        return null;
    }
}
