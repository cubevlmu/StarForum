import 'package:get/get_utils/src/extensions/export.dart';

class StringUtil {
  static String numFormat(int num) {
    double num1 = num / 10000;
    if (num1 >= 1) {
      if (num1 - num1.toInt() < 0.1) {
        return "${num1.toInt()}万";
      } else {
        return "${num1.toPrecision(1)}万";
      }
    } else {
      return num.toString();
    }
  }

  static String timeLengthFormat(int timeLength) {
    int h = timeLength ~/ 3600;
    int s0 = timeLength % 3600;
    int m = s0 ~/ 60;
    int s = s0 % 60;
    String ret;
    if (h != 0) {
      ret =
          "$h:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    } else {
      ret = "${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}";
    }
    return ret;
  }

  static String timeStampToAgoDate(int timeStamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);

    if (date.isAfter(now)) {
      return "刚刚";
    }

    final delta = now.difference(date);

    if (delta.inMinutes < 1) {
      return "刚刚";
    }

    if (delta.inMinutes < 60) {
      return "${delta.inMinutes}分钟前";
    }

    if (delta.inHours < 24) {
      return "${delta.inHours}小时前";
    }

    if (now.year == date.year) {
      return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  static String timeStampToDate(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return "${date.year}-${date.month}-${date.day}";
  }

  static String timeStampToTime(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return timeLengthFormat(date.hour * 3600 + date.minute * 60 + date.second);
  }

  static String keyWordTitleToRawTitle(String keyWordTitle) {
    return keyWordTitle.replaceAll(RegExp(r'<.*?>'), '');
  }

  static String byteNumToFileSize(double byteNum) {
    if (byteNum / 1024 < 1) {
      return "${byteNum}byte";
    } else if (byteNum / 1024 / 1024 < 1) {
      return "${(byteNum / 1024).toPrecision(2)}KB";
    } else if (byteNum / 1024 / 1024 / 1024 < 1) {
      return "${(byteNum / 1024 / 1024).toPrecision(2)}MB";
    } else if (byteNum / 1024 / 1024 / 1024 / 1024 < 1) {
      return "${(byteNum / 1024 / 1024 / 1024).toPrecision(2)}GB";
    } else {
      return "${byteNum}byte";
    }
  }

  static String replaceAllHtmlEntitiesToCharacter(String str) {
    String newStr = str.replaceAllMapped(RegExp(r'&.*?;'), (match) {
      switch (match[0]) {
        case '&lt;':
          return '<';
        case '&gt;':
          return '>';
        case '&amp;':
          return '&';
        case '&quot;':
          return '"';
        case '&apos;':
          return '\'';
        case '&cent;':
          return '¢';
        case '&pound;':
          return '£';
        default:
          if (match[0] == null) return '';
          if (match[0]!.startsWith('&#') && match[0]!.endsWith(';')) {
            var numberStr = match[0]!
                .replaceFirst('&#', '')
                .replaceFirst(';', '');
            int? number = numberStr.startsWith('x')
                ? int.tryParse(numberStr.replaceFirst('x', ''), radix: 16)
                : int.tryParse(numberStr);
            if (number != null) {
              return String.fromCharCode(number);
            }
          }
          return match[0]!;
      }
    });
    if (str == newStr) return str;
    return replaceAllHtmlEntitiesToCharacter(newStr);
  }

  static String mapToQueryString(Map<String, dynamic> params) {
    if (params.isEmpty) {
      return '';
    }
    final query = StringBuffer();
    params.forEach((key, value) {
      if (query.isNotEmpty) {
        query.write('&');
      }
      query.write(Uri.encodeQueryComponent(key));
      query.write('=');
      query.write(Uri.encodeQueryComponent(value ?? ""));
    });
    return query.toString();
  }

  static String mapToQueryStringSorted(Map<String, dynamic> params) {
    if (params.isEmpty) {
      return '';
    }
    final query = StringBuffer();
    params.keys.toList()
      ..sort()
      ..forEach((key) {
        if (query.isNotEmpty) {
          query.write('&');
        }
        query.write(Uri.encodeQueryComponent(key));
        query.write('=');
        query.write(Uri.encodeQueryComponent(params[key]?.toString() ?? ''));
      });
    return query.toString();
  }

  static String ensureNotNegative(int i) {
    if (i < 0) return "0";
    return i.toString();
  }

  static String? normalizeSiteUrl(String input) {
    var url = input.trim();

    if (url.isEmpty) return null;

    if (!url.contains('://')) {
      url = 'https://$url';
    }

    Uri uri;
    try {
      uri = Uri.parse(url);
    } catch (_) {
      return null;
    }

    if (!uri.hasAuthority) return null;
    uri = uri.replace(scheme: 'https');
    var path = uri.path.replaceAll(RegExp(r'/+'), '/');

    if (path.endsWith('/') && path.length > 1) {
      path = path.substring(0, path.length - 1);
    }

    uri = uri.replace(
      path: path == '/' ? '' : path,
      query: null,
      fragment: null,
    );

    return uri.toString();
  }
}

final fallbackTime = DateTime.utc(1980);
