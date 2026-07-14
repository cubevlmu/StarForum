import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/api/flarum_endpoint.dart';
import 'package:star_forum/data/api/services/api_parsing.dart';

void main() {
  test('requests the isSticky field in discussion sparse fieldsets', () {
    expect(DiscussionQueries.discussionFields, contains('isSticky'));
  });

  test('maps the Flarum isSticky discussion attribute', () {
    final discussions = parseDiscussions({
      'data': [
        {
          'type': 'discussions',
          'id': '42',
          'attributes': {
            'title': 'Pinned topic',
            'commentCount': 1,
            'participantCount': 1,
            'viewCount': 8,
            'createdAt': '2026-07-14T00:00:00.000Z',
            'lastPostedAt': '2026-07-14T00:00:00.000Z',
            'lastPostNumber': 1,
            'isSticky': true,
          },
        },
      ],
    });

    expect(discussions, hasLength(1));
    expect(discussions.single.isSticky, isTrue);
    expect(discussions.single.toSummary().isSticky, isTrue);
  });
}
