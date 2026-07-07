import 'package:star_forum/data/api/flarum_links.dart';

class UploadFileInfo {
  final int id;
  final String baseName;
  final String path;
  final String url;
  final String type;
  final int size;
  final String humanSize;
  final DateTime createdAt;
  final String uuid;
  final String tag;
  final bool hidden;
  final String bbcode;
  final bool shared;
  final bool canViewInfo;
  final bool canHide;
  final bool canDelete;

  const UploadFileInfo({
    required this.id,
    required this.baseName,
    required this.path,
    required this.url,
    required this.type,
    required this.size,
    required this.humanSize,
    required this.createdAt,
    required this.uuid,
    required this.tag,
    required this.hidden,
    required this.bbcode,
    required this.shared,
    required this.canViewInfo,
    required this.canHide,
    required this.canDelete,
  });
}

class UploadFileList {
  final List<UploadFileInfo> list;
  final Links links;

  const UploadFileList({required this.list, required this.links});
}
