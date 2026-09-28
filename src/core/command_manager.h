// Manager buffer input dan pengenal skill.
#pragma once

#include <string>
#include <vector>
#include <unordered_map>
#include <cstdint>

namespace starblast {

constexpr uint32_t BTN_UP    = 1 << 0;
constexpr uint32_t BTN_DOWN  = 1 << 1;
constexpr uint32_t BTN_LEFT  = 1 << 2;
constexpr uint32_t BTN_RIGHT = 1 << 3;
constexpr uint32_t BTN_A     = 1 << 4;
constexpr uint32_t BTN_B     = 1 << 5;
constexpr uint32_t BTN_C     = 1 << 6;
constexpr uint32_t BTN_X     = 1 << 7;
constexpr uint32_t BTN_Y     = 1 << 8;
constexpr uint32_t BTN_Z     = 1 << 9;
constexpr uint32_t BTN_START = 1 << 10;

constexpr uint32_t DIR_FWD  = 1 << 16;
constexpr uint32_t DIR_BACK = 1 << 17;
constexpr uint32_t DIR_UP   = 1 << 18;
constexpr uint32_t DIR_DOWN = 1 << 19;

struct CommandElement {
    uint32_t buttons = 0;
    bool hold = false;
    bool release = false;
};

struct CommandDef {
    std::string name;
    std::vector<CommandElement> sequence;
    int time = 15;
    int buffer_time = 1;
    int active_buffer_timer = 0;
};

class CommandManager {
public:
    CommandManager();
    ~CommandManager();

    bool loadCmd(const std::string& filepath);
    void addCommand(const CommandDef& cmd);

    void update(uint32_t raw_input, int32_t facing);

    bool isCommandActive(const std::string& name) const;

    uint32_t getCurrentInput() const { return input_history_[head_]; }
    uint32_t getRawInput() const { return raw_history_[head_]; }

    void reset();

private:
    std::vector<CommandDef> commands_;
    std::unordered_map<std::string, size_t> command_index_;

    static constexpr size_t BUFFER_SIZE = 60;
    uint32_t input_history_[BUFFER_SIZE];
    uint32_t raw_history_[BUFFER_SIZE];
    size_t head_ = 0;

    void parseCommandElement(const std::string& token, CommandElement& elem);
    bool checkSequence(const CommandDef& cmd, int facing) const;
};

}
