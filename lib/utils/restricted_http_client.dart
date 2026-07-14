import 'package:http/http.dart' as http;

import 'restricted_http_client_stub.dart'
    if (dart.library.io) 'restricted_http_client_io.dart'
    as implementation;

http.Client createRestrictedCertificateClient(String allowedHost) {
  return implementation.createRestrictedCertificateClient(allowedHost);
}
