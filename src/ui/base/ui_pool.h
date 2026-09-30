// Pengelola kolam memori objek dan buffer untuk menjamin zero garbage collection.
#pragma once

#include <cstdint>
#include <cstddef>
#include <vector>
#include <array>
#include <utility>

namespace starblast {

template<typename T, size_t Capacity = 64>
class UIFixedPool {
public:
    UIFixedPool() {
        m_freeCount = Capacity;
        for (size_t i = 0; i < Capacity; ++i) {
            m_freeIndices[i] = i;
        }
    }

    template<typename... Args>
    T* acquire(Args&&... args) {
        if (m_freeCount == 0) return nullptr;
        size_t idx = m_freeIndices[--m_freeCount];
        T* ptr = reinterpret_cast<T*>(&m_storage[idx]);
        new (ptr) T(std::forward<Args>(args)...);
        return ptr;
    }

    void release(T* ptr) {
        if (!ptr) return;
        uint8_t* bytePtr = reinterpret_cast<uint8_t*>(ptr);
        uint8_t* startPtr = reinterpret_cast<uint8_t*>(&m_storage[0]);
        size_t offset = bytePtr - startPtr;
        size_t idx = offset / sizeof(StorageType);

        if (idx < Capacity && m_freeCount < Capacity) {
            ptr->~T();
            m_freeIndices[m_freeCount++] = idx;
        }
    }

    void clear() {
        for (size_t i = m_freeCount; i < Capacity; ++i) {
            size_t idx = m_freeIndices[i];
            T* ptr = reinterpret_cast<T*>(&m_storage[idx]);
            ptr->~T();
        }
        m_freeCount = Capacity;
        for (size_t i = 0; i < Capacity; ++i) {
            m_freeIndices[i] = i;
        }
    }

    size_t getAvailable() const { return m_freeCount; }
    size_t getCapacity() const { return Capacity; }

private:
    using StorageType = typename std::aligned_storage<sizeof(T), alignof(T)>::type;
    std::array<StorageType, Capacity> m_storage;
    std::array<size_t, Capacity> m_freeIndices;
    size_t m_freeCount;
};

class UIBufferPool {
public:
    static uint8_t* acquire(size_t minSize);
    static void release(uint8_t* buffer);
    static void clear();

private:
    struct Bucket {
        size_t blockSize;
        std::vector<uint8_t*> freeBlocks;
        std::vector<uint8_t*> allBlocks;
    };

    static std::array<Bucket, 4>& getBuckets();
};

} // namespace starblast
