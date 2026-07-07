import 'package:star_forum/data/json/json_reader.dart';

class Links {
  const Links({required this.first, required this.prev, required this.next});

  final String first;
  final String prev;
  final String next;

  static const Links empty = Links(first: '', prev: '', next: '');

  factory Links.fromMap(Object? value) {
    final reader = JsonReader(asJsonMap(value));
    return Links(
      first: reader.string('first'),
      prev: reader.string('prev'),
      next: reader.string('next'),
    );
  }
}
