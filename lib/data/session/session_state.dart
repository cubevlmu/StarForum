import 'package:flutter/foundation.dart';

enum SessionStatus { unknown, checking, authenticated, signedOut, expired }

@immutable
class SessionSnapshot {
  const SessionSnapshot({
    this.status = SessionStatus.unknown,
    this.userId,
    this.avatarUrl = '',
    this.canUpload = false,
  });

  final SessionStatus status;
  final int? userId;
  final String avatarUrl;
  final bool canUpload;

  bool get isAuthenticated => status == SessionStatus.authenticated;

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        other is SessionSnapshot &&
            status == other.status &&
            userId == other.userId &&
            avatarUrl == other.avatarUrl &&
            canUpload == other.canUpload;
  }

  @override
  int get hashCode => Object.hash(status, userId, avatarUrl, canUpload);
}

class SessionState {
  final ValueNotifier<SessionSnapshot> state = ValueNotifier(
    const SessionSnapshot(),
  );

  SessionSnapshot get current => state.value;

  void publish(SessionSnapshot snapshot) {
    if (snapshot != state.value) state.value = snapshot;
  }
}
