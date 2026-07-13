import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/repository/discussion/discussion_excerpt_hydrator.dart';

void main() {
  test('builds plain text excerpts and truncates them', () {
    final results = buildDiscussionExcerptResults([
      DiscussionExcerptTask(
        discussionId: '42',
        contentHtml: '<p>${'content ' * 20}</p>',
        sourceUpdatedAt: DateTime.utc(2026, 7, 13),
      ),
    ]);

    expect(results, hasLength(1));
    expect(results.single.discussionId, '42');
    expect(results.single.excerpt, hasLength(80));
    expect(results.single.excerpt, isNot(contains('<p>')));
  });

  test('drops empty placeholder excerpts', () {
    final results = buildDiscussionExcerptResults([
      DiscussionExcerptTask(
        discussionId: '1',
        contentHtml: '<p>...</p>',
        sourceUpdatedAt: DateTime.utc(2026, 7, 13),
      ),
      DiscussionExcerptTask(
        discussionId: '2',
        contentHtml: '<p> </p>',
        sourceUpdatedAt: DateTime.utc(2026, 7, 13),
      ),
    ]);

    expect(results, isEmpty);
  });
}
