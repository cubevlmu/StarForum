enum FlarumAuthKind { none, accessToken, apiKey }

class FlarumAuthToken {
  const FlarumAuthToken.none()
    : kind = FlarumAuthKind.none,
      token = '',
      userId = null;

  const FlarumAuthToken.access(this.token)
    : kind = FlarumAuthKind.accessToken,
      userId = null;

  const FlarumAuthToken.apiKey(this.token, {this.userId})
    : kind = FlarumAuthKind.apiKey;

  final FlarumAuthKind kind;
  final String token;
  final int? userId;

  String? toAuthorizationHeader() {
    if (kind == FlarumAuthKind.none || token.isEmpty) return null;
    if (kind == FlarumAuthKind.accessToken || userId == null) {
      return 'Token $token';
    }
    return 'Token $token; userId=$userId';
  }

  static FlarumAuthToken parseLegacy(
    String? stored, {
    FlarumAuthKind? storedKind,
    int? storedUserId,
  }) {
    final value = stored?.trim() ?? '';
    if (value.isEmpty) return const FlarumAuthToken.none();
    final withoutPrefix = value.startsWith('Token ')
        ? value.substring('Token '.length)
        : value;
    final parts = withoutPrefix.split(';');
    final rawToken = parts.first.trim();
    int? embeddedUserId;
    for (final part in parts.skip(1)) {
      final match = RegExp(r'userId\s*=\s*(\d+)').firstMatch(part);
      embeddedUserId ??= int.tryParse(match?.group(1) ?? '');
    }
    if (storedKind == FlarumAuthKind.apiKey) {
      return FlarumAuthToken.apiKey(
        rawToken,
        userId: storedUserId ?? embeddedUserId,
      );
    }
    return FlarumAuthToken.access(rawToken);
  }
}
