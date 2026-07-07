import 'package:star_forum/data/api/json_api/json_api_document.dart';
import 'package:star_forum/data/api/json_api/json_api_resource.dart';
import 'package:star_forum/data/json/json_reader.dart';

JsonApiResource? documentResource(JsonApiDocument document) {
  final data = document.data;
  if (data == null || data is List) return null;
  final resource = JsonApiResource.from(data);
  return resource.type.isEmpty || resource.id.isEmpty ? null : resource;
}

List<JsonApiResource> documentResources(JsonApiDocument document) {
  return [
    for (final item in asJsonList(document.data))
      if (JsonApiResource.from(item) case final resource
          when resource.type.isNotEmpty && resource.id.isNotEmpty)
        resource,
  ];
}

String? linkValue(JsonApiDocument document, String key) {
  final value = document.links[key]?.toString();
  return value == null || value.isEmpty ? null : value;
}
