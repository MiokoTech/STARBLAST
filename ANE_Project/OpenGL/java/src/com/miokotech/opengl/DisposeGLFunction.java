package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class DisposeGLFunction implements FREFunction {
    private static final String TAG = "DisposeGLFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (ctx instanceof OpenGLContext) {
                ((OpenGLContext) ctx).dispose();
            }
        } catch (Exception e) {
            Log.e(TAG, "Error disposing GL: " + e.getMessage());
        }
        return null;
    }
}
