#include "android_native_app_glue.h"
#include <android/log.h>
#include <unistd.h>
#include <chrono>
#include <memory>

#include "gl_renderer.h"
#include "sprite_renderer.h"
#include "virtual_pad.h"
#include "audio_engine.h"
#include "character_runtime.h"
#include "state_manager.h"
#include "splash_state.h"
#include "title_state.h"
#include "texture_manager.h"

#define LOG_TAG "StarblastNative"
#define LOGI(...) __android_log_print(ANDROID_LOG_INFO, LOG_TAG, __VA_ARGS__)
#define LOGE(...) __android_log_print(ANDROID_LOG_ERROR, LOG_TAG, __VA_ARGS__)

struct EngineState {
    struct android_app* app;
    starblast::GLRenderer renderer;
    starblast::SpriteRenderer spriteRenderer;
    starblast::VirtualPad pad;
    bool animating;
    bool initialized;
};

static int32_t engine_handle_input(struct android_app* app, AInputEvent* event) {
    auto* engine = static_cast<EngineState*>(app->userData);
    if (!engine) return 0;

    return engine->pad.handleInput(event) ? 1 : 0;
}

static void engine_handle_cmd(struct android_app* app, int32_t cmd) {
    auto* engine = static_cast<EngineState*>(app->userData);
    if (!engine) return;

    switch (cmd) {
        case APP_CMD_INIT_WINDOW:
            if (app->window != nullptr) {
                if (engine->renderer.initEGL(app->window)) {
                    int w = ANativeWindow_getWidth(app->window);
                    int h = ANativeWindow_getHeight(app->window);
                    engine->pad.setScreenSize(w, h);
                    engine->spriteRenderer.init();
                    engine->spriteRenderer.setViewport(engine->renderer.getViewportW(), engine->renderer.getViewportH());
                    engine->animating = true;
                    engine->initialized = true;

                    starblast::StateManager::getInstance().changeState(
                        std::make_shared<starblast::SplashState>(&engine->spriteRenderer, &engine->pad)
                    );

                    LOGI("Window initialized (%dx%d), started SplashState", w, h);
                }
            }
            break;

        case APP_CMD_TERM_WINDOW:
            engine->animating = false;
            engine->spriteRenderer.destroy();
            engine->renderer.destroyEGL();
            starblast::AudioEngine::getInstance().stopBgm();
            LOGI("Window terminated");
            break;

        case APP_CMD_GAINED_FOCUS:
            engine->animating = true;
            break;

        case APP_CMD_LOST_FOCUS:
            engine->animating = false;
            break;

        case APP_CMD_WINDOW_RESIZED:
            if (app->window != nullptr) {
                int w = ANativeWindow_getWidth(app->window);
                int h = ANativeWindow_getHeight(app->window);
                engine->renderer.resize(w, h);
                engine->spriteRenderer.setViewport(engine->renderer.getViewportW(), engine->renderer.getViewportH());
                engine->pad.setScreenSize(w, h);
            }
            break;
    }
}

void android_main(struct android_app* state) {
    LOGI(">>> STARBLAST Pure C++ Native Engine Starting <<<");

    EngineState engine{};
    engine.app = state;
    engine.animating = false;
    engine.initialized = false;

    starblast::AudioEngine::getInstance().init();

    if (state->activity && state->activity->assetManager) {
        starblast::TextureManager::getInstance().setAssetManager(state->activity->assetManager);
        starblast::AudioEngine::getInstance().setAssetManager(state->activity->assetManager);
    }

    state->userData = &engine;
    state->onAppCmd = engine_handle_cmd;
    state->onInputEvent = engine_handle_input;

    constexpr double FIXED_TIMESTEP = 1.0 / 60.0;
    auto lastTime = std::chrono::steady_clock::now();
    double accumulator = 0.0;

    while (true) {
        int ident;
        int events;
        struct android_poll_source* source;

        while ((ident = ALooper_pollOnce(engine.animating ? 0 : -1, nullptr, &events, (void**)&source)) >= 0) {
            if (source != nullptr) {
                source->process(state, source);
            }

            if (state->destroyRequested != 0) {
                LOGI("Destroy requested, exiting native loop");
                engine.spriteRenderer.destroy();
                engine.renderer.destroyEGL();
                starblast::AudioEngine::getInstance().shutdown();
                return;
            }
        }

        if (engine.animating && engine.initialized) {
            auto currentTime = std::chrono::steady_clock::now();
            double frameTime = std::chrono::duration<double>(currentTime - lastTime).count();
            lastTime = currentTime;

            if (frameTime > 0.1) frameTime = 0.1;
            accumulator += frameTime;

            while (accumulator >= FIXED_TIMESTEP) {
                starblast::StateManager::getInstance().update(static_cast<float>(FIXED_TIMESTEP));
                accumulator -= FIXED_TIMESTEP;
            }

            engine.renderer.beginFrame();

            starblast::StateManager::getInstance().render();

            uint32_t mask = engine.pad.getMask();
            float dpadR = (mask & (starblast::BTN_UP | starblast::BTN_DOWN | starblast::BTN_LEFT | starblast::BTN_RIGHT)) ? 0.3f : 0.15f;
            engine.renderer.drawQuad(180 - 65, 540 - 65, 130, 130, dpadR, 0.6f, 0.9f, 0.4f);

            float jR = (mask & starblast::BTN_ATTACK) ? 0.9f : 0.3f;
            engine.renderer.drawQuad(1020 - 35, 580 - 35, 70, 70, jR, 0.4f, 0.4f, 0.5f);

            float kR = (mask & starblast::BTN_JUMP) ? 0.9f : 0.3f;
            engine.renderer.drawQuad(1140 - 35, 580 - 35, 70, 70, 0.4f, kR, 0.4f, 0.5f);

            engine.renderer.endFrame();
        }
    }
}
