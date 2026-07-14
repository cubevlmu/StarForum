import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/utils/app_language.dart';

void main() {
  test('resolves every supported locale to its selected language item', () {
    for (final language in languages) {
      expect(appLanguageForLocale(language.locale), same(language));
    }
  });

  test('keeps traditional Chinese distinct from simplified Chinese', () {
    final traditional = appLanguageForLocale(
      const Locale.fromSubtags(
        languageCode: 'zh',
        scriptCode: 'Hant',
        countryCode: 'TW',
      ),
    );

    expect(traditional.locale.scriptCode, 'Hant');
    expect(appLanguageForLocale(const Locale('zh')).locale.scriptCode, isNull);
  });
}
