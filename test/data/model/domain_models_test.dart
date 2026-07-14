import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/model/discussions.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/data/model/users.dart';

void main() {
  group('UserInfo', () {
    test('mergedWith returns a new value without discarding cached fields', () {
      final cached = _user(
        displayName: 'Cached name',
        avatarUrl: 'cached.png',
        bio: 'Cached bio',
        discussionCount: 8,
      );
      final partialRemote = _user(
        displayName: 'Remote name',
        avatarUrl: '',
        bio: '',
        discussionCount: 0,
        commentCount: 12,
      );

      final merged = cached.mergedWith(partialRemote);

      expect(merged, isNot(same(cached)));
      expect(merged.displayName, 'Remote name');
      expect(merged.avatarUrl, 'cached.png');
      expect(merged.bio, 'Cached bio');
      expect(merged.discussionCount, 8);
      expect(merged.commentCount, 12);
      expect(cached.displayName, 'Cached name');
    });

    test('copyWith can explicitly clear nullable values', () {
      final user = _user(expInfo: const ExpInfo('1', 10, 50, '2', 10));

      expect(user.copyWith(expInfo: null).expInfo, isNull);
    });
  });

  test('PostInfo copyWith preserves the source and can clear its author', () {
    final source = PostInfo(
      1,
      '2026-01-01',
      '<p>before</p>',
      '',
      9,
      -1,
      3,
      2,
      user: _user(),
    );

    final changed = source.copyWith(
      contentHtml: '<p>after</p>',
      likes: 3,
      user: null,
    );

    expect(changed.contentHtml, '<p>after</p>');
    expect(changed.likes, 3);
    expect(changed.user, isNull);
    expect(source.contentHtml, '<p>before</p>');
    expect(source.likes, 2);
    expect(source.user, isNotNull);
  });

  test(
    'DiscussionDetail owns immutable relationships and projects a summary',
    () {
      final posts = <int, PostInfo>{
        4: const PostInfo(
          4,
          '2026-01-01',
          '<p>Hello <strong>world</strong></p>',
          '',
          9,
          -1,
          3,
          2,
        ),
      };
      final detail = DiscussionDetail(
        '3',
        'Topic',
        5,
        2,
        42,
        DateTime.utc(2026, 1, 1),
        DateTime.utc(2026, 1, 2),
        5,
        4,
        _user(),
        null,
        posts[4],
        [4],
        posts,
        {9: _user()},
        const [],
        1,
        isSticky: true,
      );

      posts.clear();
      final summary = detail.toSummary();

      expect(detail.posts, hasLength(1));
      expect(() => detail.posts.clear(), throwsUnsupportedError);
      expect(summary.title, 'Topic');
      expect(summary.excerpt, 'Hello world');
      expect(summary.viewCount, 42);
      expect(summary.participantCount, 2);
      expect(summary.userId, 9);
      expect(summary.isSticky, isTrue);
    },
  );
}

UserInfo _user({
  String displayName = 'User',
  String avatarUrl = 'avatar.png',
  String bio = 'Bio',
  int discussionCount = 1,
  int commentCount = 1,
  ExpInfo? expInfo,
}) {
  return UserInfo(
    9,
    'user',
    displayName,
    avatarUrl,
    DateTime.utc(2020),
    discussionCount,
    commentCount,
    DateTime.utc(2026),
    'user@example.com',
    null,
    bio,
    expInfo: expInfo,
  );
}
