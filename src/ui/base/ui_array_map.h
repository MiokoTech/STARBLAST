// Struktur data koleksi terurut dua arah antarmuka.
#ifndef STARBLAST_UI_ARRAY_MAP_H
#define STARBLAST_UI_ARRAY_MAP_H

#include <vector>
#include <unordered_map>
#include <algorithm>

namespace starblast {

template <typename K, typename V>
class UIArrayMap {
public:
    UIArrayMap() = default;
    ~UIArrayMap() = default;

    void put(const K& key, const V& value) {
        auto it = m_map.find(key);
        if (it != m_map.end()) {
            it->second = value;
        } else {
            m_keys.push_back(key);
            m_map[key] = value;
        }
    }

    bool contains(const K& key) const {
        return m_map.find(key) != m_map.end();
    }

    V* get(const K& key) {
        auto it = m_map.find(key);
        if (it != m_map.end()) {
            return &(it->second);
        }
        return nullptr;
    }

    const V* get(const K& key) const {
        auto it = m_map.find(key);
        if (it != m_map.end()) {
            return &(it->second);
        }
        return nullptr;
    }

    V* getByIndex(size_t index) {
        if (index < m_keys.size()) {
            return get(m_keys[index]);
        }
        return nullptr;
    }

    const V* getByIndex(size_t index) const {
        if (index < m_keys.size()) {
            return get(m_keys[index]);
        }
        return nullptr;
    }

    const K* getKeyByIndex(size_t index) const {
        if (index < m_keys.size()) {
            return &m_keys[index];
        }
        return nullptr;
    }

    int indexOf(const K& key) const {
        for (size_t i = 0; i < m_keys.size(); ++i) {
            if (m_keys[i] == key) {
                return static_cast<int>(i);
            }
        }
        return -1;
    }

    bool remove(const K& key) {
        auto it = m_map.find(key);
        if (it == m_map.end()) {
            return false;
        }
        m_map.erase(it);
        m_keys.erase(std::remove(m_keys.begin(), m_keys.end(), key), m_keys.end());
        return true;
    }

    void clear() {
        m_keys.clear();
        m_map.clear();
    }

    size_t size() const {
        return m_keys.size();
    }

    bool empty() const {
        return m_keys.empty();
    }

    const std::vector<K>& getKeys() const {
        return m_keys;
    }

private:
    std::vector<K> m_keys;
    std::unordered_map<K, V> m_map;
};

}

#endif
