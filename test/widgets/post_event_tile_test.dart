import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/model/posts.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/post_detail/widgets/post_item.dart';
import 'package:star_forum/widgets/content_view.dart';

void main() {
  testWidgets('renders a sticky event as a compact tip instead of a reply', (
    tester,
  ) async {
    const post = PostInfo(
      281,
      '2026-07-14T07:25:54+00:00',
      '',
      '',
      8,
      -1,
      98,
      0,
      contentType: 'discussionStickied',
      event: PostEvent.discussionStickyChanged(sticky: true),
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: FuiTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: PostItemWidget(reply: post)),
      ),
    );
    await tester.pump();

    expect(find.text('Pinned discussion'), findsOneWidget);
    expect(find.byIcon(ForumIcons.sticky), findsOneWidget);
    expect(find.byType(ContentView), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
