/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/assets/view.dart';
import 'package:star_forum/pages/editor/controller.dart';
import 'package:star_forum/pages/editor/widgets/tag_dialog.dart';
import 'package:star_forum/pages/post_list/create_discuss_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

@immutable
class EditorPage extends StatefulWidget {
  const EditorPage({
    super.key,
    this.embedded = false,
    this.showEmbeddedBack = false,
    this.onEmbeddedLeadingPressed,
  }) : title = null,
       initialContent = null,
       onSubmitReply = null;

  const EditorPage.reply({
    super.key,
    required this.title,
    required this.initialContent,
    required this.onSubmitReply,
    this.embedded = false,
    this.showEmbeddedBack = false,
    this.onEmbeddedLeadingPressed,
  });

  final bool embedded;
  final bool showEmbeddedBack;
  final VoidCallback? onEmbeddedLeadingPressed;
  final String? title;
  final String? initialContent;
  final Future<bool> Function(String content)? onSubmitReply;

  bool get isReplyMode => onSubmitReply != null;

  @override
  State<EditorPage> createState() => _EditorPageState();
}

class _EditorPageState extends State<EditorPage> {
  late final EditorController controller;
  late final String _controllerTag;

  @override
  void initState() {
    _controllerTag = "EditorPage:${identityHashCode(this)}";
    controller = Get.put(EditorController(), tag: _controllerTag);
    final initialContent = widget.initialContent;
    if (initialContent != null && initialContent.isNotEmpty) {
      controller.contentController.text = initialContent;
      controller.contentController.selection = TextSelection.collapsed(
        offset: initialContent.length,
      );
    }
    super.initState();
  }

