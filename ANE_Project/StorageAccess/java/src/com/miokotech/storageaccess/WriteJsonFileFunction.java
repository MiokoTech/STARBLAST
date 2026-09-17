package com.miokotech.storageaccess;

import android.app.Activity;
import android.content.SharedPreferences;
import android.content.ContentResolver;
import android.database.Cursor;
import android.net.Uri;
import android.provider.DocumentsContract;

import com.adobe.fre.*;

import java.io.OutputStream;
import java.nio.charset.StandardCharsets;

public class WriteJsonFileFunction implements FREFunction {
    private static final String TAG = "WriteJsonFile";

    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            if (args.length < 2) return FREObject.newObject(false);

            String fileName = args[0].getAsString();
            String jsonContent = args[1].getAsString();

            Activity activity = ctx.getActivity();
            SharedPreferences prefs = activity.getSharedPreferences("storage_access", Activity.MODE_PRIVATE);
            String uriStr = prefs.getString("starblast_uri", null);
            if (uriStr == null) return FREObject.newObject(false);

            Uri treeUri = Uri.parse(uriStr);
            ContentResolver resolver = activity.getContentResolver();

            Uri starblastFolderUri = findStarblastFolder(resolver, treeUri);
            if (starblastFolderUri == null) {
                return FREObject.newObject(false);
            }

            String starblastDocId = DocumentsContract.getDocumentId(starblastFolderUri);
            Uri childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, starblastDocId);

            Uri targetUri = null;

            Cursor cursor = resolver.query(childrenUri,
                new String[] {
                    DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                    DocumentsContract.Document.COLUMN_DISPLAY_NAME
                },
                null, null, null);

            if (cursor != null) {
                try {
                    while (cursor.moveToNext()) {
                        String docId = cursor.getString(0);
                        String name = cursor.getString(1);
                        if (fileName.equals(name)) {
                            targetUri = DocumentsContract.buildDocumentUriUsingTree(treeUri, docId);
                            break;
                        }
                    }
                } finally {
                    cursor.close();
                }
            }

            if (targetUri == null) {
                targetUri = DocumentsContract.createDocument(
                    resolver,
                    starblastFolderUri,
                    "application/json",
                    fileName
                );
            }

            if (targetUri != null) {
                OutputStream out = resolver.openOutputStream(targetUri, "w");
                if (out != null) {
                    out.write(jsonContent.getBytes("UTF-8"));
                    out.flush();
                    out.close();
                    return FREObject.newObject(true);
                }
            }

        } catch (Exception e) {
        }

        try {
            return FREObject.newObject(false);
        } catch (FREWrongThreadException e) {
            return null;
        }
    }

    private Uri findStarblastFolder(ContentResolver resolver, Uri treeUri) {
        String parentDocId = DocumentsContract.getTreeDocumentId(treeUri);
        Uri childrenUri = DocumentsContract.buildChildDocumentsUriUsingTree(treeUri, parentDocId);

        Cursor cursor = resolver.query(childrenUri,
            new String[] {
                DocumentsContract.Document.COLUMN_DOCUMENT_ID,
                DocumentsContract.Document.COLUMN_DISPLAY_NAME
            },
            null, null, null);

        if (cursor != null) {
            try {
                while (cursor.moveToNext()) {
                    String docId = cursor.getString(0);
                    String name = cursor.getString(1);
                    if ("STARBLAST".equals(name)) {
                        return DocumentsContract.buildDocumentUriUsingTree(treeUri, docId);
                    }
                }
            } finally {
                cursor.close();
            }
        }

        return null;
    }
}
