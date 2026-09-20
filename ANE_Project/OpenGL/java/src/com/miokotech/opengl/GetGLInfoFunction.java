package com.miokotech.opengl;

import android.app.Activity;
import android.app.ActivityManager;
import android.content.Context;
import android.content.pm.ConfigurationInfo;
import android.util.Log;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class GetGLInfoFunction implements FREFunction {
    private static final String TAG = "GetGLInfoFunction";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            Activity activity = ctx.getActivity();
            String glInfo = "OpenGL ES";
            if (activity != null) {
                ActivityManager am = (ActivityManager) activity.getSystemService(Context.ACTIVITY_SERVICE);
                if (am != null) {
                    ConfigurationInfo info = am.getDeviceConfigurationInfo();
                    glInfo = "OpenGL ES Version: " + info.getGlEsVersion();
                }
            }
            return FREObject.newObject(glInfo);
        } catch (Exception e) {
            Log.e(TAG, "Error getting GL info: " + e.getMessage());
            return null;
        }
    }
}
