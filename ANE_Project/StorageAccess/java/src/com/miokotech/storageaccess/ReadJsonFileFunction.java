// 2025-07-16 @MiokoTech

package com.miokotech.storageaccess;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.provider.DocumentsContract;

import com.adobe.fre.*;

import java.io.InputStream;
import java.io.InputStreamReader;
import java.io.BufferedReader;

public class ReadJsonFileFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (args.length < 1) return FREObject.newObject("");

            String fileName = args[0].getAsString();

            Activity activity = ctx.getActivity();
            SharedPreferences prefs = activity.getSharedPreferences("storage_access", Activity.MODE_PRIVATE);
            String uriStr = prefs.getString("starblast_uri", null);
            if (uriStr == null) return FREObject.newObject("");

            Uri folderUri = Uri.parse(uriStr);
            ContentResolver resolver = activity.getContentResolver();

            String docId = DocumentsContract.getDocumentId(folderUri);
            Uri childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(folderUri, docId);

            Uri fileUri = null;
            Cursor cursor = resolver.query(childrenUri,
                    new String[]{DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                                 DocumentsContract.Document.COLUMN_DISPLAY_NAME},
                    null, null, null);

            if (cursor != null) {
                while (cursor.moveToNext()) {
                    String name = cursor.getString(1);
                    if (fileName.equals(name)) {
                        String childDocId = cursor.getString(0);
                        fileUri = DocumentsContract.buildDocumentUriUsingTree(folderUri, childDocId);
                        break;
                    }
                }
                cursor.close();
            }

            if (fileUri == null) return FREObject.newObject("");

            InputStream in = resolver.openInputStream(fileUri);
            BufferedReader reader = new BufferedReader(new InputStreamReader(in, "UTF-8"));
            StringBuilder result = new StringBuilder();
            String line;
            while ((line = reader.readLine()) != null) {
                result.append(line).append("\n");
            }
            reader.close();
            in.close();

            return FREObject.newObject(result.toString().trim());

        } catch (Exception e) {
            e.printStackTrace();
            try {
                return FREObject.newObject("");
            } catch (FREWrongThreadException freError) {
                return null;
            }
        }
    }
}
