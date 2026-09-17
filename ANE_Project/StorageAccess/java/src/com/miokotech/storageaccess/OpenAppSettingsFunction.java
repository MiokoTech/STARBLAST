package com.miokotech.storageaccess;

import android.app.Activity;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class OpenAppSettingsFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            Activity activity = ctx.getActivity();
            StoragePermissionUtils.openAppSettings(activity, StorageAccessContext.REQUEST_CODE);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
