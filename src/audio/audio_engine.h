// Manager audio dan efek suara OpenSL ES.
#ifndef STARBLAST_AUDIO_ENGINE_H
#define STARBLAST_AUDIO_ENGINE_H

#include <SLES/OpenSLES.h>
#include <SLES/OpenSLES_Android.h>
#include <android/asset_manager.h>
#include <string>
#include <unordered_map>
#include <vector>

namespace starblast {

class AudioEngine {
public:
    static AudioEngine& getInstance();

    void setAssetManager(AAssetManager* mgr) { m_assetManager = mgr; }
    AAssetManager* getAssetManager() const { return m_assetManager; }

    bool init();
    void shutdown();

    void playBgm(const std::string& path, bool loop = true);
    void stopBgm();
    void setBgmVolume(float volume);

    void playSfx(const std::string& path, float volume = 1.0f);

private:
    AudioEngine();
    ~AudioEngine();

    SLObjectItf m_engineObject;
    SLEngineItf m_engineEngine;
    SLObjectItf m_outputMixObject;

    SLObjectItf m_bgmPlayerObject;
    SLPlayItf m_bgmPlay;
    SLVolumeItf m_bgmVolume;
    SLSeekItf m_bgmSeek;

    SLObjectItf m_sfxPlayerObject;
    SLPlayItf m_sfxPlay;
    SLVolumeItf m_sfxVolume;

    float m_volume;
    float m_sfxVol;
    bool m_initialized;
    AAssetManager* m_assetManager = nullptr;
};

}

#endif
