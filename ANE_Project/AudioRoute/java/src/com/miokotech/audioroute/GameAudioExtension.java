package com.miokotech.audioroute;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREExtension;
import android.util.Log;

public class GameAudioExtension implements FREExtension {
    public static final String TAG = "GameAudioANE";

    @Override
    public void initialize() {
        Log.d(TAG, "GameAudioExtension initialize");
    }

    @Override
    public FREContext createContext(String extId) {
        return new GameAudioContext();
    }

    @Override
    public void dispose() {
        Log.d(TAG, "GameAudioExtension dispose");
    }
}
