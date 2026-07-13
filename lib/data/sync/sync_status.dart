import 'package:flutter/foundation.dart';

enum SyncPhase { idle, checking, hydrating }

class SyncStatusService {
  final phase = ValueNotifier(SyncPhase.idle);

  bool get isBusy => phase.value != SyncPhase.idle;

  void start(SyncPhase nextPhase) {
    phase.value = nextPhase;
  }

  void finish() {
    phase.value = SyncPhase.idle;
  }
}
