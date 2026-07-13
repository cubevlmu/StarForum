import 'package:flutter_secure_storage/flutter_secure_storage.dart';

FlutterSecureStorage createAppSecureStorage() {
  return FlutterSecureStorage(
    mOptions: const MacOsOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );
}
