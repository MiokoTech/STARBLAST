package com.miokotech.storageaccess;

import android.app.Activity;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

public class CheckUriFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            Activity activity = ctx.getActivity();
            boolean hasPerm = StoragePermissionUtils.hasStoragePermission(activity);
            return FREObject.newObject(hasPerm);
        } catch (Exception e) {
            e.printStackTrace();
            try {
                return FREObject.newObject(false);
            } catch (FREWrongThreadException ex) {
                return null;
            }
        }
    }
}
