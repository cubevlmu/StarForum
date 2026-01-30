import 'package:get/get_utils/src/extensions/export.dart';

//格式化工具
class StringUtil {
  ///数目字符串格式化
  ///将整数转换成简写字符串表示
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

  ///时长字符串格式化
  ///将秒时长（整数）转换成时分秒字符串表示
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

  ///将时间戳(秒为单位)转换为日期
  ///即本年前的转换为:年-月-日;
  ///本年内且时间距今大于一天的转换为:月-日;
  ///距今一天内且小于1分钟的转换为:刚刚
  ///据今大于等于1分钟且小于1小时的转换为:n分钟前
  ///距今大于等于1小时且小于24小时的转换为:n小时前
  static String timeStampToAgoDate(int timeStamp) {
    final now = DateTime.now();
    final date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);

    // 未来时间
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

    // 超过一天
    if (now.year == date.year) {
      return "${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
    }

    // 非本年
    return "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";
  }

  //时间戳转日期(年-月-日)
  static String timeStampToDate(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return "${date.year}-${date.month}-${date.day}";
  }

  //时间戳转时刻(时-分-秒)
  static String timeStampToTime(int timeStamp) {
    var date = DateTime.fromMillisecondsSinceEpoch(timeStamp * 1000);
    return timeLengthFormat(date.hour * 3600 + date.minute * 60 + date.second);
  }

  //去掉标题的关键词标签
  static String keyWordTitleToRawTitle(String keyWordTitle) {
    return keyWordTitle.replaceAll(RegExp(r'<.*?>'), '');
  }

  //byte数转文件大小
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

  ///将字符串中html字符实体改为对应的文字符号
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
          //如果&#和;之间是数字，则转换成对应unicode编码的字符
          if (match[0]!.startsWith('&#') && match[0]!.endsWith(';')) {
            var numberStr = match[0]!
                .replaceFirst('&#', '')
                .replaceFirst(';', '');
            //转换成int时如果数字前有x，则是16进制，否则按10进制转换
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

  ///将map转换成url查询字符串
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

  ///将map按key排序然后转换成url查询字符串
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
}
