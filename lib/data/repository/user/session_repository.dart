import 'dart:async';

import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_auth.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/services/auth_api.dart';
import 'package:star_forum/data/auth/auth_storage.dart';
import 'package:star_forum/data/model/users.dart';
import 'package:star_forum/data/repository/user/forum_permission_service.dart';
import 'package:star_forum/data/repository/user/user_repository.dart';
import 'package:star_forum/data/session/session_state.dart';
import 'package:star_forum/utils/log_util.dart';

enum UserRepoState { unknown, notLogin, checkingToken, loggedIn, expired }

class SessionRepository {
  SessionRepository(
    this.authApi,
    this.apiClient,
    this.userRepository,
    this.permissionService,
    this.sessionState, {
    AuthStorage? storage,
  }) : storage = storage ?? AuthStorage();

  final AuthApi authApi;
  final FlarumApiClient apiClient;
  final UserRepository userRepository;
  final ForumPermissionService permissionService;
  final SessionState sessionState;
  final AuthStorage storage;

  UserRepoState _state = UserRepoState.unknown;
  UserInfo? _user;
  bool _canUpload = false;
  bool _setupCalled = false;
  bool _isLoggingOut = false;
  Future<void>? _setupTask;
  Future<bool>? _refreshTask;
  Timer? _refreshTimer;

  static const refreshInterval = Duration(minutes: 15);

  UserRepoState get state => _state;
  bool get isLogin => _state == UserRepoState.loggedIn;
  UserInfo? get user => _user;
  int get userId => int.tryParse(storage.userId ?? '') ?? -1;

  Future<void> setup() async {
    final activeTask = _setupTask;
    if (activeTask != null) return activeTask;

    final task = _performSetup();
    _setupTask = task;
    try {
      await task;
    } finally {
      if (identical(_setupTask, task)) _setupTask = null;
    }
  }

  Future<void> _performSetup() async {
    if (_setupCalled) {
      LogUtil.debug('[SessionRepository] setup already called');
      return;
    }
    _setupCalled = true;
    if (!storage.hasLogin || storage.userId == null) {
      _setNotLogin();
      return;
    }

    _state = UserRepoState.checkingToken;
    _publish();
    apiClient.setAuth(await storage.authToken);
    final cached = await userRepository.getCachedByNameOrId(storage.userId!);
    if (cached != null) {
      _user = cached;
      _state = UserRepoState.loggedIn;
      _publish();
    }
    final legacyUsername = storage.username;
    final legacyPassword = await storage.takeLegacyPassword();

    try {
      final authInvalid = await _fetchCurrentUser();
      if (authInvalid &&
          legacyUsername != null &&
          legacyUsername.isNotEmpty &&
          legacyPassword != null &&
          legacyPassword.isNotEmpty) {
        await login(legacyUsername, legacyPassword);
      }
      unawaited(refreshPermissions());
    } catch (error, stackTrace) {
      LogUtil.errorE('[SessionRepository] setup failed', error, stackTrace);
      await _clearLogin();
    }
  }

  Future<bool> _fetchCurrentUser() async {
    try {
      final current = await userRepository.fetchAndCache(storage.userId ?? '0');
      if (current == null) {
        await _clearLogin();
        return true;
      }
      _user = current;
      _state = UserRepoState.loggedIn;
      _publish();
      return false;
    } on FlarumTransportError catch (error, stackTrace) {
      LogUtil.errorE(
        '[SessionRepository] fetch current user failed',
        error,
        stackTrace,
      );
      if (error.isAuthExpired) {
        await _clearLogin();
        return true;
      }
      return false;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[SessionRepository] fetch current user failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<bool> login(
    String username,
    String password, {
    bool autoRelogin = true,
  }) async {
    final previousAuth = apiClient.auth;
    var temporaryAuthApplied = false;
    try {
      final response = await authApi.login(
        identification: username,
        password: password,
        remember: true,
      );
      if (response == null) return false;

      apiClient.setAuth(FlarumAuthToken.access(response.token));
      temporaryAuthApplied = true;
      final current = await userRepository.fetchAndCache(
        response.userId.toString(),
      );
      if (current == null) {
        apiClient.setAuth(previousAuth);
        return false;
      }

      await storage.saveLogin(
        token: response.token,
        userId: response.userId.toString(),
        authKind: FlarumAuthKind.accessToken,
        username: username,
      );
      _user = current;
      _state = UserRepoState.loggedIn;
      _publish();
      await refreshPermissions();
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE('[SessionRepository] login failed', error, stackTrace);
      if (temporaryAuthApplied) apiClient.setAuth(previousAuth);
      return false;
    }
  }

  Future<bool> refreshCurrentUser() async {
    final activeTask = _refreshTask;
    if (activeTask != null) return activeTask;
    final task = _refreshCurrentUser();
    _refreshTask = task;
    try {
      return await task;
    } finally {
      if (identical(_refreshTask, task)) _refreshTask = null;
    }
  }

  Future<bool> _refreshCurrentUser() async {
    if (!isLogin || storage.userId == null) return false;
    try {
      final current = await userRepository.fetchAndCache(storage.userId!);
      if (current == null) return false;
      _user = current;
      _state = UserRepoState.loggedIn;
      _publish();
      await refreshPermissions();
      return true;
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[SessionRepository] refresh current user failed',
        error,
        stackTrace,
      );
      return false;
    }
  }

  Future<void> logout() async {
    if (_isLoggingOut) return;
    _isLoggingOut = true;
    try {
      await authApi.logout();
    } catch (error, stackTrace) {
      LogUtil.errorE(
        '[SessionRepository] remote logout failed',
        error,
        stackTrace,
      );
    } finally {
      await _clearLogin();
      _isLoggingOut = false;
    }
  }

  Future<void> refreshPermissions() async {
    _canUpload = await permissionService.canUpload(authenticated: isLogin);
    _publish();
  }

  Future<void> _clearLogin() async {
    _state = UserRepoState.expired;
    _publish();
    await storage.clear();
    apiClient.clearAuth();
    _canUpload = false;
    _setNotLogin();
  }

  void _setNotLogin() {
    _user = null;
    _state = UserRepoState.notLogin;
    _canUpload = false;
    _publish();
  }

  void _publish() {
    _updateRefreshTimer();
    sessionState.publish(
      SessionSnapshot(
        status: switch (_state) {
          UserRepoState.unknown => SessionStatus.unknown,
          UserRepoState.notLogin => SessionStatus.signedOut,
          UserRepoState.checkingToken => SessionStatus.checking,
          UserRepoState.loggedIn => SessionStatus.authenticated,
          UserRepoState.expired => SessionStatus.expired,
        },
        userId: _user?.id ?? int.tryParse(storage.userId ?? ''),
        avatarUrl: _user?.avatarUrl ?? '',
        canUpload: _canUpload,
      ),
    );
  }

  void _updateRefreshTimer() {
    if (_state != UserRepoState.loggedIn) {
      _refreshTimer?.cancel();
      _refreshTimer = null;
      return;
    }
    _refreshTimer ??= Timer.periodic(refreshInterval, (_) {
      unawaited(refreshCurrentUser());
    });
  }
}
