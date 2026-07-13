import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/session/session_state.dart';

void main() {
  test('publishes distinct session snapshots only', () {
    final sessionState = SessionState();
    var notifications = 0;
    sessionState.state.addListener(() => notifications += 1);

    const authenticated = SessionSnapshot(
      status: SessionStatus.authenticated,
      userId: 9,
      avatarUrl: 'https://example.invalid/avatar.png',
      canUpload: true,
    );
    sessionState.publish(authenticated);
    sessionState.publish(authenticated);

    expect(sessionState.current, authenticated);
    expect(sessionState.current.isAuthenticated, isTrue);
    expect(notifications, 1);
  });
}
