// 2025-07-16 @MiokoTech
package com.miokotech.storageaccess;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;

public class StorageAccessExtension implements FREExtension {

    public static FREContext context;

    @Override
    public FREContext createContext(String extId) {
        context = new StorageAccessContext();
        return context;
    }

    @Override
    public void dispose() {
        context = null;
    }

    @Override
    public void initialize() {
    }
}
