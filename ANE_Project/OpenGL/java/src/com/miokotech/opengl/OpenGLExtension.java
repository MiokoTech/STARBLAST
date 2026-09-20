package com.miokotech.opengl;

import android.util.Log;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class OpenGLExtension implements FREExtension {
    public static final String TAG = "GameOpenGLANE";

    @Override
    public void initialize() {
        Log.d(TAG, "OpenGLExtension initialized");
    }

    @Override
    public FREContext createContext(String extId) {
        return new OpenGLContext();
    }

    @Override
    public void dispose() {
        Log.d(TAG, "OpenGLExtension disposed");
    }
}
