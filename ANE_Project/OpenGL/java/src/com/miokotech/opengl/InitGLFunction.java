package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class InitGLFunction implements FREFunction {
    private static final String TAG = "InitGLFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (ctx instanceof OpenGLContext) {
                boolean success = ((OpenGLContext) ctx).createShadowView();
                return FREObject.newObject(success);
            }
            return FREObject.newObject(false);
        } catch (Exception e) {
            Log.e(TAG, "Error initializing GL: " + e.getMessage());
            return null;
        }
    }
}
