import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('intrinsic button group uses its minimum icon-only width', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: FuiTheme.light(),
        home: Scaffold(
          body: Align(
            alignment: AlignmentDirectional.centerStart,
            child: IntrinsicWidth(
              child: FUIButtonGroupTabBar(
                items: const [
                  FUIButtonGroupTabItem(icon: Icons.favorite, label: 'Hot'),
                  FUIButtonGroupTabItem(
                    icon: Icons.arrow_upward,
                    label: 'Oldest',
                  ),
                  FUIButtonGroupTabItem(
                    icon: Icons.arrow_downward,
                    label: 'Newest',
                  ),
                ],
                selectedIndex: 0,
                showLabels: false,
                alignment: AlignmentDirectional.centerStart,
                onSelected: (_) {},
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(
      tester.getSize(find.byType(FUIButtonGroupTabBar)).width,
      FUITokens.gap4 * 4 + 42 * 3,
    );
  });
}
