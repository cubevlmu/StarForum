import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/api/flarum_endpoint.dart';
import 'package:star_forum/data/api/services/api_parsing.dart';
import 'package:star_forum/data/model/posts.dart';

void main() {
  test('requests event content in post sparse fieldsets', () {
    expect(PostQueries.fields, contains('content'));
  });

  test('maps discussionStickied resources as post events', () {
    final posts = parsePosts({
      'data': [
        {
          'type': 'posts',
          'id': '281',
          'attributes': {
            'number': 2,
            'createdAt': '2026-07-14T07:25:54+00:00',
            'contentType': 'discussionStickied',
            'content': {'sticky': true},
          },
          'relationships': {
            'discussion': {
              'data': {'type': 'discussions', 'id': '98'},
            },
            'user': {
              'data': {'type': 'users', 'id': '8'},
            },
          },
        },
      ],
    });

    final post = posts.posts[281]!;
    expect(post.contentType, 'discussionStickied');
    expect(post.contentHtml, isEmpty);
    expect(post.event?.type, PostEventType.discussionStickyChanged);
    expect(post.event?.sticky, isTrue);
    expect(post.userId, 8);
    expect(post.discussion, 98);
  });
}
