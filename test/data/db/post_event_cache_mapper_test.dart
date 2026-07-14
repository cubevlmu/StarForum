import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/db/app_database.dart';
import 'package:star_forum/data/db/mappers/post_cache_mapper.dart';
import 'package:star_forum/data/model/posts.dart';

void main() {
  test('post event payload survives the database cache mapping', () {
    const post = PostInfo(
      281,
      '2026-07-14T07:25:54+00:00',
      '',
      '',
      8,
      -1,
      98,
      0,
      number: 2,
      contentType: 'discussionStickied',
      event: PostEvent.discussionStickyChanged(sticky: true),
    );
    final cached = post.toDbPost();

    final restored = DbPost(
      id: post.id,
      discussionId: post.discussion,
      number: post.number,
      userId: post.userId,
      contentType: post.contentType,
      contentHtml: post.contentHtml,
      createdAt: DateTime.parse(post.createdAt),
      likesCount: post.likes,
      isLiked: post.isLiked,
      fingerprint: post.fingerprint,
      rawJson: cached.rawJson.value,
      syncedAt: DateTime.utc(2026, 7, 14),
    ).toPostInfo();

    expect(restored.event?.type, PostEventType.discussionStickyChanged);
    expect(restored.event?.sticky, isTrue);
  });
}
