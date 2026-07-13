import 'dart:collection';

class WeightedLruCache<K, V> {
  WeightedLruCache({required this.maxEntries, required this.maxWeight})
    : assert(maxEntries > 0),
      assert(maxWeight > 0);

  final int maxEntries;
  final int maxWeight;
  final LinkedHashMap<K, _WeightedValue<V>> _entries = LinkedHashMap();
  int _totalWeight = 0;

  int get length => _entries.length;
  int get totalWeight => _totalWeight;

  V? get(K key) {
    final entry = _entries.remove(key);
    if (entry == null) return null;
    _entries[key] = entry;
    return entry.value;
  }

  void put(K key, V value, {required int weight}) {
    final normalizedWeight = weight < 1 ? 1 : weight;
    final previous = _entries.remove(key);
    if (previous != null) _totalWeight -= previous.weight;
    if (normalizedWeight > maxWeight) return;

    _entries[key] = _WeightedValue(value, normalizedWeight);
    _totalWeight += normalizedWeight;
    while (_entries.length > maxEntries || _totalWeight > maxWeight) {
      final oldestKey = _entries.keys.first;
      _totalWeight -= _entries.remove(oldestKey)!.weight;
    }
  }

  void clear() {
    _entries.clear();
    _totalWeight = 0;
  }
}

class _WeightedValue<V> {
  const _WeightedValue(this.value, this.weight);

  final V value;
  final int weight;
}
