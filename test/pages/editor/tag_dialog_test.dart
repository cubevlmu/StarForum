import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/editor/widgets/tag_dialog.dart';

void main() {
  testWidgets('mobile tag selection opens as a usable bottom sheet', (
    tester,
  ) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(390, 844);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    EditorTagSelection? result;
    final primaryTag = TagInfo(
      'General',
      1,
      'General discussions',
      'general',
      0,
      0,
      '',
      null,
      -1,
      false,
      null,
      true,
    );
    final normalTag = TagInfo(
      'Support',
      2,
      'Support discussions',
      'support',
      0,
      null,
      '',
      null,
      -1,
      false,
      null,
      true,
    );

    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: FuiTheme.light(),
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async {
              result = await EditorTagDialog.show(
                context,
                rootTags: [primaryTag],
                normalTags: [normalTag],
              );
            },
            child: const Text('Open'),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Open'));
    await tester.pumpAndSettle();

    expect(find.byType(EditorTagDialog), findsOneWidget);
    expect(
      tester.widget<EditorTagDialog>(find.byType(EditorTagDialog)).compact,
      isTrue,
    );
    expect(find.text('Support'), findsOneWidget);

    await tester.tap(find.text('General'));
    await tester.pump();
    await tester.tap(find.text('Support'));
    await tester.pump();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();

    expect(result?.primaryTag?.id, 1);
    expect(result?.secondaryTags.map((tag) => tag.id), [2]);
  });
}
