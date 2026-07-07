import 'json_api_resource.dart';

class JsonApiIncludedIndex {
  JsonApiIncludedIndex(List<JsonApiResource> included) {
    for (final resource in included) {
      _resources.putIfAbsent(
        resource.type,
        () => <String, JsonApiResource>{},
      )[resource.id] = resource;
    }
  }

  final Map<String, Map<String, JsonApiResource>> _resources = {};

  JsonApiResource? find(String type, String id) => _resources[type]?[id];

  Iterable<JsonApiResource> ofType(String type) =>
      _resources[type]?.values ?? const <JsonApiResource>[];
}
