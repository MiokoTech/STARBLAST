#include "menu_state.h"
#include "select_state.h"
#include "title_state.h"
#include "state_manager.h"
#include "sprite_renderer.h"
#include "pad_manager.h"
#include "audio_engine.h"
#include "texture_manager.h"
#include "menu_pak.h"
#include <fstream>
#include <sstream>
#include <cmath>
#include <algorithm>
#include <cstdlib>

namespace starblast {

MenuState::MenuState(SpriteRenderer* renderer, PadManager* pad)
    : m_renderer(renderer)
    , m_pad(pad ? pad : &PadManager::getInstance())
    , m_curMode(0)
    , m_prevMode(0)
    , m_animTime(0.0f)
    , m_inputCooldown(0.0f)
    , m_lastMask(0)
    , m_lastTouched(false)
    , m_titleBreathTimer(0.0f)
    , m_arrowFloatTimer(0.0f)
    , m_arrowUpScale(1.0f)
    , m_arrowDnScale(1.0f)
    , m_titleSlideY(0.0f)
    , m_titleAlpha(1.0f)
    , m_prevTitleSlideY(0.0f)
    , m_prevTitleAlpha(0.0f)
    , m_previewSlideX(0.0f)
    , m_previewAlpha(1.0f)
    , m_prevPreviewAlpha(0.0f)
    , m_inSubmenu(false)
    , m_subCursor(0)
    , m_subSlideX(0.0f)
    , m_subAlpha(0.0f)
    , m_inOptions(false)
    , m_optCursor(0)
    , m_optAlpha(0.0f)
    , m_bgmVol(0.7f)
    , m_sfxVol(0.8f)
    , m_difficulty(2)
    , m_fightTime(60)
    , m_rounds(2)
    , m_inCredits(false)
    , m_creditsAlpha(0.0f)
    , m_inExitDialog(false)
    , m_exitCursor(1)
    , m_exitAlpha(0.0f)
    , m_transitioning(false)
    , m_transitionToTitle(false)
    , m_targetGameMode(20)
    , m_fadeAlpha(1.0f)
{
    m_menuPak = std::make_unique<MenuPak>();
}

MenuState::~MenuState() = default;

void MenuState::onEnter() {
    m_curMode = 0;
    m_prevMode = 0;
    m_animTime = 0.0f;
    m_inputCooldown = 0.35f;
    m_lastMask = 0;
    m_lastTouched = false;
    m_titleBreathTimer = 0.0f;
    m_arrowFloatTimer = 0.0f;
    m_arrowUpScale = 1.0f;
    m_arrowDnScale = 1.0f;
    m_titleSlideY = 0.0f;
    m_titleAlpha = 1.0f;
    m_prevTitleSlideY = 0.0f;
    m_prevTitleAlpha = 0.0f;
    m_previewSlideX = 0.0f;
    m_previewAlpha = 1.0f;
    m_prevPreviewAlpha = 0.0f;

    m_inSubmenu = false;
    m_subCursor = 0;
    m_subSlideX = 0.0f;
    m_subAlpha = 0.0f;

    m_inOptions = false;
    m_optCursor = 0;
    m_optAlpha = 0.0f;

    m_inCredits = false;
    m_creditsAlpha = 0.0f;

    m_inExitDialog = false;
    m_exitCursor = 1;
    m_exitAlpha = 0.0f;

    m_transitioning = false;
    m_transitionToTitle = false;
    m_targetGameMode = 20;
    m_fadeAlpha = 1.0f;

    loadOptionsConfig();

    if (m_pad) {
        m_pad->setMode(PadMode::MENU);
    }

    m_menuPak->load("data/menu.pak", TextureManager::getInstance().getAssetManager());
    AudioEngine::getInstance().setBgmVolume(m_bgmVol);
    AudioEngine::getInstance().playBgm("sound/loading.ogg", true);
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_01.mp3", m_sfxVol);
}

void MenuState::loadOptionsConfig() {
    std::ifstream file("assets/data/options.conf");
    if (!file.is_open()) {
        file.open("/sdcard/MiokoTech/STARBLAST/assets/data/options.conf");
    }
    if (file.is_open()) {
        std::string line;
        while (std::getline(file, line)) {
            while (!line.empty() && (line.back() == '\r' || line.back() == ' ' || line.back() == '\t')) {
                line.pop_back();
            }
            size_t commentPos = line.find('#');
            if (commentPos != std::string::npos) {
                line = line.substr(0, commentPos);
            }
            size_t eqPos = line.find('=');
            if (eqPos != std::string::npos) {
                std::string key = line.substr(0, eqPos);
                std::string val = line.substr(eqPos + 1);
                key.erase(0, key.find_first_not_of(" \t"));
                key.erase(key.find_last_not_of(" \t") + 1);
                val.erase(0, val.find_first_not_of(" \t"));
                val.erase(val.find_last_not_of(" \t") + 1);

                if (key == "bgm_volume") {
                    try { m_bgmVol = std::stof(val); } catch (...) {}
                } else if (key == "sound_volume") {
                    try { m_sfxVol = std::stof(val); } catch (...) {}
                } else if (key == "difficulty") {
                    try { m_difficulty = std::stoi(val); } catch (...) {}
                } else if (key == "fight_time") {
                    try { m_fightTime = std::stoi(val); } catch (...) {}
                } else if (key == "rounds") {
                    try { m_rounds = std::stoi(val); } catch (...) {}
                }
            }
        }
    }
}

void MenuState::saveOptionsConfig() {
    std::string outPath = "assets/data/options.conf";
    std::ofstream out(outPath);
    if (!out.is_open()) {
        out.open("/sdcard/MiokoTech/STARBLAST/assets/data/options.conf");
    }
    if (out.is_open()) {
        out << "[settings]\n";
        out << "sound_volume = " << m_sfxVol << "\n";
        out << "bgm_volume = " << m_bgmVol << "\n\n";
        out << "[config]\n";
        out << "difficulty = " << m_difficulty << "\n";
        out << "rounds = " << m_rounds << "\n";
        out << "fight_time = " << m_fightTime << "\n";
    }
}

void MenuState::setMode(int newMode, bool isDown) {
    if (newMode == m_curMode) return;

    m_prevMode = m_curMode;
    m_curMode = newMode;

    if (isDown) {
        m_arrowDnScale = 1.35f;
    } else {
        m_arrowUpScale = 1.35f;
    }

    m_prevTitleSlideY = 0.0f;
    m_prevTitleAlpha = 1.0f;
    m_titleSlideY = isDown ? 35.0f : -35.0f;
    m_titleAlpha = 0.0f;

    m_prevPreviewAlpha = 1.0f;
    m_previewSlideX = 30.0f;
    m_previewAlpha = 0.0f;

    m_inputCooldown = 0.22f;

    static const int voiceMap[6] = {1, 2, 3, 6, 4, 5};
    int voiceIdx = voiceMap[m_curMode];
    std::string voicePath = "sound/menu/menu_snd_0" + std::to_string(voiceIdx) + ".mp3";
    AudioEngine::getInstance().playSfx(voicePath, m_sfxVol);
}

void MenuState::openSubmenu(int mode) {
    m_inSubmenu = true;
    m_subCursor = 0;
    m_subSlideX = 40.0f;
    m_subAlpha = 0.0f;
    m_subItems.clear();

    if (mode == 0) {
        m_subItems.push_back({"SINGLE ARCADE", "CLASSIC TOURNAMENT", 20});
        m_subItems.push_back({"SURVIVAL MODE", "ENDLESS ENEMY WAVES", 30});
        m_subItems.push_back({"MUSOU BATTLE", "MASS HORDE ASSAULT", 100});
    } else if (mode == 1) {
        m_subItems.push_back({"VS CPU", "1-PLAYER VERSUS AI", 10});
        m_subItems.push_back({"CPU WATCH", "CPU COMBAT OBSERVER", 11});
        m_subItems.push_back({"VS PEOPLE", "LOCAL 2-PLAYER BATTLE", 21});
    }
    m_inputCooldown = 0.25f;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_01.mp3", m_sfxVol);
}

void MenuState::closeSubmenu() {
    m_inSubmenu = false;
    m_inputCooldown = 0.2f;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_05.mp3", m_sfxVol);
}

void MenuState::confirmSubmenu() {
    if (m_subCursor < 0 || m_subCursor >= static_cast<int>(m_subItems.size())) return;
    m_targetGameMode = m_subItems[m_subCursor].gameMode;
    m_transitioning = true;
    m_transitionToTitle = false;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_02.mp3", m_sfxVol);
}

void MenuState::openOptions() {
    m_inOptions = true;
    m_optCursor = 0;
    m_optAlpha = 0.0f;
    m_inputCooldown = 0.25f;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_06.mp3", m_sfxVol);
}

void MenuState::closeOptions() {
    m_inOptions = false;
    m_inputCooldown = 0.2f;
    saveOptionsConfig();
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_05.mp3", m_sfxVol);
}

void MenuState::openCredits() {
    m_inCredits = true;
    m_creditsAlpha = 0.0f;
    m_inputCooldown = 0.25f;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_04.mp3", m_sfxVol);
}

void MenuState::closeCredits() {
    m_inCredits = false;
    m_inputCooldown = 0.2f;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_05.mp3", m_sfxVol);
}

void MenuState::openExitDialog() {
    m_inExitDialog = true;
    m_exitCursor = 1;
    m_exitAlpha = 0.0f;
    m_inputCooldown = 0.25f;
    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_05.mp3", m_sfxVol);
}

void MenuState::closeExitDialog() {
    m_inExitDialog = false;
    m_inputCooldown = 0.2f;
}

void MenuState::confirmSelection() {
    if (m_transitioning) return;

    if (m_curMode == 0) {
        openSubmenu(0);
    } else if (m_curMode == 1) {
        openSubmenu(1);
    } else if (m_curMode == 2) {
        m_targetGameMode = 40;
        m_transitioning = true;
        m_transitionToTitle = false;
        AudioEngine::getInstance().playSfx("sound/menu/menu_snd_03.mp3", m_sfxVol);
    } else if (m_curMode == 3) {
        openOptions();
    } else if (m_curMode == 4) {
        openCredits();
    } else if (m_curMode == 5) {
        openExitDialog();
    }
}

void MenuState::goBack() {
    if (m_transitioning) return;

    if (m_inOptions) {
        closeOptions();
    } else if (m_inCredits) {
        closeCredits();
    } else if (m_inExitDialog) {
        closeExitDialog();
    } else if (m_inSubmenu) {
        closeSubmenu();
    } else {
        m_transitioning = true;
        m_transitionToTitle = true;
        AudioEngine::getInstance().playSfx("sound/menu/menu_snd_05.mp3", m_sfxVol);
    }
}

void MenuState::update(float dt) {
    m_animTime += dt;
    m_titleBreathTimer += dt;
    m_arrowFloatTimer += dt;

    if (m_inputCooldown > 0.0f) {
        m_inputCooldown -= dt;
    }

    m_arrowUpScale = std::max(1.0f, m_arrowUpScale - dt * 2.0f);
    m_arrowDnScale = std::max(1.0f, m_arrowDnScale - dt * 2.0f);

    m_titleSlideY += (0.0f - m_titleSlideY) * std::min(1.0f, dt * 10.0f);
    m_titleAlpha = std::min(1.0f, m_titleAlpha + dt * 6.0f);
    m_prevTitleAlpha = std::max(0.0f, m_prevTitleAlpha - dt * 8.0f);

    m_previewSlideX += (0.0f - m_previewSlideX) * std::min(1.0f, dt * 8.0f);
    m_previewAlpha = std::min(1.0f, m_previewAlpha + dt * 5.0f);
    m_prevPreviewAlpha = std::max(0.0f, m_prevPreviewAlpha - dt * 6.0f);

    m_subSlideX += (0.0f - m_subSlideX) * std::min(1.0f, dt * 12.0f);
    m_subAlpha = std::min(1.0f, m_subAlpha + dt * 6.0f);
    m_optAlpha = std::min(1.0f, m_optAlpha + dt * 6.0f);
    m_creditsAlpha = std::min(1.0f, m_creditsAlpha + dt * 6.0f);
    m_exitAlpha = std::min(1.0f, m_exitAlpha + dt * 6.0f);

    if (!m_transitioning) {
        if (m_fadeAlpha > 0.0f) {
            m_fadeAlpha = std::max(0.0f, m_fadeAlpha - dt * 2.5f);
        }

        if (m_inputCooldown <= 0.0f && m_pad) {
            uint32_t mask = m_pad->getMask();
            bool touched = m_pad->isTouched();
            float tx = m_pad->getTouchX();
            float ty = m_pad->getTouchY();

            if (m_inOptions) {
                if ((mask & BTN_UP) && !(m_lastMask & BTN_UP)) {
                    m_optCursor = (m_optCursor - 1 + 6) % 6;
                    m_inputCooldown = 0.16f;
                } else if ((mask & BTN_DOWN) && !(m_lastMask & BTN_DOWN)) {
                    m_optCursor = (m_optCursor + 1) % 6;
                    m_inputCooldown = 0.16f;
                } else if ((mask & BTN_LEFT) && !(m_lastMask & BTN_LEFT)) {
                    if (m_optCursor == 0) {
                        m_bgmVol = std::max(0.0f, m_bgmVol - 0.1f);
                        AudioEngine::getInstance().setBgmVolume(m_bgmVol);
                    } else if (m_optCursor == 1) {
                        m_sfxVol = std::max(0.0f, m_sfxVol - 0.1f);
                        AudioEngine::getInstance().playSfx("sound/menu/menu_snd_06.mp3", m_sfxVol);
                    } else if (m_optCursor == 2) {
                        m_difficulty = std::max(1, m_difficulty - 1);
                    } else if (m_optCursor == 3) {
                        if (m_fightTime == -1) m_fightTime = 120;
                        else if (m_fightTime == 120) m_fightTime = 90;
                        else if (m_fightTime == 90) m_fightTime = 60;
                        else if (m_fightTime == 60) m_fightTime = 30;
                    } else if (m_optCursor == 4) {
                        m_rounds = std::max(1, m_rounds - 1);
                    }
                    m_inputCooldown = 0.16f;
                } else if ((mask & BTN_RIGHT) && !(m_lastMask & BTN_RIGHT)) {
                    if (m_optCursor == 0) {
                        m_bgmVol = std::min(1.0f, m_bgmVol + 0.1f);
                        AudioEngine::getInstance().setBgmVolume(m_bgmVol);
                    } else if (m_optCursor == 1) {
                        m_sfxVol = std::min(1.0f, m_sfxVol + 0.1f);
                        AudioEngine::getInstance().playSfx("sound/menu/menu_snd_06.mp3", m_sfxVol);
                    } else if (m_optCursor == 2) {
                        m_difficulty = std::min(4, m_difficulty + 1);
                    } else if (m_optCursor == 3) {
                        if (m_fightTime == 30) m_fightTime = 60;
                        else if (m_fightTime == 60) m_fightTime = 90;
                        else if (m_fightTime == 90) m_fightTime = 120;
                        else if (m_fightTime == 120) m_fightTime = -1;
                    } else if (m_optCursor == 4) {
                        m_rounds = std::min(3, m_rounds + 1);
                    }
                    m_inputCooldown = 0.16f;
                } else if ((mask & BTN_ATTACK) && !(m_lastMask & BTN_ATTACK)) {
                    if (m_optCursor == 5) closeOptions();
                } else if ((mask & BTN_JUMP) && !(m_lastMask & BTN_JUMP)) {
                    closeOptions();
                }

                if (touched && !m_lastTouched && tx >= 0.0f && ty >= 0.0f) {
                    if ((tx >= 20.0f && tx <= 150.0f && ty >= 610.0f && ty <= 710.0f) ||
                        (tx >= 1130.0f && tx <= 1260.0f && ty >= 610.0f && ty <= 710.0f)) {
                        closeOptions();
                    } else if (tx >= 500.0f && tx <= 780.0f && ty >= 500.0f && ty <= 560.0f) {
                        closeOptions();
                    } else if (tx < 300.0f || tx > 980.0f || ty < 120.0f || ty > 600.0f) {
                        closeOptions();
                    }
                }
            } else if (m_inCredits) {
                if (((mask & BTN_ATTACK) && !(m_lastMask & BTN_ATTACK)) ||
                    ((mask & BTN_JUMP) && !(m_lastMask & BTN_JUMP)) ||
                    (touched && !m_lastTouched)) {
                    closeCredits();
                }
            } else if (m_inExitDialog) {
                if ((mask & BTN_LEFT) && !(m_lastMask & BTN_LEFT)) {
                    m_exitCursor = 0;
                    m_inputCooldown = 0.16f;
                } else if ((mask & BTN_RIGHT) && !(m_lastMask & BTN_RIGHT)) {
                    m_exitCursor = 1;
                    m_inputCooldown = 0.16f;
                } else if (((mask & (BTN_ATTACK | BTN_JUMP)) && !(m_lastMask & (BTN_ATTACK | BTN_JUMP)))) {
                    if (m_exitCursor == 0) {
                        std::exit(0);
                    } else {
                        closeExitDialog();
                    }
                } else if ((mask & BTN_DASH) && !(m_lastMask & BTN_DASH)) {
                    closeExitDialog();
                }
            } else if (m_inSubmenu) {
                int sCount = static_cast<int>(m_subItems.size());
                if ((mask & BTN_UP) && !(m_lastMask & BTN_UP)) {
                    m_subCursor = (m_subCursor - 1 + sCount) % sCount;
                    m_inputCooldown = 0.16f;
                    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_01.mp3", m_sfxVol);
                } else if ((mask & BTN_DOWN) && !(m_lastMask & BTN_DOWN)) {
                    m_subCursor = (m_subCursor + 1) % sCount;
                    m_inputCooldown = 0.16f;
                    AudioEngine::getInstance().playSfx("sound/menu/menu_snd_01.mp3", m_sfxVol);
                } else if (((mask & (BTN_ATTACK | BTN_JUMP)) && !(m_lastMask & (BTN_ATTACK | BTN_JUMP)))) {
                    confirmSubmenu();
                } else if ((mask & BTN_DASH) && !(m_lastMask & BTN_DASH)) {
                    closeSubmenu();
                }
            } else {
                if ((mask & BTN_UP) && !(m_lastMask & BTN_UP)) {
                    setMode((m_curMode - 1 + 6) % 6, false);
                } else if ((mask & BTN_DOWN) && !(m_lastMask & BTN_DOWN)) {
                    setMode((m_curMode + 1) % 6, true);
                } else if (((mask & (BTN_ATTACK | BTN_JUMP)) && !(m_lastMask & (BTN_ATTACK | BTN_JUMP)))) {
                    confirmSelection();
                } else if ((mask & BTN_DASH) && !(m_lastMask & BTN_DASH)) {
                    goBack();
                } else if ((mask & BTN_START) && !(m_lastMask & BTN_START)) {
                    openOptions();
                }
            }

            m_lastMask = mask;
            m_lastTouched = touched;
        }
    } else {
        m_fadeAlpha = std::min(1.0f, m_fadeAlpha + dt * 2.5f);
        if (m_fadeAlpha >= 1.0f) {
            if (m_transitionToTitle) {
                StateManager::getInstance().changeState(std::make_shared<TitleState>(m_renderer, m_pad));
            } else {
                StateManager::getInstance().changeState(std::make_shared<SelectState>(m_renderer, m_pad, m_targetGameMode));
            }
        }
    }
}

void MenuState::render() {
    if (!m_renderer) return;

    m_renderer->begin();

    if (m_menuPak && m_menuPak->getNumEntries() >= 23) {
        GLuint bgTex = m_menuPak->getTexture(m_curMode);
        if (bgTex != 0) {
            m_renderer->drawSprite(bgTex, 0.0f, 0.0f, 0, 0, 1280, 720, 1280, 720, 0, 0, 1);
        }

        if (m_prevPreviewAlpha > 0.01f) {
            int prevIdx = 6 + m_prevMode;
            const auto* pe = m_menuPak->getEntry(prevIdx);
            GLuint prevTex = m_menuPak->getTexture(prevIdx);
            if (prevTex != 0 && pe) {
                m_renderer->drawSprite(
                    prevTex,
                    pe->posX, pe->posY,
                    0, 0, pe->srcW, pe->srcH,
                    pe->srcW, pe->srcH,
                    0, 0, 1,
                    1.0f, 1.0f,
                    1.0f, 1.0f, 1.0f, m_prevPreviewAlpha
                );
            }
        }

        int curIdx = 6 + m_curMode;
        const auto* ce = m_menuPak->getEntry(curIdx);
        GLuint curTex = m_menuPak->getTexture(curIdx);
        if (curTex != 0 && ce) {
            m_renderer->drawSprite(
                curTex,
                ce->posX + m_previewSlideX, ce->posY,
                0, 0, ce->srcW, ce->srcH,
                ce->srcW, ce->srcH,
                0, 0, 1,
                1.0f, 1.0f,
                1.0f, 1.0f, 1.0f, m_previewAlpha
            );
        }

        const auto* hEntry = m_menuPak->getEntry(18);
        GLuint hTex = m_menuPak->getTexture(18);
        if (hTex != 0 && hEntry) {
            m_renderer->drawSprite(hTex, hEntry->posX, hEntry->posY, 0, 0, hEntry->srcW, hEntry->srcH, hEntry->srcW, hEntry->srcH, 0, 0, 1);
        }

        const auto* auEntry = m_menuPak->getEntry(19);
        GLuint auTex = m_menuPak->getTexture(19);
        if (auTex != 0 && auEntry) {
            float floatY = std::sin(m_arrowFloatTimer * 4.0f) * 5.0f;
            float ax = auEntry->posX - (m_arrowUpScale - 1.0f) * auEntry->dstW * 0.5f;
            float ay = auEntry->posY + floatY - (m_arrowUpScale - 1.0f) * auEntry->dstH * 0.5f;
            m_renderer->drawSprite(
                auTex,
                ax, ay,
                0, 0, auEntry->srcW, auEntry->srcH,
                auEntry->srcW, auEntry->srcH,
                0, 0, 1,
                m_arrowUpScale, m_arrowUpScale
            );
        }

        float breath = 1.0f + 0.035f * (0.5f + 0.5f * std::sin(m_titleBreathTimer * 2.5f));

        if (m_prevTitleAlpha > 0.01f) {
            int ptIdx = 12 + m_prevMode;
            const auto* pte = m_menuPak->getEntry(ptIdx);
            GLuint ptTex = m_menuPak->getTexture(ptIdx);
            if (ptTex != 0 && pte) {
                m_renderer->drawSprite(
                    ptTex,
                    pte->posX, pte->posY + m_prevTitleSlideY,
                    0, 0, pte->srcW, pte->srcH,
                    pte->srcW, pte->srcH,
                    0, 0, 1,
                    1.0f, 1.0f,
                    1.0f, 1.0f, 1.0f, m_prevTitleAlpha
                );
            }
        }

        int ctIdx = 12 + m_curMode;
        const auto* cte = m_menuPak->getEntry(ctIdx);
        GLuint ctTex = m_menuPak->getTexture(ctIdx);
        if (ctTex != 0 && cte) {
            float tx = cte->posX - (breath - 1.0f) * cte->dstW * 0.5f;
            float ty = cte->posY + m_titleSlideY - (breath - 1.0f) * cte->dstH * 0.5f;
            m_renderer->drawSprite(
                ctTex,
                tx, ty,
                0, 0, cte->srcW, cte->srcH,
                cte->srcW, cte->srcH,
                0, 0, 1,
                breath, breath,
                1.0f, 1.0f, 1.0f, m_titleAlpha
            );
        }

        const auto* adEntry = m_menuPak->getEntry(20);
        GLuint adTex = m_menuPak->getTexture(20);
        if (adTex != 0 && adEntry) {
            float floatY = -std::sin(m_arrowFloatTimer * 4.0f) * 5.0f;
            float ax = adEntry->posX - (m_arrowDnScale - 1.0f) * adEntry->dstW * 0.5f;
            float ay = adEntry->posY + floatY - (m_arrowDnScale - 1.0f) * adEntry->dstH * 0.5f;
            m_renderer->drawSprite(
                adTex,
                ax, ay,
                0, 0, adEntry->srcW, adEntry->srcH,
                adEntry->srcW, adEntry->srcH,
                0, 0, 1,
                m_arrowDnScale, m_arrowDnScale
            );
        }

        const auto* bbEntry = m_menuPak->getEntry(21);
        GLuint bbTex = m_menuPak->getTexture(21);
        if (bbTex != 0 && bbEntry) {
            m_renderer->drawSprite(bbTex, bbEntry->posX, bbEntry->posY, 0, 0, bbEntry->srcW, bbEntry->srcH, bbEntry->srcW, bbEntry->srcH, 0, 0, 1);
        }
    } else {
        m_renderer->drawRect(0, 0, 1280, 720, 0.05f, 0.07f, 0.12f, 1.0f);
    }

    if (m_inSubmenu && !m_subItems.empty()) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_subAlpha * 0.45f);

