/*
 * @Author: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';
import 'package:star_forum/app/forum_icons.dart';
import 'package:star_forum/l10n/app_localizations.dart';

class ForumReplyComposer extends StatelessWidget {
  const ForumReplyComposer({
    super.key,
    this.controller,
    this.hintText,
    this.onSend,
    this.onExpand,
    this.enabled = true,
  });

  final TextEditingController? controller;
  final String? hintText;
  final VoidCallback? onSend;
  final VoidCallback? onExpand;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final l10n = AppLocalizations.of(context)!;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: colors.surface,
        border: Border(top: BorderSide(color: colors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 10),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: FUITokens.inputHeight,
                  child: TextField(
                    controller: controller,
                    enabled: enabled,
                    minLines: 1,
                    maxLines: 1,
                    decoration: InputDecoration(
                      hintText: hintText ?? l10n.replyInputHint,
                      hintStyle: TextStyle(
                        color: colors.textTertiary,
                        fontSize: 13,
                      ),
                      filled: true,
                      fillColor: colors.surfaceAlt,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 12,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                        borderSide: BorderSide(color: colors.border),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(FUITokens.radiusMd),
                        borderSide: BorderSide(
                          color: colors.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: FUITokens.gap8),
              FUIIconButton(
                icon: ForumIcons.compose,
                tooltip: l10n.replyOpenEditor,
                onPressed: onExpand,
                variant: FUIIconButtonVariant.outline,
              ),
              const SizedBox(width: FUITokens.gap8),
              FUIButton(
                label: l10n.postCreateSubmit,
                icon: ForumIcons.send,
                onPressed: onSend,
                small: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
