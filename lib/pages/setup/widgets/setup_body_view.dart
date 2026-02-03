/*
 * @Author: cubevlmu khfahqp@gmail.com
 * @LastEditors: cubevlmu khfahqp@gmail.com
 * Copyright (c) 2026 by FlybirdGames, All Rights Reserved.
 */

import 'package:flutter/material.dart';

@immutable
class SetupBodyView extends StatelessWidget {
  final String title;
  final String secondaryTitle;
  final Widget? body;
  final Widget? action;
  final Widget? leading;

  const SetupBodyView({
    super.key,
    required this.title,
    required this.secondaryTitle,
    this.body,
    this.action,
    this.leading,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisSize: .min,
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                children: [
                  const SizedBox(height: 15),
                  if (leading != null) ...[
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 0,
                      ),
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: leading!,
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                  Text(
                    title,
                    style: textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    secondaryTitle,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontSize: 18,
                    ),
                  ),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.80,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const SizedBox(height: 30),
                        body ?? const SizedBox.shrink(),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (action != null)
              Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                  left: 24,
                  right: 24,
                ),
                child: action!,
              ),
          ],
        ),
      ),
    );
  }
}
