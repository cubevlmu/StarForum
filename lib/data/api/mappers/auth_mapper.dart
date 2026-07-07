import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/login_result.dart';

class AuthMapper {
  const AuthMapper();

  LoginResult? loginResult(Object? raw) {
    final json = asJsonMap(raw);
    final token = JsonValue.asString(json['token']);
    final userId = JsonValue.asInt(json['userId'], -1);
    if (token.isEmpty || userId < 0) return null;
    return LoginResult(userId: userId, token: token);
  }
}
