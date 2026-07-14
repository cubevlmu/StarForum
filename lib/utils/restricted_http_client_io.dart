import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:http/io_client.dart';

http.Client createRestrictedCertificateClient(String allowedHost) {
  final normalizedHost = allowedHost.toLowerCase();
  final client = HttpClient()
    ..badCertificateCallback = (_, host, _) {
      return host.toLowerCase() == normalizedHost;
    };
  return IOClient(client);
}
