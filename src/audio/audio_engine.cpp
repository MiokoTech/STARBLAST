// Implementasi engine audio OpenSL ES untuk Android.
#include "audio_engine.h"
#include <android/log.h>
#include <cmath>
#include <fstream>

#define LOG_TAG "StarblastAudio"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

namespace starblast {

AudioEngine& AudioEngine::getInstance() {
    static AudioEngine instance;
    return instance;
}

AudioEngine::AudioEngine()
    : m_engineObject(nullptr)
    , m_engineEngine(nullptr)
    , m_outputMixObject(nullptr)
    , m_bgmPlayerObject(nullptr)
    , m_bgmPlay(nullptr)
    , m_bgmVolume(nullptr)
    , m_bgmSeek(nullptr)
    , m_sfxPlayerObject(nullptr)
    , m_sfxPlay(nullptr)
    , m_sfxVolume(nullptr)
    , m_volume(0.7f)
    , m_sfxVol(0.8f)
    , m_initialized(false)
{}

AudioEngine::~AudioEngine() {
    shutdown();
}

bool AudioEngine::init() {
    if (m_initialized) return true;

    SLresult result = slCreateEngine(&m_engineObject, 0, nullptr, 0, nullptr, nullptr);
    if (result != SL_RESULT_SUCCESS) {
        LOGE("Failed to create OpenSL ES engine");
        return false;
    }

    result = (*m_engineObject)->Realize(m_engineObject, SL_BOOLEAN_FALSE);
    if (result != SL_RESULT_SUCCESS) return false;

    result = (*m_engineObject)->GetInterface(m_engineObject, SL_IID_ENGINE, &m_engineEngine);
    if (result != SL_RESULT_SUCCESS) return false;

    result = (*m_engineEngine)->CreateOutputMix(m_engineEngine, &m_outputMixObject, 0, nullptr, nullptr);
    if (result != SL_RESULT_SUCCESS) return false;

    result = (*m_outputMixObject)->Realize(m_outputMixObject, SL_BOOLEAN_FALSE);
    if (result != SL_RESULT_SUCCESS) return false;

    m_initialized = true;
    LOGI("OpenSL ES AudioEngine initialized successfully");
    return true;
}

void AudioEngine::shutdown() {
    stopBgm();

    if (m_sfxPlayerObject != nullptr) {
        if (m_sfxPlay != nullptr) {
            (*m_sfxPlay)->SetPlayState(m_sfxPlay, SL_PLAYSTATE_STOPPED);
        }
        (*m_sfxPlayerObject)->Destroy(m_sfxPlayerObject);
        m_sfxPlayerObject = nullptr;
        m_sfxPlay = nullptr;
        m_sfxVolume = nullptr;
    }

    if (m_outputMixObject != nullptr) {
        (*m_outputMixObject)->Destroy(m_outputMixObject);
        m_outputMixObject = nullptr;
    }
    if (m_engineObject != nullptr) {
        (*m_engineObject)->Destroy(m_engineObject);
        m_engineObject = nullptr;
        m_engineEngine = nullptr;
    }
    m_initialized = false;
}

void AudioEngine::stopBgm() {
    if (m_bgmPlayerObject != nullptr) {
        if (m_bgmPlay != nullptr) {
            (*m_bgmPlay)->SetPlayState(m_bgmPlay, SL_PLAYSTATE_STOPPED);
        }
        (*m_bgmPlayerObject)->Destroy(m_bgmPlayerObject);
        m_bgmPlayerObject = nullptr;
        m_bgmPlay = nullptr;
        m_bgmVolume = nullptr;
        m_bgmSeek = nullptr;
    }
}

void AudioEngine::playBgm(const std::string& path, bool loop) {
    if (!m_initialized) init();
    stopBgm();

    SLDataSource audioSrc{};
    SLDataLocator_URI loc_uri{};
    SLDataLocator_AndroidFD loc_fd{};
    SLDataFormat_MIME format_mime = {SL_DATAFORMAT_MIME, nullptr, SL_CONTAINERTYPE_UNSPECIFIED};

    bool usingAsset = false;
    if (m_assetManager) {
        std::vector<std::string> tryPaths = {path};
        if (path.rfind("assets/", 0) == 0) {
            tryPaths.push_back(path.substr(7));
        } else {
            tryPaths.push_back("assets/" + path);
        }

        for (const auto& p : tryPaths) {
            AAsset* asset = AAssetManager_open(m_assetManager, p.c_str(), AASSET_MODE_UNKNOWN);
            if (asset) {
                off_t start = 0, length = 0;
                int fd = AAsset_openFileDescriptor(asset, &start, &length);
                AAsset_close(asset);
                if (fd >= 0) {
                    loc_fd = {SL_DATALOCATOR_ANDROIDFD, fd, start, length};
                    audioSrc = {&loc_fd, &format_mime};
                    usingAsset = true;
                    LOGI("Playing BGM from APK asset: %s", p.c_str());
                    break;
                }
            }
        }
    }

    if (!usingAsset) {
        loc_uri = {SL_DATALOCATOR_URI, (SLchar*)path.c_str()};
        audioSrc = {&loc_uri, &format_mime};
    }

    SLDataLocator_OutputMix loc_outmix = {SL_DATALOCATOR_OUTPUTMIX, m_outputMixObject};
    SLDataSink audioSnk = {&loc_outmix, nullptr};

    const SLInterfaceID ids[3] = {SL_IID_SEEK, SL_IID_VOLUME, SL_IID_PREFETCHSTATUS};
    const SLboolean req[3] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};

