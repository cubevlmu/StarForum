import 'package:star_forum/data/json/json_reader.dart';

class JsonApiResource {
  const JsonApiResource({
    required this.type,
    required this.id,
    required this.attributes,
    required this.relationships,
  });

  final String type;
  final String id;
  final JsonMap attributes;
  final JsonMap relationships;

  int get intId => int.tryParse(id) ?? -1;

  factory JsonApiResource.from(Object? raw) {
    final json = asJsonMap(raw);
    return JsonApiResource(
      type: JsonValue.asString(json['type']),
      id: JsonValue.asString(json['id']),
      attributes: asJsonMap(json['attributes']),
      relationships: asJsonMap(json['relationships']),
    );
  }

  JsonMap relationshipData(String key) {
    return asJsonMap(asJsonMap(relationships[key])['data']);
  }

  List<JsonApiResourceIdentifier> relationshipIdentifiers(String key) {
    final data = asJsonMap(relationships[key])['data'];
    if (data is List) {
      return data
          .map(JsonApiResourceIdentifier.from)
          .whereType<JsonApiResourceIdentifier>()
          .toList(growable: false);
    }
    final identifier = JsonApiResourceIdentifier.from(data);
    return identifier == null ? const [] : [identifier];
  }

  String? relatedId(String key) {
    final value = relationshipData(key)['id'];
    return value?.toString();
  }

  List<String> relatedIds(String key) {
    final data = asJsonList(asJsonMap(relationships[key])['data']);
    return [
      for (final item in data)
        if (asJsonMap(item)['id'] != null) asJsonMap(item)['id'].toString(),
    ];
  }
}

class JsonApiResourceIdentifier {
  const JsonApiResourceIdentifier({required this.type, required this.id});

  final String type;
  final String id;

  static JsonApiResourceIdentifier? from(Object? raw) {
    final json = asJsonMap(raw);
    final type = json['type']?.toString();
    final id = json['id']?.toString();
    if (type == null || type.isEmpty || id == null || id.isEmpty) return null;
    return JsonApiResourceIdentifier(type: type, id: id);
  }
}
