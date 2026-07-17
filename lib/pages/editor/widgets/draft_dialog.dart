import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/data/repository/editor_draft_repository.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/snackbar_utils.dart';
import 'package:star_forum/utils/string_util.dart';

class EditorDraftDialog extends StatefulWidget {
  const EditorDraftDialog({
    super.key,
    required this.drafts,
    required this.onDelete,
  });

  final List<EditorDraftRecord> drafts;
  final Future<void> Function(int id) onDelete;

  static Future<EditorDraftRecord?> show(
    BuildContext context, {
    required List<EditorDraftRecord> drafts,
    required Future<void> Function(int id) onDelete,
  }) {
    return showDialog<EditorDraftRecord>(
      context: context,
      builder: (_) => EditorDraftDialog(drafts: drafts, onDelete: onDelete),
    );
  }

  @override
  State<EditorDraftDialog> createState() => _EditorDraftDialogState();
}

class _EditorDraftDialogState extends State<EditorDraftDialog> {
  late final List<EditorDraftRecord> _drafts;
  int? _deletingId;

  @override
  void initState() {
    super.initState();
    _drafts = widget.drafts.toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return FUIDialog(
      title: l10n.editorDraftListTitle,
      subtitle: l10n.editorDraftListSubtitle,
      icon: ForumIcons.folder,
      content: SizedBox(
        width: 520,
        height: 360,
        child: _drafts.isEmpty
            ? Center(
                child: Text(
                  l10n.editorNoDrafts,
                  style: TextStyle(color: context.colors.textSecondary),
                ),
              )
            : ListView.separated(
                itemCount: _drafts.length,
                separatorBuilder: (_, _) =>
                    Divider(height: 1, color: context.colors.border),
                itemBuilder: (context, index) {
                  final draft = _drafts[index];
                  return FUITile(
                    icon: ForumIcons.compose,
                    title: _title(draft, l10n),
                    subtitle: l10n.editorDraftSavedAt(
                      StringUtil.dateTimeToAgoDate(draft.updatedAt),
                    ),
                    showChevron: false,
                    onTap: () => Navigator.of(context).pop(draft),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        FUIIconButton(
                          icon: FUIIcons.delete,
                          tooltip: l10n.editorDeleteDraft,
                          variant: FUIIconButtonVariant.danger,
                          size: 32,
                          loading: _deletingId == draft.id,
                          onPressed: _deletingId == null
                              ? () => _delete(draft)
                              : null,
                        ),
                        const SizedBox(width: FUITokens.gap6),
                        Icon(
                          FUIIcons.chevronRight,
                          size: FUITokens.iconMd,
                          color: context.colors.textTertiary,
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
      actions: [
        FUIButton(
          label: l10n.commonActionCancel,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ],
    );
  }

  String _title(EditorDraftRecord draft, AppLocalizations l10n) {
    final title = draft.title.trim();
    if (title.isNotEmpty) return title;
    final content = draft.content.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (content.isEmpty) return l10n.editorUntitledDraft;
    return content.length > 60 ? '${content.substring(0, 60)}...' : content;
  }

  Future<void> _delete(EditorDraftRecord draft) async {
    setState(() => _deletingId = draft.id);
    try {
      await widget.onDelete(draft.id);
      if (!mounted) return;
      setState(() => _drafts.removeWhere((item) => item.id == draft.id));
    } catch (_) {
      if (!mounted) return;
      SnackbarUtils.showError(
        msg: AppLocalizations.of(context)!.editorDraftDeleteFailed,
        context: context,
      );
    } finally {
      if (mounted) setState(() => _deletingId = null);
    }
  }
}
