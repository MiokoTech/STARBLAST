package com.miokotech.audioroute;

import com.adobe.fre.FREContext;
import com.adobe.fre.FREFunction;
import com.adobe.fre.FREObject;
import android.media.AudioAttributes;
import android.media.AudioFormat;
import android.media.AudioManager;
import android.media.AudioTrack;
import android.util.Log;

class InitAudioFunction implements FREFunction {
    @Override
    public FREObject call(FREContext ctx, FREObject[] args) {
        try {
            AudioAttributes attrs = new AudioAttributes.Builder()
                .setUsage(AudioAttributes.USAGE_GAME)
                .setContentType(AudioAttributes.CONTENT_TYPE_MUSIC)
                .build();

            int sampleRate = 44100;
            int bufferSize = AudioTrack.getMinBufferSize(
                sampleRate,
                android.media.AudioFormat.CHANNEL_OUT_STEREO,
                android.media.AudioFormat.ENCODING_PCM_16BIT
            );

            AudioTrack track = new AudioTrack(
                attrs,
                new android.media.AudioFormat.Builder()
                    .setEncoding(android.media.AudioFormat.ENCODING_PCM_16BIT)
                    .setSampleRate(sampleRate)
                    .setChannelMask(android.media.AudioFormat.CHANNEL_OUT_STEREO)
                    .build(),
                bufferSize,
                AudioTrack.MODE_STREAM,
                AudioManager.AUDIO_SESSION_ID_GENERATE
            );

            track.play();

            Log.d("GameAudioANE", "AudioTrack initialized with USAGE_GAME");
        } catch (Exception e) {
            Log.e("GameAudioANE", "Error initAudio: " + e.getMessage());
        }

        return null;
    }
}
