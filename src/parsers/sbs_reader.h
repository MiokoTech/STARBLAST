#pragma once

#include <cstdint>
#include <string>
#include <vector>
#include <unordered_map>
#include <GLES3/gl3.h>
#include <android/asset_manager.h>

namespace starblast {

#pragma pack(push, 1)
struct SbsHeaderRaw {
    char magic[4];
    uint16_t version;
    uint16_t flags;
    uint32_t total_sprites;
    uint16_t total_sheets;
    uint8_t atlas_format;
    uint8_t reserved1;
    uint32_t sprite_table_offset;
    uint32_t atlas_table_offset;
    uint32_t reserved2;
    uint32_t reserved3;
};

struct SbsSpriteEntryRaw {
    int32_t group;
    int32_t number;
    uint16_t sheet_id;
    uint16_t flags;
    uint16_t atlas_x;
    uint16_t atlas_y;
    uint16_t width;
    uint16_t height;
    int16_t axis_x;
    int16_t axis_y;
};
#pragma pack(pop)

struct SbsSheetInfo {
    uint16_t width;
    uint16_t height;
    uint32_t data_offset;
    uint32_t data_size;
    GLuint texture_id;
};

class SbsReader {
public:
    SbsReader();
    ~SbsReader();

    bool load(const std::string& filepath, AAssetManager* assetMgr = nullptr);
    void unload();

    const SbsSpriteEntryRaw* getSprite(int32_t group, int32_t number) const;
    GLuint getSheetTexture(uint16_t sheet_id) const;
    const SbsSheetInfo* getSheetInfo(uint16_t sheet_id) const;

    uint32_t getTotalSprites() const { return header_.total_sprites; }
    uint16_t getTotalSheets() const { return header_.total_sheets; }
    uint8_t getAtlasFormat() const { return header_.atlas_format; }
    const std::vector<SbsSheetInfo>& getSheets() const { return sheets_; }

private:
    SbsHeaderRaw header_;
    std::vector<SbsSpriteEntryRaw> entries_;
    std::vector<SbsSheetInfo> sheets_;
    std::vector<GLuint> texture_ids_;
    std::unordered_map<uint64_t, size_t> sprite_map_;
};

}
