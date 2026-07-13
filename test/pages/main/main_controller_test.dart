import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/pages/main/controller.dart';

void main() {
  test('resetToHome clears retained navigation and search state', () {
    final controller = MainController();
    controller.selectedIndex.value = 3;
    controller.isHomeSearchActive.value = true;
    controller.homeSearchKeyword.value = 'query';

    controller.resetToHome();

    expect(controller.selectedIndex.value, 0);
    expect(controller.isHomeSearchActive.value, isFalse);
    expect(controller.homeSearchKeyword.value, isNull);
  });
}