    SLresult result = (*m_engineEngine)->CreateAudioPlayer(
        m_engineEngine, &m_bgmPlayerObject, &audioSrc, &audioSnk, 3, ids, req
    );
    if (result != SL_RESULT_SUCCESS) {
        LOGE("Failed to create BGM player for: %s", path.c_str());
        return;
    }

    (*m_bgmPlayerObject)->Realize(m_bgmPlayerObject, SL_BOOLEAN_FALSE);
    (*m_bgmPlayerObject)->GetInterface(m_bgmPlayerObject, SL_IID_PLAY, &m_bgmPlay);
    (*m_bgmPlayerObject)->GetInterface(m_bgmPlayerObject, SL_IID_SEEK, &m_bgmSeek);
    (*m_bgmPlayerObject)->GetInterface(m_bgmPlayerObject, SL_IID_VOLUME, &m_bgmVolume);

    if (m_bgmSeek != nullptr && loop) {
        (*m_bgmSeek)->SetLoop(m_bgmSeek, SL_BOOLEAN_TRUE, 0, SL_TIME_UNKNOWN);
    }

    setBgmVolume(m_volume);

    if (m_bgmPlay != nullptr) {
        (*m_bgmPlay)->SetPlayState(m_bgmPlay, SL_PLAYSTATE_PLAYING);
        LOGI("Playing BGM: %s", path.c_str());
    }
}

void AudioEngine::setBgmVolume(float volume) {
    m_volume = std::max(0.0f, std::min(1.0f, volume));
    if (m_bgmVolume != nullptr) {
        SLmillibel mb;
        if (m_volume <= 0.001f) {
            mb = SL_MILLIBEL_MIN;
        } else {
            mb = static_cast<SLmillibel>(2000.0f * std::log10(m_volume));
            if (mb < -4000) mb = -4000;
        }
        (*m_bgmVolume)->SetVolumeLevel(m_bgmVolume, mb);
    }
}

void AudioEngine::playSfx(const std::string& path, float volume) {
    if (!m_initialized) init();

    if (m_sfxPlayerObject != nullptr) {
        if (m_sfxPlay != nullptr) {
            (*m_sfxPlay)->SetPlayState(m_sfxPlay, SL_PLAYSTATE_STOPPED);
        }
        (*m_sfxPlayerObject)->Destroy(m_sfxPlayerObject);
        m_sfxPlayerObject = nullptr;
        m_sfxPlay = nullptr;
        m_sfxVolume = nullptr;
    }

    SLDataFormat_MIME format_mime = {
        SL_DATAFORMAT_MIME, nullptr, SL_CONTAINERTYPE_UNSPECIFIED
    };
    SLDataLocator_AndroidFD loc_fd;
    SLDataLocator_URI loc_uri;
    SLDataSource audioSrc;

    bool usingAsset = false;
    if (m_assetManager) {
        std::vector<std::string> tryPaths = {path};
        if (path.rfind("assets/", 0) == 0) {
            tryPaths.push_back(path.substr(7));
        } else {
            tryPaths.push_back("assets/" + path);
        }

        for (const auto& p : tryPaths) {
            AAsset* asset = AAssetManager_open(m_assetManager, p.c_str(), AASSET_MODE_UNKNOWN);
            if (asset) {
                off_t start = 0, length = 0;
                int fd = AAsset_openFileDescriptor(asset, &start, &length);
                AAsset_close(asset);
                if (fd >= 0) {
                    loc_fd = {SL_DATALOCATOR_ANDROIDFD, fd, start, length};
                    audioSrc = {&loc_fd, &format_mime};
                    usingAsset = true;
                    break;
                }
            }
        }
    }

    if (!usingAsset) {
        std::string fullPath = path;
        std::ifstream test(fullPath);
        if (!test.is_open()) {
            fullPath = "/sdcard/MiokoTech/STARBLAST/" + path;
        }
        loc_uri = {SL_DATALOCATOR_URI, (SLchar*)fullPath.c_str()};
        audioSrc = {&loc_uri, &format_mime};
    }

    SLDataLocator_OutputMix loc_outmix = {SL_DATALOCATOR_OUTPUTMIX, m_outputMixObject};
    SLDataSink audioSnk = {&loc_outmix, nullptr};

    const SLInterfaceID ids[2] = {SL_IID_VOLUME, SL_IID_PREFETCHSTATUS};
    const SLboolean req[2] = {SL_BOOLEAN_TRUE, SL_BOOLEAN_TRUE};

    SLresult result = (*m_engineEngine)->CreateAudioPlayer(
        m_engineEngine, &m_sfxPlayerObject, &audioSrc, &audioSnk, 2, ids, req
    );
    if (result != SL_RESULT_SUCCESS) return;

    (*m_sfxPlayerObject)->Realize(m_sfxPlayerObject, SL_BOOLEAN_FALSE);
    (*m_sfxPlayerObject)->GetInterface(m_sfxPlayerObject, SL_IID_PLAY, &m_sfxPlay);
    (*m_sfxPlayerObject)->GetInterface(m_sfxPlayerObject, SL_IID_VOLUME, &m_sfxVolume);

    float vol = std::max(0.0f, std::min(1.0f, volume));
    if (m_sfxVolume != nullptr) {
        SLmillibel mb = (vol <= 0.001f) ? SL_MILLIBEL_MIN : static_cast<SLmillibel>(2000.0f * std::log10(vol));
        if (mb < -4000) mb = -4000;
        (*m_sfxVolume)->SetVolumeLevel(m_sfxVolume, mb);
    }

    if (m_sfxPlay != nullptr) {
        (*m_sfxPlay)->SetPlayState(m_sfxPlay, SL_PLAYSTATE_PLAYING);
    }
}

}
