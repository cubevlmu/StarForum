import 'package:fin_ui/fin_ui.dart';
import 'package:flutter/material.dart';
import 'package:star_forum/data/repository/user_repo.dart';
import 'package:star_forum/di/injector.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/utils/shared_dialog.dart' as shared;
import 'package:star_forum/utils/snackbar_utils.dart';

class SharedDialog {
  const SharedDialog._();

  static void showDialog2(
    BuildContext context,
    String title,
    String content,
    String aText,
    Function() aAction,
    String bText,
    Function() bAction,
  ) {
    shared.SharedDialog.showConfirmDialog(
      context,
      title: title,
      content: content,
      cancelText: aText,
      confirmText: bText,
      cancelAction: aAction,
      confirmAction: bAction,
    );
  }

  static void showLogoutDialog(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    shared.SharedDialog.showConfirmDialog(
      context,
      title: l10n.authLogoutDialogTitle,
      content: l10n.authLogoutDialogContent,
      cancelText: l10n.commonActionCancel,
      confirmText: l10n.commonActionConfirm,
      variant: shared.SharedDialogVariant.warning,
      confirmAction: () async {
        final repo = getIt<UserRepo>();
        await repo.logout();
        SnackbarUtils.showMessage(msg: l10n.authLogoutSuccess);
      },
    );
  }

  static void showNumberDialog(
    BuildContext context,
    String title,
    String content,
    String aText,
    VoidCallback aAction,
    String bText,
    Function(int) bAction,
  ) {
    final controller = TextEditingController();
    shared.SharedDialog.showContentDialog(
      context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          const SizedBox(height: FUITokens.gap12),
          FUITextField(
            controller: controller,
            hintText: AppLocalizations.of(context)!.dialogInputNumberHint,
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      cancelText: aText,
      confirmText: bText,
      cancelAction: aAction,
      confirmAction: () {
        final value = int.tryParse(controller.text);
        if (value != null) bAction(value);
      },
    ).whenComplete(controller.dispose);
  }

  static void showInputDialog(
    BuildContext context,
    String title,
    String content,
    String aText,
    VoidCallback aAction,
    String bText,
    Function(String) bAction,
  ) {
    final controller = TextEditingController();
    shared.SharedDialog.showContentDialog(
      context,
      title: title,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(content),
          const SizedBox(height: FUITokens.gap12),
          FUITextField(
            controller: controller,
            hintText: AppLocalizations.of(context)!.dialogInputTextHint,
          ),
        ],
      ),
      cancelText: aText,
      confirmText: bText,
      cancelAction: aAction,
      confirmAction: () => bAction(controller.text),
    ).whenComplete(controller.dispose);
  }

  static Future<T?> showRadioListDialog<T>(
    BuildContext context, {
    required String title,
    required Map<String, T> itemNameValueMap,
    required T groupValue,
    Function(T? value)? onChanged,
  }) async {
    T? selected = groupValue;
    final confirmed = await shared.SharedDialog.showContentDialog(
      context,
      title: title,
      content: StatefulBuilder(
        builder: (context, setState) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final entry in itemNameValueMap.entries)
                FUITile(
                  title: entry.key,
                  icon: entry.value == selected
                      ? FUIIcons.check
                      : FUIIcons.chevronRight,
                  showChevron: false,
                  onTap: () {
                    setState(() => selected = entry.value);
                    onChanged?.call(entry.value);
                  },
                ),
            ],
          );
        },
      ),
    );
    return confirmed ? selected : null;
  }
}
