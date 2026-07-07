import 'package:star_forum/data/api/flarum_links.dart';
import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/uploads.dart';

import 'mapper_support.dart';

class UploadMapper {
  const UploadMapper();

  UploadFileList documentList(JsonApiDocument document) {
    return UploadFileList(
      list: [
        for (final resource in documentResources(document))
          if (resource.type == 'files') resourceItem(resource),
      ],
      links: Links.fromMap(document.links),
    );
  }

  UploadFileInfo resourceItem(JsonApiResource resource) {
    final attrs = JsonReader(resource.attributes);
    return UploadFileInfo(
      id: resource.intId,
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
