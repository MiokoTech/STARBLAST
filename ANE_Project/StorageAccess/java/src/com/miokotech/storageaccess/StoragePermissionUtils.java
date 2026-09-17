package com.miokotech.storageaccess;

import android.app.Activity;
import android.content.Intent;
import android.content.pm.PackageManager;
import android.net.Uri;
import android.os.Build;
import android.os.Environment;
import android.provider.Settings;

public class StoragePermissionUtils {

    public static boolean hasStoragePermission(Activity activity) {
        if (activity == null) {
            return false;
        }
        // Android 11+ (API 30+) requires MANAGE_EXTERNAL_STORAGE for direct file access
        if (Build.VERSION.SDK_INT >= 30) {
            return Environment.isExternalStorageManager();
        }
        // Android 6.0 - 10 (API 23 - 29) requires runtime READ/WRITE permission
        if (Build.VERSION.SDK_INT >= 23) {
            int readPerm = activity.checkSelfPermission("android.permission.READ_EXTERNAL_STORAGE");
            int writePerm = activity.checkSelfPermission("android.permission.WRITE_EXTERNAL_STORAGE");
            return readPerm == PackageManager.PERMISSION_GRANTED && writePerm == PackageManager.PERMISSION_GRANTED;
        }
        return true;
    }

    public static void requestStoragePermission(Activity activity, int requestCode) {
        if (activity == null) {
            return;
        }
        // Android 11+ (API 30+): Direct user to "All Files Access" / "Kelola Semua File" settings page
        if (Build.VERSION.SDK_INT >= 30) {
            try {
                Intent intent = new Intent(Settings.ACTION_MANAGE_APP_ALL_FILES_ACCESS_PERMISSION);
                intent.setData(Uri.parse("package:" + activity.getPackageName()));
                activity.startActivityForResult(intent, requestCode);
                return;
            } catch (Exception e) {
                try {
                    Intent fallbackIntent = new Intent(Settings.ACTION_MANAGE_ALL_FILES_ACCESS_PERMISSION);
                    activity.startActivityForResult(fallbackIntent, requestCode);
                    return;
                } catch (Exception ex) {
                    openAppSettings(activity, requestCode);
                    return;
                }
            }
        }
        // Android 6.0 - 10 (API 23 - 29): Request runtime permissions or open app settings
        if (Build.VERSION.SDK_INT >= 23) {
            try {
                activity.requestPermissions(
                    new String[]{
                        "android.permission.READ_EXTERNAL_STORAGE",
                        "android.permission.WRITE_EXTERNAL_STORAGE"
                    },
                    requestCode
                );
            } catch (Exception e) {
                openAppSettings(activity, requestCode);
            }
        }
    }

    public static void openAppSettings(Activity activity, int requestCode) {
        if (activity == null) {
            return;
        }
        try {
            Intent intent = new Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS);
            intent.setData(Uri.parse("package:" + activity.getPackageName()));
            activity.startActivityForResult(intent, requestCode);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
