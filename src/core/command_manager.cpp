// Pencocokan kombinasi input jurus berdasarkan arah hadap karakter.
#include "command_manager.h"
#include <fstream>
#include <sstream>
#include <algorithm>
#include <cctype>

namespace starblast {

namespace {

inline std::string trim(const std::string& str) {
    size_t first = str.find_first_not_of(" \t\r\n\xef\xbb\xbf");
    if (first == std::string::npos) return "";
    size_t last = str.find_last_not_of(" \t\r\n");
    return str.substr(first, (last - first + 1));
}

inline std::string stripQuotes(const std::string& str) {
    std::string s = trim(str);
    if (s.size() >= 2 && s.front() == '"' && s.back() == '"') {
        return s.substr(1, s.size() - 2);
    }
    return s;
}

inline std::string toLower(std::string str) {
    std::transform(str.begin(), str.end(), str.begin(), [](unsigned char c) {
        return std::tolower(c);
    });
    return str;
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

}

CommandManager::CommandManager() {
    reset();
}

CommandManager::~CommandManager() = default;

void CommandManager::reset() {
    std::fill(std::begin(input_history_), std::end(input_history_), 0);
    std::fill(std::begin(raw_history_), std::end(raw_history_), 0);
    head_ = 0;
    for (auto& cmd : commands_) {
        cmd.active_buffer_timer = 0;
    }
}

void CommandManager::addCommand(const CommandDef& cmd) {
    size_t idx = commands_.size();
    commands_.push_back(cmd);
    command_index_[toLower(cmd.name)] = idx;
    command_index_[cmd.name] = idx;
}

bool CommandManager::loadCmd(const std::string& filepath) {
    std::ifstream file(filepath);
    if (!file.is_open()) return false;

    std::string line;
    bool in_cmd = false;
    CommandDef cur_cmd;

    auto finishCmd = [&]() {
        if (in_cmd && !cur_cmd.name.empty() && !cur_cmd.sequence.empty()) {
            addCommand(cur_cmd);
        }
        cur_cmd = CommandDef();
        in_cmd = false;
    };

    while (std::getline(file, line)) {

        size_t cpos = line.find_first_of(";#");
        if (cpos != std::string::npos) line = line.substr(0, cpos);
        line = trim(line);
        if (line.empty()) continue;

        if (line.front() == '[' && line.back() == ']') {
            std::string sec = toLower(trim(line.substr(1, line.size() - 2)));
            if (sec == "command") {
                finishCmd();
                in_cmd = true;
                cur_cmd = CommandDef();
                continue;
            } else {
                finishCmd();
                in_cmd = false;
                continue;
            }
        }

        if (!in_cmd) continue;

        size_t eq = line.find('=');
        if (eq == std::string::npos) continue;

        std::string key = toLower(trim(line.substr(0, eq)));
        std::string val = stripQuotes(trim(line.substr(eq + 1)));

        if (key == "name") {
            cur_cmd.name = val;
        } else if (key == "time") {
            try { cur_cmd.time = std::stoi(val); } catch (...) {}
        } else if (key == "buffer.time") {
            try { cur_cmd.buffer_time = std::stoi(val); } catch (...) {}
        } else if (key == "command") {
            auto tokens = split(val, ',');
            cur_cmd.sequence.clear();
            for (const auto& tok : tokens) {
                CommandElement elem;
                parseCommandElement(tok, elem);
                if (elem.buttons != 0) {
                    cur_cmd.sequence.push_back(elem);
                }
            }
        }
    }

    finishCmd();
    return true;
}

void CommandManager::parseCommandElement(const std::string& token, CommandElement& elem) {
    std::string s = trim(token);
    if (s.empty()) return;

    if (s.front() == '~') {
        elem.release = true;
        s = s.substr(1);
    }
    if (!s.empty() && s.front() == '/') {
        elem.hold = true;
        s = s.substr(1);
    }
    if (!s.empty() && s.front() == '$') {
        s = s.substr(1);
    }

    auto parts = split(s, '+');
    for (const auto& part_raw : parts) {
        std::string p = trim(part_raw);
        if (p.empty()) continue;

        if (p == "B") elem.buttons |= DIR_BACK;
        else if (p == "F") elem.buttons |= DIR_FWD;
        else if (p == "D") elem.buttons |= DIR_DOWN;
        else if (p == "U") elem.buttons |= DIR_UP;
        else if (p == "DB") elem.buttons |= (DIR_DOWN | DIR_BACK);
        else if (p == "DF") elem.buttons |= (DIR_DOWN | DIR_FWD);
        else if (p == "UB") elem.buttons |= (DIR_UP | DIR_BACK);
        else if (p == "UF") elem.buttons |= (DIR_UP | DIR_FWD);
        else if (p == "a") elem.buttons |= BTN_A;
        else if (p == "b") elem.buttons |= BTN_B;
        else if (p == "c") elem.buttons |= BTN_C;
        else if (p == "x") elem.buttons |= BTN_X;
        else if (p == "y") elem.buttons |= BTN_Y;
        else if (p == "z") elem.buttons |= BTN_Z;
        else if (p == "s" || toLower(p) == "start") elem.buttons |= BTN_START;
        else {
            std::string lp = toLower(p);
            if (lp == "fwd") elem.buttons |= DIR_FWD;
            else if (lp == "back") elem.buttons |= DIR_BACK;
            else if (lp == "up") elem.buttons |= DIR_UP;
            else if (lp == "down") elem.buttons |= DIR_DOWN;
            else if (lp == "holdfwd") { elem.buttons |= DIR_FWD; elem.hold = true; }
            else if (lp == "holdback") { elem.buttons |= DIR_BACK; elem.hold = true; }
            else if (lp == "holdup") { elem.buttons |= DIR_UP; elem.hold = true; }
            else if (lp == "holddown") { elem.buttons |= DIR_DOWN; elem.hold = true; }
            else if (lp == "holda") { elem.buttons |= BTN_A; elem.hold = true; }
            else if (lp == "holdb") { elem.buttons |= BTN_B; elem.hold = true; }
            else if (lp == "holdc") { elem.buttons |= BTN_C; elem.hold = true; }
            else if (lp == "holdx") { elem.buttons |= BTN_X; elem.hold = true; }
            else if (lp == "holdy") { elem.buttons |= BTN_Y; elem.hold = true; }
            else if (lp == "holdz") { elem.buttons |= BTN_Z; elem.hold = true; }
        }
    }
}

void CommandManager::update(uint32_t raw_input, int32_t facing) {
    uint32_t rel_input = 0;

    if (raw_input & BTN_UP) rel_input |= DIR_UP;
    if (raw_input & BTN_DOWN) rel_input |= DIR_DOWN;

    if (facing >= 0) {
        if (raw_input & BTN_RIGHT) rel_input |= DIR_FWD;
        if (raw_input & BTN_LEFT)  rel_input |= DIR_BACK;
    } else {
        if (raw_input & BTN_LEFT)  rel_input |= DIR_FWD;
        if (raw_input & BTN_RIGHT) rel_input |= DIR_BACK;
    }

    rel_input |= (raw_input & (BTN_A | BTN_B | BTN_C | BTN_X | BTN_Y | BTN_Z | BTN_START));

    head_ = (head_ + 1) % BUFFER_SIZE;
    input_history_[head_] = rel_input;
    raw_history_[head_] = raw_input;

    for (auto& cmd : commands_) {
        if (cmd.active_buffer_timer > 0) {
            cmd.active_buffer_timer--;
        }
        if (checkSequence(cmd, facing)) {
            cmd.active_buffer_timer = std::max(1, cmd.buffer_time);
        }
    }
}

bool CommandManager::checkSequence(const CommandDef& cmd, int facing) const {
    if (cmd.sequence.empty()) return false;

    if (cmd.sequence.size() == 1) {
        const auto& elem = cmd.sequence[0];
        uint32_t cur = input_history_[head_];
        size_t prev_head = (head_ + BUFFER_SIZE - 1) % BUFFER_SIZE;
        uint32_t prev = input_history_[prev_head];

        if (elem.hold) {
            return (cur & elem.buttons) == elem.buttons;
        }
        if (elem.release) {
            return ((prev & elem.buttons) == elem.buttons) && ((cur & elem.buttons) == 0);
        }

        bool pressed_now = ((cur & elem.buttons) == elem.buttons) && ((prev & elem.buttons) != elem.buttons);
        return pressed_now;
    }

    int max_frames = std::min(cmd.time, static_cast<int>(BUFFER_SIZE));
    int step_idx = static_cast<int>(cmd.sequence.size()) - 1;

    for (int offset = 0; offset < max_frames; offset++) {
        size_t idx = (head_ + BUFFER_SIZE - offset) % BUFFER_SIZE;
        size_t prev_idx = (idx + BUFFER_SIZE - 1) % BUFFER_SIZE;
        uint32_t frame_input = input_history_[idx];
        uint32_t prev_input = input_history_[prev_idx];

        const auto& expected = cmd.sequence[step_idx];
        bool matches = false;
        if (expected.hold) {
            matches = (frame_input & expected.buttons) == expected.buttons;
        } else if (expected.release) {
            matches = ((prev_input & expected.buttons) == expected.buttons) &&
                      ((frame_input & expected.buttons) == 0);
        } else {

            bool is_same_as_next = (step_idx < static_cast<int>(cmd.sequence.size()) - 1) &&
                                   (cmd.sequence[step_idx].buttons == cmd.sequence[step_idx + 1].buttons);
            if (is_same_as_next || step_idx == static_cast<int>(cmd.sequence.size()) - 1) {
                matches = ((frame_input & expected.buttons) == expected.buttons) &&
                          ((prev_input & expected.buttons) != expected.buttons);
            } else {
                matches = (frame_input & expected.buttons) == expected.buttons;
            }
        }

        if (matches) {
            step_idx--;
            if (step_idx < 0) {
                return true;
            }
        }
    }

    return false;
}

bool CommandManager::isCommandActive(const std::string& name) const {
    auto it = command_index_.find(toLower(name));
    if (it != command_index_.end()) {
        return commands_[it->second].active_buffer_timer > 0;
    }

    auto it2 = command_index_.find(name);
    if (it2 != command_index_.end()) {
        return commands_[it2->second].active_buffer_timer > 0;
    }
    return false;
}

}
