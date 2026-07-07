import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_endpoint.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/model/tags.dart';

import 'api_parsing.dart';

class TagApi {
  TagApi(this.client);

  final FlarumApiClient client;

  Future<Tags?> list() async {
    final response = await client.get<Object?>(
      '/api/tags',
      query: FlarumQuery()
          .include(['parent'])
          .fields('tags', DiscussionQueries.tagFields)
          .build(),
    );
    return parseTags(response.data);
  }
}
