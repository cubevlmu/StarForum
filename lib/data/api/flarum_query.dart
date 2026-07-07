class FlarumQuery {
  final Map<String, String> _values = {};

  FlarumQuery page({int offset = 0, int limit = 20}) {
    _values['page[offset]'] = offset.toString();
    _values['page[limit]'] = limit.toString();
    return this;
  }

  FlarumQuery sort(String? value) {
    if (value != null && value.isNotEmpty) _values['sort'] = value;
    return this;
  }

  FlarumQuery include(List<String> values) {
    if (values.isNotEmpty) _values['include'] = values.join(',');
    return this;
  }

  FlarumQuery fields(String type, List<String> values) {
    if (values.isNotEmpty) _values['fields[$type]'] = values.join(',');
    return this;
  }

  FlarumQuery filter(String key, String value) {
    if (value.isNotEmpty) _values['filter[$key]'] = value;
    return this;
  }

  FlarumQuery search(String query) => filter('q', query);

  Map<String, String> build() => Map.unmodifiable(_values);
}
