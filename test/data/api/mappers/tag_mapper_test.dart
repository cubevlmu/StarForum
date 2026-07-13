import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/api/services/api_parsing.dart';

void main() {
  test('keeps null-position tags in the normal tag collection', () {
    final tags = parseTags({
      'data': [
        {
          'type': 'tags',
          'id': '1',
          'attributes': {
            'name': 'General',
            'slug': 'general',
            'position': 0,
            'canStartDiscussion': true,
          },
        },
        {
          'type': 'tags',
          'id': '2',
          'attributes': {
            'name': 'Support',
            'slug': 'support',
            'position': null,
            'canStartDiscussion': true,
          },
        },
        {
          'type': 'tags',
          'id': '3',
          'attributes': {
            'name': 'Off topic',
            'slug': 'off-topic',
            'position': null,
            'canStartDiscussion': true,
          },
        },
      ],
    });

    expect(tags.tags.values.map((tag) => tag.id), [1]);
    expect(tags.miniTags.keys, containsAll(<int>[2, 3]));
    expect(tags.miniTags, hasLength(2));
  });
}
