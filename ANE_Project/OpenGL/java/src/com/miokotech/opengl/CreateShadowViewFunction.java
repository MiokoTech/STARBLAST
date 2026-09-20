package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class CreateShadowViewFunction implements FREFunction {
    private static final String TAG = "CreateShadowViewFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (ctx instanceof OpenGLContext) {
                boolean created = ((OpenGLContext) ctx).createShadowView();
                return FREObject.newObject(created);
            }
            return FREObject.newObject(false);
        } catch (Exception e) {
            Log.e(TAG, "Error creating shadow view: " + e.getMessage());
            return null;
        }
    }
}
