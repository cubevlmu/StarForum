import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_auth.dart';
import 'package:star_forum/data/api/flarum_transport_error.dart';
import 'package:star_forum/data/api/mappers/auth_mapper.dart';
import 'package:star_forum/data/model/login_result.dart';

class AuthApi {
  AuthApi(this.client);

  final FlarumApiClient client;

  Future<LoginResult?> login({
    required String identification,
    required String password,
    bool remember = true,
  }) async {
    final response = await client.post<Object?>(
      '/api/token',
      data: {
        'identification': identification,
        'password': password,
        'remember': remember ? 1 : 0,
      },
      options: Options(contentType: Headers.formUrlEncodedContentType),
    );
    return const AuthMapper().loginResult(response.data);
  }

  Future<bool> logout({bool global = false}) async {
    if (client.auth.kind != FlarumAuthKind.accessToken) return true;
    try {
      final response = await client.post<Object?>(
        '/logout',
        data: {if (global) 'global': 1},
        options: Options(contentType: Headers.formUrlEncodedContentType),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } on FlarumTransportError catch (error) {
      if (error.statusCode == 404 || error.statusCode == 405) {
        client.setEnvironment(
          client.environment.copyWith(
            features: client.environment.features.copyWith(
              supportsPostLogout: false,
            ),
          ),
        );
        return true;
      }
      return false;
    }
  }
}
