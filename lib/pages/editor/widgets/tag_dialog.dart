/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';

class EditorTagSelection {
  const EditorTagSelection({
    required this.primaryTag,
    required this.secondaryTags,
  });

  final TagInfo? primaryTag;
  final List<TagInfo> secondaryTags;
}

class EditorTagDialog extends StatefulWidget {
  const EditorTagDialog({
    super.key,
    required this.rootTags,
    required this.normalTags,
    this.initialPrimaryTag,
    this.initialSecondaryTags = const [],
  });

  final List<TagInfo> rootTags;
  final List<TagInfo> normalTags;
  final TagInfo? initialPrimaryTag;
  final List<TagInfo> initialSecondaryTags;

  static Future<EditorTagSelection?> show(
    BuildContext context, {
    required List<TagInfo> rootTags,
    required List<TagInfo> normalTags,
    TagInfo? initialPrimaryTag,
    List<TagInfo> initialSecondaryTags = const [],
  }) {
    return showDialog<EditorTagSelection>(
      context: context,
      builder: (context) => EditorTagDialog(
        rootTags: rootTags,
        normalTags: normalTags,
        initialPrimaryTag: initialPrimaryTag,
        initialSecondaryTags: initialSecondaryTags,
      ),
    );
  }

  @override
  State<EditorTagDialog> createState() => _EditorTagDialogState();
}

class _EditorTagDialogState extends State<EditorTagDialog> {
  TagInfo? _selectedPrimaryTag;
  late final List<TagInfo> _selectedSecondaryTags;
  late final List<({TagInfo tag, int depth})> _primaryEntries;

  @override
  void initState() {
    _selectedPrimaryTag = widget.initialPrimaryTag;
    _selectedSecondaryTags = widget.initialSecondaryTags.toList();
    _primaryEntries = _flattenTags(widget.rootTags);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;

    return Dialog(
      backgroundColor: colors.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(FUITokens.radiusXl),
        side: BorderSide(color: colors.border),
      ),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 560, maxHeight: 720),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 16, 12, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tagDialogTitle,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: colors.textPrimary,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  FUIIconButton(
                    icon: FUIIcons.close,
                    variant: FUIIconButtonVariant.outline,
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            // Selection preview + confirm
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _TagSelectionPreview(
                      primaryTag: _selectedPrimaryTag,
                      secondaryTags: _selectedSecondaryTags,
                      placeholder: l10n.editorTagPrimaryPlaceholder,
                    ),
                  ),
                  const SizedBox(width: FUITokens.gap10),
                  FUIButton(
                    label: l10n.commonActionConfirm,
                    onPressed: _selectedPrimaryTag == null
                        ? null
                        : () => Navigator.of(context).pop(
                            EditorTagSelection(
                              primaryTag: _selectedPrimaryTag,
                              secondaryTags: _selectedSecondaryTags,
                            ),
                          ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colors.border),
            // Tag list
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                  FUITokens.gap10,
                  FUITokens.gap8,
                  FUITokens.gap10,
                  FUITokens.gap10,
                ),
                children: [
                  _SectionLabel(label: l10n.editorPrimaryTagSection),
                  const SizedBox(height: FUITokens.gap6),
                  ..._primaryEntries.map((entry) {
                    final selected = _selectedPrimaryTag?.id == entry.tag.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: FUITokens.gap4),
                      child: _TagTile(
                        tag: entry.tag,
                        depth: entry.depth,
                        selected: selected,
                        isCheckbox: false,
                        onTap: () {
                          setState(() => _selectedPrimaryTag = entry.tag);
                        },
                      ),
                    );
                  }),
                  if (widget.normalTags.isNotEmpty) ...[
                    const SizedBox(height: FUITokens.gap10),
                    Divider(height: 1, color: colors.border),
                    const SizedBox(height: FUITokens.gap10),
                    _SectionLabel(label: l10n.editorSecondaryTagSection),
                    const SizedBox(height: FUITokens.gap6),
                    ...widget.normalTags.map((tag) {
                      final selected = _selectedSecondaryTags.any(
                        (item) => item.id == tag.id,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: FUITokens.gap4),
                        child: _TagTile(
                          tag: tag,
                          depth: 0,
                          selected: selected,
                          isCheckbox: true,
                          onTap: () => setState(() => _toggleSecondaryTag(tag)),
                        ),
                      );
                    }),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSecondaryTag(TagInfo tag) {
    final index = _selectedSecondaryTags.indexWhere(
      (item) => item.id == tag.id,
    );
    if (index >= 0) {
      _selectedSecondaryTags.removeAt(index);
    } else {
      _selectedSecondaryTags.add(tag);
    }
  }

  List<({TagInfo tag, int depth})> _flattenTags(List<TagInfo> roots) {
    final result = <({TagInfo tag, int depth})>[];

    void visit(TagInfo tag, int depth) {
      if (tag.canStartDiscussion) {
        result.add((tag: tag, depth: depth));
      }
      final children = tag.children?.values.toList() ?? const <TagInfo>[];
      for (final child in children) {
        visit(child, depth + 1);
      }
    }

    for (final tag in roots) {
      visit(tag, 0);
    }
    return result;
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(FUITokens.gap4, 0, 0, 0),
      child: Text(
        label,
        style: TextStyle(
          color: colors.textSecondary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TagSelectionPreview extends StatelessWidget {
  const _TagSelectionPreview({
    required this.primaryTag,
    required this.secondaryTags,
    required this.placeholder,
  });

  final TagInfo? primaryTag;
  final List<TagInfo> secondaryTags;
  final String placeholder;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final hasSelection = primaryTag != null || secondaryTags.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 46),
      padding: const EdgeInsets.symmetric(
        horizontal: FUITokens.gap12,
        vertical: FUITokens.gap8,
      ),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colors.surfaceAlt,
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
        border: Border.all(color: colors.border),
      ),
      child: !hasSelection
          ? Text(
              placeholder,
              style: TextStyle(color: colors.textTertiary, fontSize: 13),
            )
          : Wrap(
              spacing: FUITokens.gap6,
              runSpacing: FUITokens.gap6,
              children: [
                if (primaryTag != null)
                  FUITag(
                    label: primaryTag!.name,
                    variant: FUITagVariant.primary,
                  ),
                ...secondaryTags.map(
                  (tag) =>
                      FUITag(label: tag.name, variant: FUITagVariant.neutral),
                ),
              ],
            ),
    );
  }
}

