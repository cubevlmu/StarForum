/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/l10n/app_localizations.dart';

class EditorTagSelection {
  const EditorTagSelection({required this.primaryTag, required this.secondaryTags});

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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 580, maxHeight: 760),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 14),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      l10n.tagDialogTitle,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close_rounded),
                    visualDensity: VisualDensity.compact,
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: _TagInputShell(
                      primaryTag: _selectedPrimaryTag,
                      secondaryTags: _selectedSecondaryTags,
                    ),
                  ),
                  const SizedBox(width: 10),
                  FilledButton(
                    onPressed: _selectedPrimaryTag == null
                        ? null
                        : () => Navigator.of(context).pop(
                            EditorTagSelection(
                              primaryTag: _selectedPrimaryTag,
                              secondaryTags: _selectedSecondaryTags,
                            ),
                          ),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 52),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                    ),
                    child: Text(l10n.commonActionConfirm),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: colorScheme.outlineVariant),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(10, 8, 10, 10),
                children: [
                  _SectionTitle(label: l10n.editorPrimaryTagSection),
                  const SizedBox(height: 6),
                  ..._primaryEntries.map((entry) {
                    final selected = _selectedPrimaryTag?.id == entry.tag.id;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: _TagListTile(
                        tag: entry.tag,
                        depth: entry.depth,
                        selected: selected,
                        trailing: selected
                            ? Icon(
                                Icons.check_circle_rounded,
                                size: 20,
                                color: colorScheme.primary,
                              )
                            : const Icon(
                                Icons.radio_button_unchecked_rounded,
                                size: 20,
                              ),
                        onTap: () {
                          setState(() {
                            _selectedPrimaryTag = entry.tag;
                          });
                        },
                      ),
                    );
                  }),
                  if (widget.normalTags.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Divider(height: 1, color: colorScheme.outlineVariant),
                    const SizedBox(height: 10),
                    _SectionTitle(label: l10n.editorSecondaryTagSection),
                    const SizedBox(height: 6),
                    ...widget.normalTags.map((tag) {
                      final selected = _selectedSecondaryTags.any(
                        (item) => item.id == tag.id,
                      );
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 4),
                        child: _TagListTile(
                          tag: tag,
                          depth: 0,
                          selected: selected,
                          trailing: Checkbox(
                            value: selected,
                            onChanged: (_) => _toggleSecondaryTag(tag),
                          ),
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
    final index = _selectedSecondaryTags.indexWhere((item) => item.id == tag.id);
    if (index >= 0) {
      _selectedSecondaryTags.removeAt(index);
      return;
    }
    _selectedSecondaryTags.add(tag);
  }

  List<({TagInfo tag, int depth})> _flattenTags(List<TagInfo> roots) {
    final result = <({TagInfo tag, int depth})>[];

    void visit(TagInfo tag, int depth) {
      if (!tag.canStartDiscussion) {
        return;
      }
      result.add((tag: tag, depth: depth));
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: Theme.of(context).textTheme.labelLarge?.copyWith(
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _TagInputShell extends StatelessWidget {
  const _TagInputShell({
    required this.primaryTag,
    required this.secondaryTags,
  });

  final TagInfo? primaryTag;
  final List<TagInfo> secondaryTags;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasSelection = primaryTag != null || secondaryTags.isNotEmpty;

    return Container(
      constraints: const BoxConstraints(minHeight: 52),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: !hasSelection
          ? Text(
              l10n.editorTagPrimaryPlaceholder,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            )
          : Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (primaryTag != null)
                  _SelectedTagChip(
                    label: primaryTag!.name,
                    emphasized: true,
                  ),
                ...secondaryTags.map(
                  (tag) => _SelectedTagChip(label: tag.name, emphasized: false),
                ),
              ],
            ),
    );
  }
}

class _SelectedTagChip extends StatelessWidget {
  const _SelectedTagChip({required this.label, required this.emphasized});

  final String label;
  final bool emphasized;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: emphasized
            ? colorScheme.secondaryContainer
            : colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
          color: emphasized
              ? colorScheme.onSecondaryContainer
              : colorScheme.onSurface,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

class _TagListTile extends StatelessWidget {
  const _TagListTile({
    required this.tag,
    required this.depth,
    required this.selected,
    required this.trailing,
    required this.onTap,
  });

  final TagInfo tag;
  final int depth;
  final bool selected;
  final Widget trailing;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final description = tag.description.trim();

    return Material(
      color: selected
          ? colorScheme.secondaryContainer.withValues(alpha: 0.7)
          : Colors.transparent,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: onTap,
        child: Padding(
          padding: EdgeInsets.fromLTRB(12 + depth * 18, 12, 8, 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: selected
                      ? colorScheme.primary.withValues(alpha: 0.14)
                      : colorScheme.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(8),
                ),
                alignment: Alignment.center,
                child: Icon(
                  _tagIcon(tag),
                  size: 18,
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: selected
                            ? FontWeight.w700
                            : FontWeight.w600,
                      ),
                    ),
                    if (description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 8),
              trailing,
            ],
          ),
        ),
      ),
    );
  }

  IconData _tagIcon(TagInfo tag) {
    if (tag.isChild) {
      return Icons.subdirectory_arrow_right_rounded;
    }
    if ((tag.position ?? 99) <= 3) {
      return Icons.push_pin_outlined;
    }
    return Icons.sell_outlined;
  }
}
