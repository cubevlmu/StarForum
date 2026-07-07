import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/model/badge.dart';

import '../services/api_parsing.dart';

class BadgeApi {
  BadgeApi(this.client);

  final FlarumApiClient client;

  Future<BadgeCategories?> listCategories() async {
    final query = FlarumQuery()
        .include(['badges'])
        .fields('badgeCategories', ['name', 'description', 'badges'])
        .fields('badges', ['name', 'icon', 'description', 'earnedAmount']);
    final response = await client.get<Object?>(
      '/api/badge_categories',
      query: query.build(),
    );
    return parseBadges(response.data);
  }
}
