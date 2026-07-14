import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/utils/html_utils.dart';

void main() {
  test(
    'plain text conversion excludes scripts and separates block content',
    () {
      const html = '''
<h3>作案人员 ABO_SI250</h3>
<p>行为 破坏机器和建筑<br>处理 <strong>永久封禁</strong></p>
<pre><code>嫌疑人信息
QQ号 3380850560</code><script src="highlight.js"></script><script>
window.hljsLoader.highlightBlocks(document.currentScript.parentNode);
</script></pre>
<p><em>请大家引以为戒！</em></p>
''';

      final text = htmlToPlainText(html);

      expect(text, contains('作案人员 ABO_SI250 行为'));
      expect(text, contains('永久封禁 嫌疑人信息'));
      expect(text, contains('QQ号 3380850560 请大家引以为戒！'));
      expect(text, isNot(contains('hljsLoader')));
      expect(text, isNot(contains('highlight.js')));
    },
  );
}
