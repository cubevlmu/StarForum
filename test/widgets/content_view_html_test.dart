import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/widgets/content_view.dart';

void main() {
  testWidgets('code blocks do not render embedded syntax highlighter scripts', (
    tester,
  ) async {
    const html = '''
<h3>作案人员 ABO_SI250</h3>
<p>行为 破坏机器和建筑<br>
期间加入群内展示自己行为<br>
处理 <strong>永久封禁</strong></p>
<pre><code>嫌疑人信息
QQ号 3380850560
物理位置 金华</code><script src="highlight.js"></script><script>
window.hljsLoader.highlightBlocks(document.currentScript.parentNode);
</script></pre>
<p><em>请大家引以为戒！</em></p>
''';

    await tester.pumpWidget(
      MaterialApp(
        theme: FuiTheme.light(),
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const Scaffold(body: ContentView(content: html)),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('作案人员 ABO_SI250'), findsOneWidget);
    final paragraph = tester.widget<Text>(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text &&
            (widget.textSpan?.toPlainText().contains('行为 破坏机器') ?? false),
      ),
    );
    expect(
      paragraph.textSpan?.toPlainText(),
      '行为 破坏机器和建筑\n期间加入群内展示自己行为\n处理 永久封禁',
    );
    expect(find.text('嫌疑人信息\nQQ号 3380850560\n物理位置 金华'), findsOneWidget);
    expect(find.textContaining('hljsLoader'), findsNothing);
    expect(find.textContaining('highlight.js'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
