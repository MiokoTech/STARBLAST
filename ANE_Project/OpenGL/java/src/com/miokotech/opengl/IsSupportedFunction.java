package com.miokotech.opengl;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;

public class IsSupportedFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            return FREObject.newObject(true);
        } catch (Exception e) {
            return null;
        }
    }
}
