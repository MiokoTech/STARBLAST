package com.miokotech.audioroute;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import java.util.HashMap;
import java.util.Map;

public class GameAudioContext extends FREContext {

    @Override
    public void dispose() {
    }

    @Override
    public Map<String, FREFunction> getFunctions() {
        Map<String, FREFunction> map = new HashMap<String, FREFunction>();
        map.put("initAudio", new InitAudioFunction());
        return map;
    }
}
