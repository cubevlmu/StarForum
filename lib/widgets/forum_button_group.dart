import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/app/forum_layout.dart';
import 'package:star_forum/utils/setting_util.dart';

class ForumButtonGroupItem {
  const ForumButtonGroupItem({
    required this.icon,
    required this.label,
    this.tooltip,
  });

  final IconData icon;
  final String label;
  final String? tooltip;
}

class ForumButtonGroup extends StatelessWidget {
  const ForumButtonGroup({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onSelected,
    this.alignment,
    this.padding = const EdgeInsets.fromLTRB(
      ForumLayout.edge,
      0,
      ForumLayout.edge,
      0,
    ),
  });

  final List<ForumButtonGroupItem> items;
  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final AlignmentGeometry? alignment;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final resolvedAlignment = alignment ?? _resolveAlignment();
    return Padding(
      padding: padding,
      child: SizedBox(
        width: double.infinity,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: colors.surfaceAlt,
            borderRadius: BorderRadius.circular(FUITokens.radiusSm),
            border: Border.all(color: colors.border),
          ),
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Align(
              alignment: resolvedAlignment,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: _ForumButtonGroupTrack(
                  items: items,
                  selectedIndex: selectedIndex,
                  showLabels: !SettingsUtil.buttonGroupIconOnly,
                  onSelected: onSelected,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  AlignmentGeometry _resolveAlignment() {
    switch (SettingsUtil.buttonGroupAlignment) {
      case ButtonGroupAlignmentPreference.automatic:
      case ButtonGroupAlignmentPreference.leading:
        return Alignment.centerLeft;
      case ButtonGroupAlignmentPreference.centered:
        return Alignment.center;
    }
  }
}

class _ForumButtonGroupTrack extends StatefulWidget {
  const _ForumButtonGroupTrack({
    required this.items,
    required this.selectedIndex,
    required this.showLabels,
    required this.onSelected,
  });

  final List<ForumButtonGroupItem> items;
  final int selectedIndex;
  final bool showLabels;
  final ValueChanged<int> onSelected;

  @override
  State<_ForumButtonGroupTrack> createState() => _ForumButtonGroupTrackState();
}

class _ForumButtonGroupTrackState extends State<_ForumButtonGroupTrack> {
  final GlobalKey _trackKey = GlobalKey();
  late List<GlobalKey> _buttonKeys;
  double _indicatorLeft = 0;
  double _indicatorWidth = 0;

  @override
  void initState() {
    super.initState();
    _buttonKeys = List.generate(widget.items.length, (_) => GlobalKey());
    _scheduleIndicatorMeasure();
  }

  @override
  void didUpdateWidget(covariant _ForumButtonGroupTrack oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.items.length != widget.items.length) {
      _buttonKeys = List.generate(widget.items.length, (_) => GlobalKey());
    }
    _scheduleIndicatorMeasure();
  }

  void _scheduleIndicatorMeasure() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || widget.items.isEmpty) return;
      final index = widget.selectedIndex.clamp(0, widget.items.length - 1);
      final trackContext = _trackKey.currentContext;
      final buttonContext = _buttonKeys[index].currentContext;
      if (trackContext == null || buttonContext == null) return;

      final trackBox = trackContext.findRenderObject();
      final buttonBox = buttonContext.findRenderObject();
      if (trackBox is! RenderBox || buttonBox is! RenderBox) return;
      if (!trackBox.hasSize || !buttonBox.hasSize) return;

      final buttonGlobal = buttonBox.localToGlobal(Offset.zero);
      final buttonLocal = trackBox.globalToLocal(buttonGlobal);
      final nextLeft = buttonLocal.dx;
      final nextWidth = buttonBox.size.width;
      if ((nextLeft - _indicatorLeft).abs() < 0.5 &&
          (nextWidth - _indicatorWidth).abs() < 0.5) {
        return;
      }
      setState(() {
        _indicatorLeft = nextLeft;
        _indicatorWidth = nextWidth;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final selectedIndex = widget.items.isEmpty
        ? -1
        : widget.selectedIndex.clamp(0, widget.items.length - 1);
    return Stack(
      key: _trackKey,
      children: [
        if (selectedIndex >= 0 && _indicatorWidth > 0)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            left: _indicatorLeft,
            top: 0,
            bottom: 0,
            width: _indicatorWidth,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(6),
              ),
            ),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var index = 0; index < widget.items.length; index++) ...[
              _ForumButtonGroupButton(
                key: _buttonKeys[index],
                item: widget.items[index],
                selected: selectedIndex == index,
                showLabel: widget.showLabels,
                onTap: () => widget.onSelected(index),
              ),
              if (index != widget.items.length - 1)
                const SizedBox(width: FUITokens.gap4),
            ],
          ],
        ),
      ],
    );
  }
}

class _ForumButtonGroupButton extends StatelessWidget {
  const _ForumButtonGroupButton({
    super.key,
    required this.item,
    required this.selected,
    required this.showLabel,
    required this.onTap,
  });

  final ForumButtonGroupItem item;
  final bool selected;
  final bool showLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final foreground = selected ? colors.textInverse : colors.textSecondary;
    return Tooltip(
      message: item.tooltip ?? item.label,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(6),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minWidth: 42, minHeight: 36),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: showLabel ? FUITokens.gap12 : 0,
              ),
              child: AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 160),
                curve: Curves.easeOutCubic,
                style:
                    Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      height: 1,
                    ) ??
                    TextStyle(
                      color: foreground,
                      fontWeight: selected ? FontWeight.w800 : FontWeight.w700,
                      height: 1,
                    ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(item.icon, size: 18, color: foreground),
                    if (showLabel) ...[
                      const SizedBox(width: FUITokens.gap6),
                      Text(
                        item.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
