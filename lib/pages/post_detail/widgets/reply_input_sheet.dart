/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';
import 'package:star_forum/l10n/app_localizations.dart';

class ReplyInputSheet extends StatefulWidget {
  const ReplyInputSheet({
    super.key,
    this.hintText,
    this.onOpenEditor,
    required this.onSubmit,
  });

  final String? hintText;
  final ValueChanged<String>? onOpenEditor;
  final Future<bool> Function(String content) onSubmit;

  @override
  State<ReplyInputSheet> createState() => _ReplyInputSheetState();
}

class _ReplyInputSheetState extends State<ReplyInputSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_isSubmitting) return;
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSubmitting = true);

    final ok = await widget.onSubmit(text);

    if (mounted) {
      setState(() => _isSubmitting = false);
      if (ok) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    autofocus: true,
                    enabled: !_isSubmitting,
                    minLines: 1,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: widget.hintText ?? l10n.replyInputHint,
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton(
                  tooltip: l10n.replyOpenEditor,
                  onPressed: _isSubmitting || widget.onOpenEditor == null
                      ? null
                      : () {
                          final draft = _controller.text;
                          Navigator.of(context).pop();
                          widget.onOpenEditor!(draft);
                        },
                  icon: const Icon(Icons.open_in_full_rounded),
                ),
                IconButton(
                  icon: _isSubmitting
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.4,
                            color: colorScheme.primary,
                          ),
                        )
                      : const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
