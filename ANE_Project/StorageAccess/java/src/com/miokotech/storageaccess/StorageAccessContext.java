// 2025-06-16 @MiokoTech
package com.miokotech.storageaccess;

import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.util.Log;
import android.content.ContentResolver;
import android.database.Cursor;
import android.provider.DocumentsContract;

import com.adobe.air.AndroidActivityWrapper;
import com.adobe.air.AndroidActivityWrapper.ActivityResultCallback;

import com.adobe.fre.FREByteArray;
import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import com.adobe.fre.FREWrongThreadException;

import java.io.ByteArrayOutputStream;
import java.io.InputStream;
import java.util.HashMap;
import java.util.Map;

public class StorageAccessContext extends FREContext implements ActivityResultCallback {

    public static final int REQUEST_CODE = 7777;

    private AndroidActivityWrapper aaw;
    private Activity activity;

    @Override
    public void dispose() {
        if (aaw != null) {
            aaw.removeActivityResultListener(this);
        }
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        if (requestCode == REQUEST_CODE) {
            boolean hasPermission = StoragePermissionUtils.hasStoragePermission(activity != null ? activity : getActivity());
            if (hasPermission) {
                dispatchStatusEventAsync("STORAGE_PERMISSION_GRANTED", "true");
                dispatchStatusEventAsync("SAF_SELECTED", "GRANTED");
            } else {
                dispatchStatusEventAsync("STORAGE_PERMISSION_DENIED", "false");
            }
        }
    }

    @Override
    public Map<String, FREFunction> getFunctions() {
        activity = getActivity();
        aaw = AndroidActivityWrapper.GetAndroidActivityWrapper();
        if (aaw != null) {
            aaw.addActivityResultListener(this);
        }

        Map<String, FREFunction> map = new HashMap<>();
        map.put("requestStorageAccess", new RequestStorageAccessFunction());
        map.put("checkUri", new CheckUriFunction());
        map.put("hasPermission", new CheckUriFunction());
        map.put("openAppSettings", new OpenAppSettingsFunction());
        map.put("getTreeUri", new GetTreeUriFunction());
        map.put("writeJsonFile", new WriteJsonFileFunction());
        map.put("readJsonFile", new ReadJsonFileFunction());
        map.put("loadSWFBytes", new LoadSWFBytesFunction());
        return map;
    }

    class LoadSWFBytesFunction implements FREFunction {
        @Override
        public FREObject call(FREContext ctx, FREObject[] args) {
            try {
                String filename = args[0].getAsString();

                Activity act = ctx.getActivity();
                if (act == null) {
                    return null;
                }
                SharedPreferences prefs = act.getSharedPreferences("storage_access", Activity.MODE_PRIVATE);
                String uriStr = prefs.getString("tree_uri", null);
                if (uriStr == null) return null;

                Uri treeUri = Uri.parse(uriStr);
                ContentResolver resolver = act.getContentResolver();

                Uri childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri,
                        DocumentsContract.getTreeDocumentId(treeUri));

                Cursor cursor = resolver.query(childrenUri,
                        new String[]{DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                                 DocumentsContract.Document.COLUMN_DISPLAY_NAME}, null, null, null);

                if (cursor != null) {
                    while (cursor.moveToNext()) {
                        String docId = cursor.getString(0);
                        String name = cursor.getString(1);

                        if (name.equals(filename)) {
                            Uri fileUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId);
                            InputStream in = resolver.openInputStream(fileUri);

                            ByteArrayOutputStream baos = new ByteArrayOutputStream();
                            byte[] buffer = new byte[4096];
                            int len;
                            while ((len = in.read(buffer)) != -1) {
                                baos.write(buffer, 0, len);
                            }
                            in.close();
                            cursor.close();

                            byte[] swfBytes = baos.toByteArray();
                            FREObject result = FREObject.newObject("flash.utils.ByteArray", null);
                            result.setProperty("length", FREObject.newObject(swfBytes.length));

                            FREByteArray byteArray = (FREByteArray) result;
                            byteArray.acquire();
                            byteArray.getBytes().put(swfBytes);
                            byteArray.release();

                            return result;
                        }
                    }
                    cursor.close();
                }

            } catch (Exception e) {
                e.printStackTrace();
            }
            return null;
        }
    }
}
