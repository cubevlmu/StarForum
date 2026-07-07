import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/json/json_reader.dart';
import 'package:star_forum/data/model/forum_info.dart';

import 'mapper_support.dart';

class ForumMapper {
  const ForumMapper();

  ForumInfo? document(JsonApiDocument document) {
    final resource = documentResource(document);
    if (resource == null || resource.type != 'forums') return null;
    final attrs = JsonReader(resource.attributes);
    return ForumInfo(
      url: attrs.string('baseUrl'),
      title: attrs.string('title'),
      description: attrs.string('description'),
      welcomeTitle: attrs.string('welcomeTitle'),
      welcomeMessage: attrs.string('welcomeMessage'),
      logoUrl: attrs.string('logoUrl'),
      canUpload: attrs.boolean('fof-upload.canUpload'),
    );
  }
}
