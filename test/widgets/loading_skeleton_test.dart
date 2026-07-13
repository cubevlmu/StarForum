import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/widgets/post_list_loading_skeleton.dart';
import 'package:star_forum/widgets/shimmer_skeleton.dart';
import 'package:star_forum/widgets/two_column_loading_skeleton.dart';

void main() {
  testWidgets('post list skeleton fills a tall viewport', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SingleChildScrollView(child: PostListLoadingSkeleton()),
        ),
      ),
    );

    expect(find.byType(Divider), findsNWidgets(6));
    expect(tester.takeException(), isNull);
  });

  testWidgets('two column skeleton fills the available screen height', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            height: 500,
            child: TwoColumnLoadingSkeleton(
              cardHeight: 96,
              itemBuilder: (context, palette) => const _SkeletonItem(),
            ),
          ),
        ),
      ),
    );

    expect(find.byType(_SkeletonItem), findsNWidgets(8));
  });

  testWidgets('post list skeleton supports intrinsic sliver measurement', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverFillRemaining(
                hasScrollBody: false,
                child: PostListLoadingSkeleton(),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(PostListLoadingSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('post list skeleton supports a sliver box adapter', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: CustomScrollView(
            slivers: [SliverToBoxAdapter(child: PostListLoadingSkeleton())],
          ),
        ),
      ),
    );

    expect(find.byType(PostListLoadingSkeleton), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('skeleton bar width is relative to its parent', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: SkeletonBar(
              decoration: BoxDecoration(color: Colors.grey),
              widthFactor: 0.75,
              height: 12,
            ),
          ),
        ),
      ),
    );

    final bar = find.descendant(
      of: find.byType(SkeletonBar),
      matching: find.byType(DecoratedBox),
    );
    expect(tester.getSize(bar), const Size(300, 12));
  });

  testWidgets('skeleton bar supports an unconstrained width', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(400, 800);
    addTearDown(() {
      tester.view.resetDevicePixelRatio();
      tester.view.resetPhysicalSize();
    });

    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: UnconstrainedBox(
            child: SkeletonBar(
              decoration: BoxDecoration(color: Colors.grey),
              widthFactor: 0.2,
              height: 28,
            ),
          ),
        ),
      ),
    );

    final bar = find.descendant(
      of: find.byType(SkeletonBar),
      matching: find.byType(DecoratedBox),
    );
    expect(tester.getSize(bar), const Size(80, 28));
    expect(tester.takeException(), isNull);
  });
}

class _SkeletonItem extends StatelessWidget {
  const _SkeletonItem();

  @override
  Widget build(BuildContext context) => const SizedBox(height: 96);
}
