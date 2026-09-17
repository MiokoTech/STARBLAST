package com.miokotech.storageaccess;

import android.app.Activity;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class RequestStorageAccessFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            Activity activity = ctx.getActivity();
            if (activity == null) {
                return null;
            }
            if (StoragePermissionUtils.hasStoragePermission(activity)) {
                if (ctx != null) {
                    ctx.dispatchStatusEventAsync("STORAGE_PERMISSION_GRANTED", "true");
                    ctx.dispatchStatusEventAsync("SAF_SELECTED", "GRANTED");
                }
                return null;
            }
            StoragePermissionUtils.requestStoragePermission(activity, StorageAccessContext.REQUEST_CODE);
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }
}
