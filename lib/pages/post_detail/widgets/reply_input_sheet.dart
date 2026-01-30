/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved. 
 */

import 'package:flutter/material.dart';

class ReplyInputSheet extends StatefulWidget {
  const ReplyInputSheet({
    super.key,
    this.hintText,
    required this.onSubmit,
  });

  final String? hintText;
  final Future<bool> Function(String content) onSubmit;

  @override
  State<ReplyInputSheet> createState() => _ReplyInputSheetState();
}

class _ReplyInputSheetState extends State<ReplyInputSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isSubmitting = false;

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
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
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
                      hintText: widget.hintText ?? "写下你的回复…",
                      border: InputBorder.none,
                    ),
                    onSubmitted: (_) => _submit(),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _isSubmitting ? null : _submit,
                ),
              ],
            ),
          ),
          const SizedBox(height: 2),
          if (_isSubmitting)
            const LinearProgressIndicator(minHeight: 2),
        ],
      ),
    );
  }
}
