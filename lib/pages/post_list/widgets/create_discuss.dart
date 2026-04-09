/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/data/model/tags.dart';
import 'package:star_forum/data/repository/tag_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

class CreateDiscussWidget extends StatefulWidget {
  const CreateDiscussWidget({super.key, required this.onSubmit});

  final Future<bool> Function(List<int> tagIds, String title, String content)
  onSubmit;

  @override
  State<CreateDiscussWidget> createState() => _CreateDiscussWidgetState();
}

class _CreateDiscussWidgetState extends State<CreateDiscussWidget> {
  final _titleCtrl = TextEditingController();
  final _contentCtrl = TextEditingController();

  final repo = getIt<TagRepo>();

  TagInfo? _primaryTag;
  final List<TagInfo> _selectedTags = [];
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleCtrl.dispose();
    _contentCtrl.dispose();
    super.dispose();
  }

  String get _tagText => _primaryTag == null
      ? AppLocalizations.of(context)!.commonNoticePrimaryTagRequired
      : "${_primaryTag!.name}${_selectedTags.isEmpty ? "" : "/"}${_selectedTags.map((e) => e.name).join(", ")}";

  Future<void> _submit() async {
    if (_isSubmitting) return;

    final title = _titleCtrl.text.trim();
    final content = _contentCtrl.text.trim();

    if (title.isEmpty || content.isEmpty) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(context)!.commonNoticeTitleContentEmpty,
      );
      return;
    }

    if (title.length < 6) {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(context)!.commonNoticeTitleTooShort,
      );
      return;
    }

    final lst = _selectedTags.map((e) => e.id).toList();
    if (_primaryTag != null) {
      lst.add(_primaryTag!.id);
    } else {
      SnackbarUtils.showMessage(
        msg: AppLocalizations.of(context)!.commonNoticePrimaryTagRequired,
      );
      return;
    }

    setState(() => _isSubmitting = true);
    final ok = await widget.onSubmit(lst, title, content);

    if (!mounted) return;

    setState(() => _isSubmitting = false);
    if (ok) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _selectTags,
              child: Text(_tagText, style: const TextStyle(color: Colors.blue)),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _titleCtrl,
              enabled: !_isSubmitting,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.postCreateTitleHint,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 8),

            TextField(
              controller: _contentCtrl,
              enabled: !_isSubmitting,
              minLines: 3,
              maxLines: 6,
              decoration: InputDecoration(
                hintText: AppLocalizations.of(context)!.postCreateContentHint,
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: _isSubmitting ? null : _submit,
              icon: const Icon(Icons.send),
              label: Text(AppLocalizations.of(context)!.postCreateSubmit),
            ),

            if (_isSubmitting)
              const Padding(
                padding: EdgeInsets.only(top: 8),
                child: LinearProgressIndicator(minHeight: 2),
              ),
          ],
        ),
      ),
    );
  }

  void _selectTags() async {
    if (!repo.isReady) {
      await repo.syncTags();
    }

    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(AppLocalizations.of(context)!.tagDialogTitle),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    RadioGroup<TagInfo>(
                      groupValue: _primaryTag,
                      onChanged: (v) {
                        _primaryTag = v;
                        setDialogState(() {});
                      },
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: repo.getPrimaryTags().map((tag) {
                          if (!tag.canStartDiscussion) {
                            return const SizedBox.shrink();
                          }
                          return _buildPrimaryNode(tag);
                        }).toList(),
                      ),
                    ),
                    const Divider(),
                    ...repo.getTags().map((tag) {
                      if (!tag.canStartDiscussion) {
                        return const SizedBox.shrink();
                      }
                      return _buildTagNode(
                        tag,
                        cc: () => setDialogState(() {}),
                      );
                    }),
                    const Divider(),
                    ListTile(
                      leading: const Icon(Icons.add),
                      title: Text(
                        AppLocalizations.of(context)!.tagDialogCustomTag,
                      ),
                      onTap: _onCustomTag,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    if (_primaryTag == null) {
                      SnackbarUtils.showMessage(
                        msg: AppLocalizations.of(
                          context,
                        )!.commonNoticePrimaryTagRequired,
                      );
                      return;
                    }
                    setState(() {});
                    Navigator.pop(context);
                  },
                  child: Text(AppLocalizations.of(context)!.tagDialogClose),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _buildTagNode(TagInfo tag, {int depth = 0, required VoidCallback cc}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: CheckboxListTile(
        dense: true,
        contentPadding: EdgeInsets.zero,
        value: _selectedTags.contains(tag),
        title: Padding(
          padding: EdgeInsetsGeometry.only(left: 10),
          child: Text(tag.name),
        ),
        onChanged: (v) {
          if (v == true) {
            if (!_selectedTags.contains(tag)) {
              if (_selectedTags.length == 3) _selectedTags.removeAt(0);
              _selectedTags.add(tag);
            }
          } else {
            _selectedTags.remove(tag);
          }
          cc();
        },
      ),
    );
  }

  Widget _buildPrimaryNode(TagInfo tag, {int depth = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: depth * 16.0),
      child: RadioListTile<TagInfo>(
        dense: true,
        contentPadding: EdgeInsets.zero,
        value: tag,
        title: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Text(tag.name),
        ),
      ),
    );
  }

  void _onCustomTag() {
    SnackbarUtils.showMessage(
      msg: AppLocalizations.of(context)!.commonNoticeCustomTagTodo,
    );
  }
}
