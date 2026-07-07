import 'package:get/get.dart';

enum SyncPhase { idle, checking, hydrating, writing }

class SyncStatusService extends GetxService {
  final phase = SyncPhase.idle.obs;
  final message = ''.obs;

  bool get isBusy => phase.value != SyncPhase.idle;

  void start(SyncPhase nextPhase, String nextMessage) {
    phase.value = nextPhase;
    message.value = nextMessage;
  }

  void finish() {
    phase.value = SyncPhase.idle;
    message.value = '';
  }
}
