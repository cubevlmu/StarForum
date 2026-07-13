import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/pages/post_detail/controller.dart';

void main() {
  test('reply count excludes the first post', () {
    expect(replyCountFromCommentCount(-1), 0);
    expect(replyCountFromCommentCount(0), 0);
    expect(replyCountFromCommentCount(1), 0);
    expect(replyCountFromCommentCount(8), 7);
  });

  test('hot replies sort by likes then post number', () {
    final replies = <PostInfo>[
      _post(id: 1, likes: 2, number: 4),
      _post(id: 2, likes: 7, number: 5),
      _post(id: 3, likes: 7, number: 2),
      _post(id: 4, likes: 0, number: 3),
    ]..sort(compareReplyHotness);

    expect(replies.map((reply) => reply.id), <int>[3, 2, 1, 4]);
  });
}

PostInfo _post({required int id, required int likes, required int number}) {
  return PostInfo(
    id,
    '2026-07-14T00:00:00Z',
    '<p>Reply</p>',
    '',
    1,
    0,
    1,
    likes,
    number: number,
  );
}
