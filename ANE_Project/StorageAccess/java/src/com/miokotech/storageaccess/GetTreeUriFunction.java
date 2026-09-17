package com.miokotech.storageaccess;

import android.app.Activity;
import android.content.SharedPreferences;

import com.adobe.fre.*;

public class GetTreeUriFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        Activity activity = ctx.getActivity();
        SharedPreferences prefs = activity.getSharedPreferences("storage_access", Activity.MODE_PRIVATE);
        String uri = prefs.getString("tree_uri", "");
        try {
            return FREObject.newObject(uri);
        } catch (Exception e) {
            return null;
        }
    }
}
