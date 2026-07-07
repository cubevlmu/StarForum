import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';

abstract final class ForumLayout {
  const ForumLayout._();

  static const double edge = FUITokens.gap12;
  static const double cardGap = 3;
  static const double sectionGap = FUITokens.gap8;

  static const EdgeInsets pageHeadPadding = EdgeInsets.fromLTRB(
    FUITokens.pagePadding,
    FUITokens.gap12,
    FUITokens.pagePadding,
    FUITokens.gap4,
  );

  static const EdgeInsets listItemPadding = EdgeInsets.fromLTRB(
    edge,
    cardGap,
    edge,
    cardGap,
  );

  static const EdgeInsets tabBarPadding = EdgeInsets.zero;

  static const EdgeInsets tabLabelPadding = EdgeInsets.only(
    left: FUITokens.pagePadding,
    right: FUITokens.gap24,
  );

  static TextStyle? selectedTabStyle(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w800);

  static TextStyle? unselectedTabStyle(BuildContext context) => Theme.of(
    context,
  ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600);
}
