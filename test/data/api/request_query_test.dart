import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_api_environment.dart';
import 'package:star_forum/data/api/services/post_api.dart';
import 'package:star_forum/data/api/services/user_api.dart';

void main() {
  test('user directory sends the selected group to Flarum', () async {
    final adapter = _RecordingAdapter(_emptyListDocument);
    final api = UserApi(_client(adapter));

    await api.directory(groupId: 4, limit: 20, offset: 0);

    expect(adapter.requests.single.path, 'https://forum.test/api/users');
    expect(adapter.requests.single.queryParameters['filter[group]'], '4');
    expect(adapter.requests.single.queryParameters['include'], 'groups');
  });

  test(
    'post time ordering maps to ascending and descending API sorts',
    () async {
      final adapter = _RecordingAdapter(_emptyListDocument);
      final api = PostApi(_client(adapter));

      await api.listByDiscussion(
        discussionId: '9',
        sort: PostSort.timeAscending,
      );
      await api.listByDiscussion(
        discussionId: '9',
        sort: PostSort.timeDescending,
      );

      expect(adapter.requests[0].queryParameters['sort'], 'createdAt');
      expect(adapter.requests[1].queryParameters['sort'], '-createdAt');
    },
  );

  test('group directory maps stable group ids and names', () async {
    final adapter = _RecordingAdapter({
      'data': [
        {
          'type': 'groups',
          'id': '1',
          'attributes': {
            'nameSingular': 'Administrator',
            'namePlural': 'Administrators',
            'color': '#b72a2a',
          },
        },
      ],
    });
    final api = UserApi(_client(adapter));

    final groups = await api.groups();

    expect(groups.single.id, 1);
    expect(groups.single.name, 'Administrators');
  });
}

const _emptyListDocument = <String, Object>{'data': <Object>[]};

FlarumApiClient _client(_RecordingAdapter adapter) {
  final dio = Dio()..httpClientAdapter = adapter;
  return FlarumApiClient(dio)
    ..setEnvironment(const FlarumApiEnvironment(baseUrl: 'https://forum.test'));
}

class _RecordingAdapter implements HttpClientAdapter {
  _RecordingAdapter(this.response);

  final Object response;
  final List<RequestOptions> requests = [];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    return ResponseBody.fromString(
      jsonEncode(response),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}
