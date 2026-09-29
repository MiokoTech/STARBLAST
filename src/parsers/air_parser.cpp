// Parsing frame animasi dan hitbox karakter.
#include "air_parser.h"
#include "texture_manager.h"
#include <android/asset_manager.h>
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>

namespace starblast {

namespace {

inline std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) return "";
    size_t last = str.find_last_not_of(" \t\r\n");
    return str.substr(first, (last - first + 1));
}

inline std::string stripComment(const std::string& line) {
    size_t comment_pos = line.find_first_of(";#");
    if (comment_pos != std::string::npos) {
        return trim(line.substr(0, comment_pos));
    }
    return trim(line);
}

inline std::vector<std::string> split(const std::string& s, char delimiter) {
    std::vector<std::string> tokens;
    std::string token;
    std::istringstream tokenStream(s);
    while (std::getline(tokenStream, token, delimiter)) {
        tokens.push_back(trim(token));
    }
    return tokens;
}

inline std::string toUpper(std::string str) {
    std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c) {
        return std::toupper(c);
    });
    return str;
}

}

AirParser::AirParser() = default;
AirParser::~AirParser() = default;

bool AirParser::load(const std::string& filepath) {
    std::string content;
    bool readSuccess = false;

    AAssetManager* assetMgr = TextureManager::getInstance().getAssetManager();
    if (assetMgr) {
        std::vector<std::string> tryPaths = {filepath};
        if (filepath.rfind("assets/", 0) == 0) {
            tryPaths.push_back(filepath.substr(7));
        } else {
            tryPaths.push_back("assets/" + filepath);
        }
        for (const auto& p : tryPaths) {
            AAsset* asset = AAssetManager_open(assetMgr, p.c_str(), AASSET_MODE_BUFFER);
            if (asset) {
                off_t length = AAsset_getLength(asset);
                content.resize(length);
                AAsset_read(asset, &content[0], length);
                AAsset_close(asset);
                readSuccess = true;
                break;
            }
        }
    }

    if (!readSuccess) {
        std::ifstream f(filepath);
        if (!f.is_open()) {
            std::string sdPath = "/sdcard/MiokoTech/STARBLAST/" + filepath;
            f.open(sdPath);
        }
        if (f.is_open()) {
            std::stringstream ss;
            ss << f.rdbuf();
            content = ss.str();
            readSuccess = true;
        }
    }

    if (!readSuccess || content.empty()) {
        return false;
    }

    std::istringstream file(content);

    actions_.clear();

    std::string line;
    AirAction cur_action;
    bool in_action = false;

    std::vector<ClsnRect> default_clsn1;
    std::vector<ClsnRect> default_clsn2;
    std::vector<ClsnRect> cur_clsn1;
    std::vector<ClsnRect> cur_clsn2;
    bool has_cur_clsn1 = false;
    bool has_cur_clsn2 = false;

    auto finishAction = [&]() {
        if (in_action && cur_action.action_no >= 0) {
            int32_t total = 0;
            for (const auto& f : cur_action.frames) {
                if (f.duration > 0) total += f.duration;
            }
            cur_action.total_ticks = total;
            actions_[cur_action.action_no] = cur_action;
        }
        cur_action = AirAction();
        default_clsn1.clear();
        default_clsn2.clear();
        cur_clsn1.clear();
        cur_clsn2.clear();
        has_cur_clsn1 = false;
        has_cur_clsn2 = false;
        in_action = false;
    };

    while (std::getline(file, line)) {
        std::string clean = stripComment(line);
        if (clean.empty()) continue;

        std::string upper = toUpper(clean);

        if (upper.rfind("[BEGIN ACTION", 0) == 0) {
            finishAction();
            size_t end_bracket = clean.find(']');
            if (end_bracket != std::string::npos) {
                std::string num_str = trim(clean.substr(13, end_bracket - 13));
                try {
                    cur_action.action_no = std::stoi(num_str);
                    in_action = true;
                } catch (...) {
                    in_action = false;
                }
            }
            continue;
        }

        if (!in_action) continue;

        if (upper.rfind("LOOPSTART", 0) == 0) {
            cur_action.loopstart_idx = static_cast<int32_t>(cur_action.frames.size());
            continue;
        }

        if (upper.rfind("CLSN1DEFAULT", 0) == 0) {
            default_clsn1.clear();
            continue;
        }
        if (upper.rfind("CLSN2DEFAULT", 0) == 0) {
            default_clsn2.clear();
            continue;
        }
        if (upper.rfind("CLSN1", 0) == 0 && upper.find('[') == std::string::npos && upper.find(':') != std::string::npos) {
            cur_clsn1.clear();
            has_cur_clsn1 = true;
            continue;
        }
        if (upper.rfind("CLSN2", 0) == 0 && upper.find('[') == std::string::npos && upper.find(':') != std::string::npos) {
            cur_clsn2.clear();
            has_cur_clsn2 = true;
            continue;
        }

        if (upper.rfind("CLSN", 0) == 0 && upper.find('=') != std::string::npos) {
            size_t eq_pos = clean.find('=');
            std::string coords_str = clean.substr(eq_pos + 1);
            auto coords = split(coords_str, ',');
            if (coords.size() >= 4) {
                try {
                    ClsnRect r;
                    r.x1 = static_cast<int16_t>(std::stoi(coords[0]));
                    r.y1 = static_cast<int16_t>(std::stoi(coords[1]));
                    r.x2 = static_cast<int16_t>(std::stoi(coords[2]));
                    r.y2 = static_cast<int16_t>(std::stoi(coords[3]));

                    if (upper.rfind("CLSN1DEFAULT", 0) == 0) {
                        default_clsn1.push_back(r);
                    } else if (upper.rfind("CLSN2DEFAULT", 0) == 0) {
                        default_clsn2.push_back(r);
                    } else if (upper.rfind("CLSN1[", 0) == 0) {
                        cur_clsn1.push_back(r);
                        has_cur_clsn1 = true;
                    } else if (upper.rfind("CLSN2[", 0) == 0) {
                        cur_clsn2.push_back(r);
                        has_cur_clsn2 = true;
                    }
                } catch (...) {}
            }
            continue;
        }

        auto parts = split(clean, ',');
        if (parts.size() >= 5) {
            try {
                AirFrame frame;
                frame.group = std::stoi(parts[0]);
                frame.number = std::stoi(parts[1]);
                frame.x_offset = static_cast<int16_t>(std::stoi(parts[2]));
                frame.y_offset = static_cast<int16_t>(std::stoi(parts[3]));
                frame.duration = std::stoi(parts[4]);

                if (parts.size() >= 6) {
                    std::string flip = toUpper(parts[5]);
                    if (flip == "H") frame.flip_flags = 1;
                    else if (flip == "V") frame.flip_flags = 2;
                    else if (flip == "HV" || flip == "VH") frame.flip_flags = 3;
                }

                if (has_cur_clsn1) {
                    frame.clsn1 = cur_clsn1;
                } else {
                    frame.clsn1 = default_clsn1;
                }

                if (has_cur_clsn2) {
                    frame.clsn2 = cur_clsn2;
                } else {
                    frame.clsn2 = default_clsn2;
                }

                cur_action.frames.push_back(frame);

                cur_clsn1.clear();
                cur_clsn2.clear();
                has_cur_clsn1 = false;
                has_cur_clsn2 = false;

            } catch (...) {}
        }
    }

    finishAction();
    return !actions_.empty();
}

const AirAction* AirParser::getAction(int32_t action_no) const {
    auto it = actions_.find(action_no);
    if (it != actions_.end()) {
        return &it->second;
    }
    return nullptr;
}

bool AirParser::hasAction(int32_t action_no) const {
    return actions_.find(action_no) != actions_.end();
}

}
