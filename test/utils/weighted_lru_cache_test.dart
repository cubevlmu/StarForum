import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/utils/content_hash_key.dart';
import 'package:star_forum/utils/weighted_lru_cache.dart';

void main() {
  test('evicts least recently used entry by weight', () {
    final cache = WeightedLruCache<String, int>(maxEntries: 3, maxWeight: 5);
    cache.put('a', 1, weight: 2);
    cache.put('b', 2, weight: 2);
    expect(cache.get('a'), 1);

    cache.put('c', 3, weight: 2);

    expect(cache.get('b'), isNull);
    expect(cache.get('a'), 1);
    expect(cache.get('c'), 3);
    expect(cache.totalWeight, 4);
  });

  test('does not retain an entry larger than the byte budget', () {
    final cache = WeightedLruCache<String, int>(maxEntries: 2, maxWeight: 4);
    cache.put('large', 1, weight: 5);

    expect(cache.length, 0);
    expect(cache.totalWeight, 0);
  });

  test('content key includes length and two hashes', () {
    final first = ContentHashKey.fromString('<p>hello</p>');
    final same = ContentHashKey.fromString('<p>hello</p>');
    final different = ContentHashKey.fromString('<p>world</p>');

    expect(first, same);
    expect(first, isNot(different));
  });
}
