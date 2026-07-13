/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:get/get.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/model/uploads.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/assets/view.dart';
import 'package:star_forum/pages/editor/controller.dart';
import 'package:star_forum/pages/editor/widgets/tag_dialog.dart';
import 'package:star_forum/pages/post_list/create_discuss_util.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

@immutable
class EditorPage extends StatefulWidget {
  const EditorPage({super.key, this.embedded = false})
    : title = null,
      initialContent = null,
      onSubmitReply = null;

  const EditorPage.reply({
    super.key,
    required this.title,
    required this.initialContent,
    required this.onSubmitReply,
    this.embedded = false,
  });

  final bool embedded;
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
    _controllerTag = 'EditorPage:${identityHashCode(this)}';
    controller = Get.put(EditorController(), tag: _controllerTag);
    controller.contentFocusNode.addListener(_handleContentFocusChanged);
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
    controller.contentFocusNode.removeListener(_handleContentFocusChanged);
    if (Get.isRegistered<EditorController>(tag: _controllerTag)) {
      Get.delete<EditorController>(tag: _controllerTag);
    }
    super.dispose();
  }

  void _handleContentFocusChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colors = context.colors;
    final mediaQuery = MediaQuery.of(context);
    final hideEditorMeta =
        mediaQuery.size.width < 700 &&
        mediaQuery.viewInsets.bottom > 0 &&
        controller.contentFocusNode.hasFocus;

    return Scaffold(
      backgroundColor: colors.background,
      resizeToAvoidBottomInset: true,
      bottomNavigationBar: Obx(() {
        final isSubmitting = controller.isSubmitting.value;
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(height: 1, color: colors.border),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  FUITokens.gap8,
                  FUITokens.gap6,
                  FUITokens.gap12,
                  FUITokens.gap6,
                ),
                child: _EditorFooter(
                  controller: controller,
                  isSubmitting: isSubmitting,
                  onSubmit: () => _submit(context),
                ),
              ),
            ],
          ),
        );
      }),
      body: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    FUITokens.pagePadding,
                    FUITokens.gap12,
                    FUITokens.pagePadding,
                    FUITokens.gap8,
                  ),
                  child: FuiPageHead(
                    title: widget.title ?? l10n.editorPageTitle,
                  ),
                ),

                Expanded(
                  child: Obx(() {
                    final isSubmitting = controller.isSubmitting.value;
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(
                        FUITokens.pagePadding,
                        0,
                        FUITokens.pagePadding,
                        FUITokens.gap8,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 160),
                            switchInCurve: Curves.easeOutCubic,
                            switchOutCurve: Curves.easeOutCubic,
                            child: !widget.isReplyMode && !hideEditorMeta
                                ? Column(
                                    key: const ValueKey('editor-meta'),
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      _EditorTagField(
                                        label: controller.buildTagLabel(
                                          l10n.tagDialogTitle,
                                        ),
                                        enabled:
                                            !isSubmitting &&
                                            !controller.isSelectingTags.value,
                                        onTap: () => _showTagDialog(context),
                                      ),
                                      const SizedBox(height: FUITokens.gap10),
                                      _EditorTitleField(
                                        controller: controller,
                                        enabled: !isSubmitting,
                                      ),
                                      const SizedBox(height: FUITokens.gap10),
                                    ],
                                  )
                                : const SizedBox.shrink(
                                    key: ValueKey('editor-meta-hidden'),
                                  ),
                          ),
                          Expanded(
                            child: _EditorBodyField(
                              controller: controller,
                              enabled: !isSubmitting,
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showTagDialog(BuildContext context) async {
    if (controller.isSubmitting.value || controller.isSelectingTags.value) {
      return;
    }

    FocusManager.instance.primaryFocus?.unfocus();

    final repo = controller.tagRepo;
    controller.isSelectingTags.value = true;
    try {
      await repo.syncTags();
    } finally {
      controller.isSelectingTags.value = false;
    }
    if (!mounted) return;

    final l10n = AppLocalizations.of(this.context)!;
    final primaryTags = repo.getRootTagsForUI();
    final primaryTagIds = primaryTags.map((tag) => tag.id).toSet();
    final secondaryTags = repo
        .getTags()
        .where(
          (tag) => tag.canStartDiscussion && !primaryTagIds.contains(tag.id),
        )
        .toList();
    bool hasSelectableTag(Iterable<TagInfo> tags) {
      for (final tag in tags) {
        if (tag.canStartDiscussion) return true;
        final children = tag.children?.values;
        if (children != null && hasSelectableTag(children)) return true;
      }
      return false;
    }

    final canStartDiscussion =
        hasSelectableTag(primaryTags) || secondaryTags.isNotEmpty;
    if (!canStartDiscussion) {
      SnackbarUtils.showMessage(
        msg: l10n.themeSelectTagHint,
        context: this.context,
      );
      return;
    }

    final selected = await EditorTagDialog.show(
      this.context,
      rootTags: primaryTags,
      normalTags: secondaryTags,
      initialPrimaryTag: controller.primaryTag.value,
      initialSecondaryTags: controller.secondaryTags,
    );
    if (selected == null) return;
    controller.applyTagSelection(
      primary: selected.primaryTag,
      secondary: selected.secondaryTags,
    );
  }

  Future<void> _submit(BuildContext context) async {
    if (controller.isSubmitting.value) return;

    final l10n = AppLocalizations.of(context)!;
    final title = controller.titleController.text.trim();
    final content = controller.contentController.text.trim();

    if (content.isEmpty || (!widget.isReplyMode && title.isEmpty)) {
      SnackbarUtils.showMessage(
        msg: l10n.commonNoticeTitleContentEmpty,
        context: this.context,
      );
      return;
    }
    if (!widget.isReplyMode && title.length < 6) {
      SnackbarUtils.showMessage(
        msg: l10n.commonNoticeTitleTooShort,
        context: this.context,
      );
      return;
    }

    if (widget.isReplyMode) {
      controller.isSubmitting.value = true;
      try {
        final ok = await widget.onSubmitReply!(content);
        if (!mounted || !ok) return;
        if (widget.embedded) {
          FuiNavigation.closeCurrent(this.context);
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
      SnackbarUtils.showMessage(
        msg: l10n.commonNoticePrimaryTagRequired,
        context: this.context,
      );
      return;
    }

    final tags = <int>[
      primaryTag.id,
      ...controller.secondaryTags.map((tag) => tag.id),
    ];

    controller.isSubmitting.value = true;
    try {
      final ok = await CreateDiscussUtil.submitDiscussion(
        context: this.context,
        tags: tags,
        title: title,
        content: content,
      );
      if (!mounted || !ok) return;
      if (widget.embedded) {
        FuiNavigation.closeCurrent(this.context);
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
    final colors = context.colors;
    final hasTag = label != AppLocalizations.of(context)!.tagDialogTitle;

    return FUISurface(
      onTap: enabled ? onTap : null,
      padding: const EdgeInsets.fromLTRB(
        FUITokens.gap14,
        FUITokens.gap12,
        FUITokens.gap12,
        FUITokens.gap12,
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: hasTag ? colors.primarySoft : colors.surfaceAlt,
              borderRadius: BorderRadius.circular(FUITokens.radiusSm),
            ),
            child: Icon(
              ForumIcons.tags,
              size: FUITokens.iconSm,
              color: hasTag ? colors.primary : colors.textTertiary,
            ),
          ),
          const SizedBox(width: FUITokens.gap12),
          Expanded(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: hasTag ? colors.textPrimary : colors.textTertiary,
                fontSize: 14,
                fontWeight: hasTag ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ),
          Icon(
            FUIIcons.chevronDown,
            size: FUITokens.iconMd,
            color: colors.textTertiary,
          ),
        ],
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return FUISurface(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller.titleController,
        focusNode: controller.titleFocusNode,
        enabled: enabled,
        textInputAction: TextInputAction.next,
        onSubmitted: (_) => controller.contentFocusNode.requestFocus(),
        style: TextStyle(
          color: colors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        decoration: InputDecoration(
          hintText: l10n.postCreateTitleHint,
          hintStyle: TextStyle(
            color: colors.textTertiary,
            fontSize: 18,
            fontWeight: FontWeight.w400,
          ),
          contentPadding: const EdgeInsets.fromLTRB(
            FUITokens.gap14,
            FUITokens.gap14,
            FUITokens.gap14,
            FUITokens.gap14,
          ),
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
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return FUISurface(
      padding: EdgeInsets.zero,
      child: TextField(
        controller: controller.contentController,
        focusNode: controller.contentFocusNode,
        enabled: enabled,
        expands: true,
        maxLines: null,
        minLines: null,
        keyboardType: TextInputType.multiline,
        textCapitalization: TextCapitalization.sentences,
        textAlignVertical: TextAlignVertical.top,
        style: TextStyle(color: colors.textPrimary, fontSize: 14, height: 1.6),
        decoration: InputDecoration(
          hintText: l10n.postCreateContentHint,
          hintStyle: TextStyle(color: colors.textTertiary, fontSize: 14),
          alignLabelWithHint: true,
          contentPadding: const EdgeInsets.all(FUITokens.gap14),
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
    final sessionState = getIt<SessionState>();
    return ValueListenableBuilder<SessionSnapshot>(
      valueListenable: sessionState.state,
      builder: (context, session, _) =>
          _buildFooter(context, l10n, canUpload: session.canUpload),
    );
  }

  Widget _buildFooter(
    BuildContext context,
    AppLocalizations l10n, {
    required bool canUpload,
  }) {
    final actions = <_ToolbarAction>[
      _ToolbarAction(
        FluentIcons.text_header_1_24_regular,
        l10n.editorToolbarHeading,
        () => controller.insertLinePrefix('# '),
      ),
      _ToolbarAction(
        FluentIcons.text_bold_24_regular,
        l10n.editorToolbarBold,
        () => controller.insertWrap('**'),
      ),
      _ToolbarAction(
        FluentIcons.text_italic_24_regular,
        l10n.editorToolbarItalic,
        () => controller.insertWrap('_'),
      ),
      _ToolbarAction(
        FluentIcons.text_strikethrough_24_regular,
        l10n.editorToolbarStrike,
        () => controller.insertWrap('~~'),
      ),
      _ToolbarAction(
        FluentIcons.text_quote_24_regular,
        l10n.editorToolbarQuote,
        () => controller.insertLinePrefix('> '),
      ),
      _ToolbarAction(
        FluentIcons.code_24_regular,
        l10n.editorToolbarCode,
        () => controller.insertWrap('`'),
      ),
      _ToolbarAction(
        FluentIcons.link_24_regular,
        l10n.editorToolbarLink,
        () => controller.insertSnippet(
          '[${l10n.editorLinkTextPlaceholder}](https://)',
          cursorOffset: 1,
        ),
      ),
      _ToolbarAction(
        ForumIcons.image,
        l10n.editorToolbarImage,
        () => controller.insertSnippet('![](https://)', cursorOffset: 4),
      ),
      _ToolbarAction(
        FluentIcons.text_bullet_list_ltr_24_regular,
        l10n.editorToolbarBulletList,
        () => controller.insertLinePrefix('- '),
      ),
      _ToolbarAction(
        FluentIcons.text_number_list_ltr_24_regular,
        l10n.editorToolbarNumberList,
        () => controller.insertLinePrefix('1. '),
      ),
      _ToolbarAction(
        ForumIcons.mention,
        l10n.editorToolbarMention,
        () => controller.insertSnippet('@'),
      ),
      _ToolbarAction(
        FluentIcons.emoji_24_regular,
        l10n.editorToolbarEmoji,
        () => controller.insertSnippet(':)'),
      ),
      if (canUpload)
        _ToolbarAction(
          ForumIcons.folder,
          l10n.editorToolbarMyFiles,
          () => isSubmitting ? null : _openAssetsDialog(context),
        ),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: actions
                  .map(
                    (a) => Padding(
                      padding: const EdgeInsets.only(right: FUITokens.gap2),
                      child: FUIIconButton(
                        icon: a.icon,
                        tooltip: a.tooltip,
                        variant: FUIIconButtonVariant.ghost,
                        onPressed: isSubmitting ? null : a.onTap,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ),
        const SizedBox(width: FUITokens.gap10),
        FUIButton(
          label: l10n.postCreateSubmit,
          icon: ForumIcons.send,
          loading: isSubmitting,
          onPressed: isSubmitting ? null : () => onSubmit(),
        ),
      ],
    );
  }

  Future<void> _openAssetsDialog(BuildContext context) async {
    final file = await showDialog<UploadFileInfo>(
      context: context,
      builder: (context) => Dialog(
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
      ),
    );
    final bbcode = file?.bbcode.trim();
    if (bbcode == null || bbcode.isEmpty) return;
    controller.insertTextAtCursor('$bbcode\n');
  }
}

class _ToolbarAction {
  const _ToolbarAction(this.icon, this.tooltip, this.onTap);
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
}
