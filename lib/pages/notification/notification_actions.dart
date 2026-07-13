import 'package:get/get.dart';
import 'package:star_forum/data/model/notifications.dart';
import 'package:star_forum/data/repository/notification_repo.dart';
import 'package:star_forum/l10n/app_localizations.dart';
import 'package:star_forum/pages/notification/notification_state.dart';
import 'package:star_forum/utils/log_util.dart';
import 'package:star_forum/utils/snackbar_utils.dart';

class NotificationActions {
  NotificationActions({
    required this.repository,
    required this.items,
    required this.isInvoking,
    required this.activeToolbarAction,
    required this.activeItemAction,
    required this.activeItemId,
    required this.onCleared,
  });

  final NotificationRepository repository;
  final RxList<NotificationsInfo> items;
  final RxBool isInvoking;
  final Rx<NotificationToolbarAction> activeToolbarAction;
  final Rx<NotificationItemAction> activeItemAction;
  final RxnInt activeItemId;
  final void Function() onCleared;

  Future<bool> markRead(int id) async {
    if (isInvoking.value) return false;
    isInvoking.value = true;
    activeItemId.value = id;
    activeItemAction.value = NotificationItemAction.markRead;
    try {
      final result = await repository.markRead(id.toString());
      if (result.data == null) {
        _showMessage((l10n) => l10n.notificationMarkReadFailed);
        return false;
      }
      final index = items.indexWhere((item) => item.id == id);
      if (index >= 0) {
        items[index].isRead = true;
        items.refresh();
      }
      _showMessage((l10n) => l10n.notificationMarkReadSuccess);
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[NotificationActions] mark read failed',
        error,
        stackTrace,
      );
      _showMessage((l10n) => l10n.notificationMarkReadFailed);
      return false;
    } finally {
      activeItemId.value = null;
      activeItemAction.value = NotificationItemAction.none;
      isInvoking.value = false;
    }
  }

  Future<void> readAll() async {
    if (isInvoking.value) return;
    if (items.isNotEmpty && items.every((item) => item.isRead)) {
      _showMessage((l10n) => l10n.notificationMarkAllReadNoNeed);
      return;
    }
    isInvoking.value = true;
    activeToolbarAction.value = NotificationToolbarAction.readAll;
    try {
      final result = await repository.readAll();
      if (result.isFailure) {
        _showMessage((l10n) => l10n.notificationMarkAllReadFailed);
        return;
      }
      for (final item in items) {
        item.isRead = true;
      }
      items.refresh();
      _showMessage((l10n) => l10n.notificationMarkReadSuccess);
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[NotificationActions] read all failed',
        error,
        stackTrace,
      );
      _showMessage((l10n) => l10n.notificationMarkAllReadFailed);
    } finally {
      activeToolbarAction.value = NotificationToolbarAction.none;
      isInvoking.value = false;
    }
  }

  Future<void> clearAll() async {
    if (isInvoking.value) return;
    isInvoking.value = true;
    activeToolbarAction.value = NotificationToolbarAction.clearAll;
    try {
      final result = await repository.clearAll();
      if (result.isFailure) {
        _showMessage((l10n) => l10n.notificationClearAllFailed);
        return;
      }
      items.clear();
      onCleared();
      _showMessage((l10n) => l10n.notificationClearAllSuccess);
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[NotificationActions] clear all failed',
        error,
        stackTrace,
      );
      _showMessage((l10n) => l10n.notificationClearAllFailed);
    } finally {
      activeToolbarAction.value = NotificationToolbarAction.none;
      isInvoking.value = false;
    }
  }

  void _showMessage(String Function(AppLocalizations l10n) select) {
    final context = Get.context;
    if (context == null) return;
    SnackbarUtils.showMessage(
      msg: select(AppLocalizations.of(context)!),
      context: context,
    );
  }
}
