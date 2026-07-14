import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/model/discussion_summary.dart';
import 'package:star_forum/widgets/post_card.dart';

void main() {
  testWidgets('discussion tile keeps views visible and omits likes', (
    tester,
  ) async {
    const longAuthor = 'user-1234567890123456789012345678901234567890';
    final now = DateTime(2026, 7, 14);
    final discussion = DiscussionSummary(
      id: '1',
      title: 'A discussion',
      excerpt: '',
      authorName: longAuthor,
      viewCount: 42,
      likeCount: 99,
      commentCount: 3,
      lastPostedAt: now,
      createdAt: now,
      userId: 1,
      subscription: 0,
      isSticky: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: FuiTheme.light(),
        home: Scaffold(
          body: SizedBox(width: 296, child: PostCard(item: discussion)),
        ),
      ),
    );
    await tester.pump();

    final authorText = tester.widget<Text>(find.text(longAuthor));
    expect(authorText.maxLines, 1);
    expect(authorText.overflow, TextOverflow.ellipsis);
    expect(find.byIcon(FUIIcons.visibility), findsOneWidget);
    expect(find.byIcon(ForumIcons.like), findsNothing);
    expect(find.byIcon(ForumIcons.sticky), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