  @override
  void dispose() {
    if (Get.isRegistered<EditorController>(tag: _controllerTag)) {
      Get.delete<EditorController>(tag: _controllerTag);
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: !widget.embedded,
        leading: widget.embedded
            ? IconButton(
                icon: Icon(
                  widget.showEmbeddedBack
                      ? Icons.arrow_back_rounded
                      : Icons.close_rounded,
                ),
                onPressed: widget.onEmbeddedLeadingPressed,
              )
            : null,
        title: Text(widget.title ?? l10n.editorPageTitle),
      ),
      body: SafeArea(
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
              child: Obx(() {
                final isSubmitting = controller.isSubmitting.value;
                return Column(
                  children: [
                    if (!widget.isReplyMode) ...[
                      _EditorTagField(
                        label: controller.buildTagLabel(l10n.tagDialogTitle),
                        enabled: !isSubmitting,
                        onTap: () => _showTagDialog(context),
                      ),
                      const SizedBox(height: 12),
                      _EditorTitleField(
                        controller: controller,
                        enabled: !isSubmitting,
                      ),
                      const SizedBox(height: 12),
                    ],
                    Expanded(
                      child: _EditorBodyField(
                        controller: controller,
                        enabled: !isSubmitting,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Divider(color: colorScheme.outlineVariant, height: 1),
                    const SizedBox(height: 8),
                    _EditorFooter(
                      controller: controller,
                      isSubmitting: isSubmitting,
                      onSubmit: () => _submit(context),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTagDialog(BuildContext context) async {
    if (controller.isSubmitting.value) {
      return;
    }

    final repo = controller.tagRepo;
    if (!repo.isReady) {
      await repo.syncTags();
    }
    if (!mounted) {
      return;
    }

    final l10n = AppLocalizations.of(this.context)!;
    final primaryTags = repo
        .getPrimaryTags()
        .where((tag) => tag.canStartDiscussion)
        .toList();
    final primaryTagIds = primaryTags.map((tag) => tag.id).toSet();
    final secondaryTags = repo
        .getTags()
        .where(
          (tag) => tag.canStartDiscussion && !primaryTagIds.contains(tag.id),
        )
        .toList();

    if (primaryTags.isEmpty) {
      SnackbarUtils.showMessage(msg: l10n.themeSelectTagHint);
      return;
    }

    final selected = await EditorTagDialog.show(
      this.context,
      rootTags: primaryTags,
      normalTags: secondaryTags,
      initialPrimaryTag: controller.primaryTag.value,
      initialSecondaryTags: controller.secondaryTags,
    );
    if (selected == null) {
      return;
    }
    controller.applyTagSelection(
      primary: selected.primaryTag,
      secondary: selected.secondaryTags,
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (controller.isSubmitting.value) {
      return;
    }

    final l10n = AppLocalizations.of(context)!;
    final title = controller.titleController.text.trim();
    final content = controller.contentController.text.trim();

    if (content.isEmpty || (!widget.isReplyMode && title.isEmpty)) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticeTitleContentEmpty);
      return;
    }

    if (!widget.isReplyMode && title.length < 6) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticeTitleTooShort);
      return;
    }

    if (widget.isReplyMode) {
      controller.isSubmitting.value = true;
      try {
        final ok = await widget.onSubmitReply!(content);
        if (!mounted || !ok) {
          return;
        }
        if (widget.embedded) {
          widget.onEmbeddedLeadingPressed?.call();
          return;
        }
        Navigator.of(this.context).pop();
      } finally {
        controller.isSubmitting.value = false;
      }
      return;
    }

    final primaryTag = controller.primaryTag.value;
    if (primaryTag == null) {
      SnackbarUtils.showMessage(msg: l10n.commonNoticePrimaryTagRequired);
      return;
    }

    final tags = <int>[
      primaryTag.id,
      ...controller.secondaryTags.map((tag) => tag.id),
    ];

    controller.isSubmitting.value = true;
    try {
      final ok = await CreateDiscussUtil.submitDiscussion(
        tags: tags,
        title: title,
        content: content,
      );
      if (!mounted || !ok) {
        return;
      }

      if (widget.embedded) {
        widget.onEmbeddedLeadingPressed?.call();
        return;
      }
      Navigator.of(this.context).pop();
    } finally {
      controller.isSubmitting.value = false;
    }
  }
}

class _EditorTagField extends StatelessWidget {
  const _EditorTagField({
    required this.label,
    required this.enabled,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final selected = label != AppLocalizations.of(context)!.tagDialogTitle;

    return Material(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: enabled ? onTap : null,
        child: Ink(
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Row(
            children: [
              Icon(
                Icons.sell_outlined,
                size: 18,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: selected
                        ? colorScheme.onSurface
                        : colorScheme.onSurfaceVariant,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EditorTitleField extends StatelessWidget {
  const _EditorTitleField({required this.controller, required this.enabled});

  final EditorController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: controller.titleController,
        enabled: enabled,
        textInputAction: TextInputAction.next,
        style: Theme.of(
          context,
        ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
        decoration: InputDecoration(
          hintText: l10n.postCreateTitleHint,
          contentPadding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _EditorBodyField extends StatelessWidget {
  const _EditorBodyField({required this.controller, required this.enabled});

  final EditorController controller;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: TextField(
        controller: controller.contentController,
        focusNode: controller.contentFocusNode,
        enabled: enabled,
        expands: true,
        maxLines: null,
        minLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: l10n.postCreateContentHint,
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          border: InputBorder.none,
        ),
      ),
    );
  }
}

class _EditorFooter extends StatelessWidget {
  const _EditorFooter({
    required this.controller,
    required this.isSubmitting,
    required this.onSubmit,
  });

  final EditorController controller;
  final bool isSubmitting;
  final Future<void> Function() onSubmit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final userRepo = getIt<UserRepo>();

    final canUpload = userRepo.canUpload.value;
    final actions = <_EditorToolbarAction>[
      _EditorToolbarAction(
        icon: Icons.title_rounded,
        tooltip: l10n.editorToolbarHeading,
        onTap: () => controller.insertLinePrefix("# "),
      ),
      _EditorToolbarAction(
        icon: Icons.format_bold_rounded,
        tooltip: l10n.editorToolbarBold,
        onTap: () => controller.insertWrap("**"),
      ),
      _EditorToolbarAction(
        icon: Icons.format_italic_rounded,
        tooltip: l10n.editorToolbarItalic,
        onTap: () => controller.insertWrap("_"),
      ),
      _EditorToolbarAction(
        icon: Icons.format_strikethrough_rounded,
        tooltip: l10n.editorToolbarStrike,
        onTap: () => controller.insertWrap("~~"),
      ),
      _EditorToolbarAction(
        icon: Icons.format_quote_rounded,
        tooltip: l10n.editorToolbarQuote,
        onTap: () => controller.insertLinePrefix("> "),
      ),
      _EditorToolbarAction(
        icon: Icons.code_rounded,
        tooltip: l10n.editorToolbarCode,
        onTap: () => controller.insertWrap("`"),
      ),
      _EditorToolbarAction(
        icon: Icons.link_rounded,
        tooltip: l10n.editorToolbarLink,
        onTap: () =>
            controller.insertSnippet("[文字](https://)", cursorOffset: 1),
      ),
      _EditorToolbarAction(
        icon: Icons.image_outlined,
        tooltip: l10n.editorToolbarImage,
        onTap: () => controller.insertSnippet("![](https://)", cursorOffset: 4),
      ),
      _EditorToolbarAction(
        icon: Icons.format_list_bulleted_rounded,
        tooltip: l10n.editorToolbarBulletList,
        onTap: () => controller.insertLinePrefix("- "),
      ),
      _EditorToolbarAction(
        icon: Icons.format_list_numbered_rounded,
        tooltip: l10n.editorToolbarNumberList,
        onTap: () => controller.insertLinePrefix("1. "),
      ),
      _EditorToolbarAction(
        icon: Icons.alternate_email_rounded,
        tooltip: l10n.editorToolbarMention,
        onTap: () => controller.insertSnippet("@"),
      ),
      _EditorToolbarAction(
        icon: Icons.sentiment_satisfied_alt_rounded,
        tooltip: l10n.editorToolbarEmoji,
        onTap: () => controller.insertSnippet(":)"),
      ),
      if (canUpload)
        _EditorToolbarAction(
          icon: Icons.folder_outlined,
          tooltip: l10n.editorToolbarMyFiles,
          onTap: () => isSubmitting ? null : _openAssetsDialog(context),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: actions.map((action) {
                return Padding(
                  padding: const EdgeInsets.only(right: 4),
                  child: IconButton(
                    onPressed: isSubmitting ? null : action.onTap,
                    tooltip: action.tooltip,
                    icon: Icon(action.icon),
                    visualDensity: VisualDensity.compact,
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        const SizedBox(width: 12),
        FilledButton.icon(
          onPressed: onSubmit,
          icon: isSubmitting
              ? SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                    strokeWidth: 2.2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                )
              : const Icon(Icons.send_rounded),
          label: Text(l10n.postCreateSubmit),
        ),
      ],
    );
  }

  Future<void> _openAssetsDialog(BuildContext context) async {
    final file = await showDialog<UploadFileInfo>(
      context: context,
      builder: (context) {
        return Dialog(
          clipBehavior: Clip.antiAlias,
          insetPadding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760, maxHeight: 560),
            child: AssetsPage(
              embedded: true,
              selectionEnabled: true,
              onSelected: (file) => Navigator.of(context).pop(file),
            ),
          ),
        );
      },
    );
    final bbcode = file?.bbcode.trim();
    if (bbcode == null || bbcode.isEmpty) {
      return;
    }
    controller.insertTextAtCursor('$bbcode\n');
  }
}

class _EditorToolbarAction {
  const _EditorToolbarAction({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
}
