// Implementasi kolam memori objek dan buffer untuk menjamin zero garbage collection.
#include "ui_pool.h"
#include <cstdlib>

namespace starblast {

struct BufferHeader {
    uint32_t magic;
    uint32_t bucketIndex;
};

static constexpr uint32_t POOL_MAGIC = 0x53544250;

std::array<UIBufferPool::Bucket, 4>& UIBufferPool::getBuckets() {
    static std::array<Bucket, 4> buckets = {{
        { 64 * 1024, {}, {} },
        { 256 * 1024, {}, {} },
        { 1024 * 1024, {}, {} },
        { 4096 * 1024, {}, {} }
    }};
    return buckets;
}

uint8_t* UIBufferPool::acquire(size_t minSize) {
    auto& buckets = getBuckets();
    size_t needed = minSize + sizeof(BufferHeader);

    for (size_t i = 0; i < buckets.size(); ++i) {
        if (buckets[i].blockSize >= needed) {
            uint8_t* raw = nullptr;
            if (!buckets[i].freeBlocks.empty()) {
                raw = buckets[i].freeBlocks.back();
                buckets[i].freeBlocks.pop_back();
            } else {
                raw = static_cast<uint8_t*>(std::malloc(buckets[i].blockSize));
                if (!raw) return nullptr;
                buckets[i].allBlocks.push_back(raw);
            }

            BufferHeader* header = reinterpret_cast<BufferHeader*>(raw);
            header->magic = POOL_MAGIC;
            header->bucketIndex = static_cast<uint32_t>(i);

            return raw + sizeof(BufferHeader);
        }
    }

    uint8_t* raw = static_cast<uint8_t*>(std::malloc(needed));
    if (!raw) return nullptr;

    BufferHeader* header = reinterpret_cast<BufferHeader*>(raw);
    header->magic = POOL_MAGIC;
    header->bucketIndex = 0xFFFFFFFF;

    return raw + sizeof(BufferHeader);
}

void UIBufferPool::release(uint8_t* buffer) {
    if (!buffer) return;

    uint8_t* raw = buffer - sizeof(BufferHeader);
    BufferHeader* header = reinterpret_cast<BufferHeader*>(raw);

    if (header->magic != POOL_MAGIC) {
        std::free(raw);
        return;
    }

    if (header->bucketIndex == 0xFFFFFFFF) {
        std::free(raw);
        return;
    }

    auto& buckets = getBuckets();
    if (header->bucketIndex < buckets.size()) {
        buckets[header->bucketIndex].freeBlocks.push_back(raw);
    } else {
        std::free(raw);
    }
}

void UIBufferPool::clear() {
    auto& buckets = getBuckets();
    for (auto& b : buckets) {
        for (auto* ptr : b.allBlocks) {
            std::free(ptr);
        }
        b.freeBlocks.clear();
        b.allBlocks.clear();
    }
}

} // namespace starblast
