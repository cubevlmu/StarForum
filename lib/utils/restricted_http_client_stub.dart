import 'package:http/http.dart' as http;

http.Client createRestrictedCertificateClient(String allowedHost) {
  return http.Client();
}