        float subX = 480.0f + m_subSlideX;
        float subY = 220.0f;
        float subW = 340.0f;
        float rowH = 68.0f;
        int sCount = static_cast<int>(m_subItems.size());
        float subH = sCount * rowH + 20.0f;

        m_renderer->drawRect(subX, subY - 10.0f, subW, subH, 0.06f, 0.08f, 0.14f, m_subAlpha * 0.95f);
        m_renderer->drawRect(subX - 4.0f, subY - 10.0f, 4.0f, subH, 1.0f, 0.75f, 0.2f, m_subAlpha * 0.9f);

        for (int i = 0; i < sCount; ++i) {
            float ry = subY + i * rowH;
            bool isHover = (m_subCursor == i);

            if (isHover) {
                float pulse = 0.5f + 0.5f * std::sin(m_animTime * 6.0f);
                m_renderer->drawRect(subX + 8.0f, ry + 2.0f, subW - 16.0f, rowH - 8.0f, 0.2f, 0.25f, 0.4f, m_subAlpha * (0.7f + 0.2f * pulse));
                m_renderer->drawRect(subX + 8.0f, ry + 2.0f, 6.0f, rowH - 8.0f, 1.0f, 0.85f, 0.3f, m_subAlpha);
            } else {
                m_renderer->drawRect(subX + 8.0f, ry + 2.0f, subW - 16.0f, rowH - 8.0f, 0.1f, 0.12f, 0.2f, m_subAlpha * 0.6f);
            }
        }
    }

    if (m_inOptions) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_optAlpha * 0.7f);

        float optX = 320.0f;
        float optY = 120.0f;
        float optW = 640.0f;
        float optH = 480.0f;

        m_renderer->drawRect(optX, optY, optW, optH, 0.06f, 0.08f, 0.14f, m_optAlpha * 0.95f);
        m_renderer->drawRect(optX, optY, optW, 50.0f, 0.12f, 0.16f, 0.28f, m_optAlpha);
        m_renderer->drawRect(optX, optY + 48.0f, optW, 3.0f, 1.0f, 0.8f, 0.2f, m_optAlpha);

        for (int i = 0; i < 6; ++i) {
            float rowY = optY + 70.0f + i * 58.0f;
            bool isCur = (m_optCursor == i);

            if (isCur) {
                m_renderer->drawRect(optX + 16.0f, rowY, optW - 32.0f, 48.0f, 0.2f, 0.28f, 0.45f, m_optAlpha * 0.85f);
                m_renderer->drawRect(optX + 16.0f, rowY, 5.0f, 48.0f, 1.0f, 0.85f, 0.25f, m_optAlpha);
            } else {
                m_renderer->drawRect(optX + 16.0f, rowY, optW - 32.0f, 48.0f, 0.09f, 0.11f, 0.18f, m_optAlpha * 0.6f);
            }

            if (i == 0) {
                float barW = 200.0f;
                float fillW = barW * m_bgmVol;
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, barW, 16.0f, 0.04f, 0.05f, 0.08f, m_optAlpha);
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, fillW, 16.0f, 0.3f, 0.8f, 1.0f, m_optAlpha);
            } else if (i == 1) {
                float barW = 200.0f;
                float fillW = barW * m_sfxVol;
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, barW, 16.0f, 0.04f, 0.05f, 0.08f, m_optAlpha);
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, fillW, 16.0f, 1.0f, 0.6f, 0.2f, m_optAlpha);
            } else if (i == 2) {
                float diffFill = m_difficulty * 50.0f;
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, 200.0f, 16.0f, 0.04f, 0.05f, 0.08f, m_optAlpha);
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, diffFill, 16.0f, 0.4f, 0.9f, 0.4f, m_optAlpha);
            } else if (i == 3) {
                float timeFill = (m_fightTime == -1 ? 200.0f : (m_fightTime / 120.0f) * 200.0f);
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, 200.0f, 16.0f, 0.04f, 0.05f, 0.08f, m_optAlpha);
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, timeFill, 16.0f, 0.9f, 0.8f, 0.3f, m_optAlpha);
            } else if (i == 4) {
                float roundFill = (m_rounds / 3.0f) * 200.0f;
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, 200.0f, 16.0f, 0.04f, 0.05f, 0.08f, m_optAlpha);
                m_renderer->drawRect(optX + 380.0f, rowY + 16.0f, roundFill, 16.0f, 0.9f, 0.3f, 0.5f, m_optAlpha);
            }
        }
    }

    if (m_inCredits) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_creditsAlpha * 0.75f);

        float crdX = 290.0f;
        float crdY = 120.0f;
        float crdW = 700.0f;
        float crdH = 480.0f;

        m_renderer->drawRect(crdX, crdY, crdW, crdH, 0.06f, 0.08f, 0.14f, m_creditsAlpha * 0.95f);
        m_renderer->drawRect(crdX, crdY, crdW, 50.0f, 0.12f, 0.16f, 0.28f, m_creditsAlpha);
        m_renderer->drawRect(crdX, crdY + 48.0f, crdW, 3.0f, 0.3f, 0.8f, 1.0f, m_creditsAlpha);

        for (int i = 0; i < 6; ++i) {
            float rowY = crdY + 70.0f + i * 55.0f;
            m_renderer->drawRect(crdX + 24.0f, rowY, crdW - 48.0f, 42.0f, 0.09f, 0.12f, 0.2f, m_creditsAlpha * 0.65f);
            m_renderer->drawRect(crdX + 24.0f, rowY, 4.0f, 42.0f, 0.3f, 0.8f, 1.0f, m_creditsAlpha);
        }

        m_renderer->drawRect(crdX + 220.0f, crdY + 415.0f, 260.0f, 45.0f, 0.2f, 0.3f, 0.5f, m_creditsAlpha * 0.85f);
    }

    if (m_inExitDialog) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_exitAlpha * 0.75f);

        float dlgX = 400.0f;
        float dlgY = 240.0f;
        float dlgW = 480.0f;
        float dlgH = 240.0f;

        m_renderer->drawRect(dlgX, dlgY, dlgW, dlgH, 0.06f, 0.08f, 0.14f, m_exitAlpha * 0.95f);
        m_renderer->drawRect(dlgX, dlgY, dlgW, 45.0f, 0.15f, 0.18f, 0.3f, m_exitAlpha);
        m_renderer->drawRect(dlgX, dlgY + 43.0f, dlgW, 3.0f, 1.0f, 0.3f, 0.3f, m_exitAlpha);

        bool yesHover = (m_exitCursor == 0);
        bool noHover = (m_exitCursor == 1);

        m_renderer->drawRect(dlgX + 40.0f, dlgY + 140.0f, 180.0f, 50.0f, yesHover ? 0.8f : 0.15f, yesHover ? 0.2f : 0.18f, yesHover ? 0.2f : 0.25f, m_exitAlpha * 0.9f);
        m_renderer->drawRect(dlgX + 260.0f, dlgY + 140.0f, 180.0f, 50.0f, noHover ? 0.2f : 0.15f, noHover ? 0.6f : 0.18f, noHover ? 0.9f : 0.25f, m_exitAlpha * 0.9f);
    }

    if (m_fadeAlpha > 0.001f) {
        m_renderer->drawRect(0, 0, 1280, 720, 0.0f, 0.0f, 0.0f, m_fadeAlpha);
    }

    m_renderer->end();
}

void MenuState::onExit() {
    if (m_menuPak) {
        m_menuPak->release();
    }
}

}
