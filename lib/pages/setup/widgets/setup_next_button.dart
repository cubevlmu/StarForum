import 'package:flutter/material.dart';
import 'package:fin_ui/fin_ui.dart';

class SetupNextButton extends StatelessWidget {
  const SetupNextButton({
    super.key,
    required this.icon,
    this.text,
    required this.onTap,
    this.loading = false,
  });

  final IconData icon;
  final String? text;
  final VoidCallback? onTap;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    return FUIButton(
      label: text ?? MaterialLocalizations.of(context).continueButtonLabel,
      icon: loading ? null : icon,
      loading: loading,
      fullWidth: true,
      onPressed: onTap,
    );
  }
}
