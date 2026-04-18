import 'base.dart';

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

  factory UploadFileInfo.fromBaseData(BaseData data) {
    final attrs = data.attrs;
    return UploadFileInfo(
      id: data.id,
      baseName: attrs.string('baseName'),
      path: attrs.string('path'),
      url: attrs.string('url'),
      type: attrs.string('type'),
      size: attrs.integer('size'),
      humanSize: attrs.string('humanSize'),
      createdAt: attrs.dateTime('createdAt'),
      uuid: attrs.string('uuid'),
      tag: attrs.string('tag'),
      hidden: attrs.boolean('hidden'),
      bbcode: attrs.string('bbcode'),
      shared: attrs.boolean('shared'),
      canViewInfo: attrs.boolean('canViewInfo'),
      canHide: attrs.boolean('canHide'),
      canDelete: attrs.boolean('canDelete'),
    );
  }
}

class UploadFileList {
  final List<UploadFileInfo> list;
  final Links links;

  const UploadFileList({required this.list, required this.links});

  factory UploadFileList.fromMap(Map map) {
    return UploadFileList.fromBase(BaseListBean.fromMap(map));
  }

  factory UploadFileList.fromBase(BaseListBean base) {
    final list = <UploadFileInfo>[];
    for (final item in base.data.list) {
      if (item.type == 'files') {
        list.add(UploadFileInfo.fromBaseData(item));
      }
    }
    return UploadFileList(list: list, links: base.links);
  }
}