class _TagTile extends StatelessWidget {
  const _TagTile({
    required this.tag,
    required this.depth,
    required this.selected,
    required this.isCheckbox,
    required this.onTap,
  });

  final TagInfo tag;
  final int depth;
  final bool selected;
  final bool isCheckbox;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final description = tag.description.trim();

    return Material(
      color: selected && !isCheckbox ? colors.primarySoft : Colors.transparent,
      borderRadius: BorderRadius.circular(FUITokens.radiusMd),
      child: InkWell(
        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            FUITokens.gap12 + depth * 18.0,
            FUITokens.gap10,
            FUITokens.gap8,
            FUITokens.gap10,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon box
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? colors.primary.withValues(alpha: 0.12)
                      : colors.surfaceAlt,
                  borderRadius: BorderRadius.circular(FUITokens.radiusSm),
                  border: Border.all(
                    color: selected
                        ? colors.primary.withValues(alpha: 0.3)
                        : colors.border,
                  ),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _tagIcon(),
                  size: FUITokens.iconSm,
                  color: selected ? colors.primary : colors.textTertiary,
                ),
              ),
              const SizedBox(width: FUITokens.gap10),
              // Text
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag.name,
                      style: TextStyle(
                        color: selected ? colors.primary : colors.textPrimary,
                        fontSize: 14,
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: TextStyle(
                          color: colors.textSecondary,
                          fontSize: 12,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              // Trailing indicator
              if (isCheckbox)
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    color: selected ? colors.primary : colors.surface,
                    borderRadius: BorderRadius.circular(FUITokens.radiusXs),
                    border: Border.all(
                      color: selected ? colors.primary : colors.border,
                    ),
                  ),
                  child: selected
                      ? Icon(
                          FUIIcons.checkmark,
                          size: 14,
                          color: colors.textInverse,
                        )
                      : null,
                )
              else
                Icon(
                  selected
                      ? Icons.check_circle_rounded
                      : Icons.radio_button_unchecked_rounded,
                  size: 20,
                  color: selected ? colors.primary : colors.textTertiary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _tagIcon() {
    if (tag.isChild) return Icons.subdirectory_arrow_right_rounded;
    if ((tag.position ?? 99) <= 3) return Icons.push_pin_outlined;
    return ForumIcons.tags;
  }
}
