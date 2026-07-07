import 'package:package_info_plus/package_info_plus.dart';

abstract final class AppInfo {
  const AppInfo._();

  static PackageInfo? _cached;

  static Future<PackageInfo> load() async {
    final cached = _cached;
    if (cached != null) return cached;
    final info = await PackageInfo.fromPlatform();
    _cached = info;
    return info;
  }

  static Future<String> version() async {
    final info = await load();
    return info.version;
  }

  static Future<String> versionLabel() async {
    final info = await load();
    if (info.buildNumber.isEmpty) return info.version;
    return '${info.version}+${info.buildNumber}';
  }
}
