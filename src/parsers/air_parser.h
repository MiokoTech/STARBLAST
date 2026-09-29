#pragma once

#include <cstdint>
#include <string>
#include <vector>
#include <unordered_map>

namespace starblast {

struct ClsnRect {
    int16_t x1;
    int16_t y1;
    int16_t x2;
    int16_t y2;
};

struct AirFrame {
    int32_t group = 0;
    int32_t number = 0;
    int16_t x_offset = 0;
    int16_t y_offset = 0;
    int32_t duration = 1;
    uint8_t flip_flags = 0;
    std::vector<ClsnRect> clsn1;
    std::vector<ClsnRect> clsn2;
};

struct AirAction {
    int32_t action_no = 0;
    int32_t loopstart_idx = 0;
    std::vector<AirFrame> frames;
    int32_t total_ticks = 0;
};

class AirParser {
public:
    AirParser();
    ~AirParser();

    bool load(const std::string& filepath);
    const AirAction* getAction(int32_t action_no) const;
    bool hasAction(int32_t action_no) const;

    size_t getActionCount() const { return actions_.size(); }

private:
    std::unordered_map<int32_t, AirAction> actions_;
};

}
