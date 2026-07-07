import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';

class SetupBodyView extends StatelessWidget {
  const SetupBodyView({
    super.key,
    required this.title,
    required this.secondaryTitle,
    this.body,
    this.action,
    this.leading,
    this.header,
  });

  final String title;
  final String secondaryTitle;
  final Widget? body;
  final Widget? action;
  final Widget? leading;
  final Widget? header;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: context.colors.background,
      child: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            const padding = EdgeInsets.fromLTRB(
              FUITokens.pagePadding,
              FUITokens.gap12,
              FUITokens.pagePadding,
              FUITokens.gap24,
            );
            return SingleChildScrollView(
              padding: padding,
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: constraints.maxHeight - padding.vertical,
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (header != null)
                        header!
                      else ...[
                        if (leading != null) ...[
                          Align(
                            alignment: Alignment.centerLeft,
                            child: leading!,
                          ),
                          const SizedBox(height: FUITokens.gap16),
                        ],
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(
                                color: context.colors.textPrimary,
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: FUITokens.gap6),
                        Text(
                          secondaryTitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: context.colors.textSecondary,
                                height: 1.4,
                              ),
                        ),
                      ],
                      const SizedBox(height: FUITokens.gap24),
                      body ?? const SizedBox.shrink(),
                      const Spacer(),
                      if (action != null) ...[
                        const SizedBox(height: FUITokens.gap24),
                        action!,
                      ],
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
