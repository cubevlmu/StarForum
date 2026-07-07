import 'package:dio/dio.dart';
import 'package:star_forum/data/api/flarum_api_client.dart';
import 'package:star_forum/data/api/flarum_page.dart';
import 'package:star_forum/data/api/flarum_query.dart';
import 'package:star_forum/data/model/notifications.dart';

import 'api_parsing.dart';

class NotificationApi {
  NotificationApi(this.client);

  final FlarumApiClient client;

  Future<FlarumPage<NotificationsInfo>?> list({String? nextUrl}) async {
    final response = await client.get<Object?>(
      nextUrl ?? '/api/notifications',
      query: nextUrl == null ? FlarumQuery().page(limit: 20).build() : null,
    );
    final parsed = parseNotifications(response.data);
    return FlarumPage(
      items: parsed.list,
      nextUrl: parsed.links.next.isEmpty ? null : parsed.links.next,
      prevUrl: parsed.links.prev.isEmpty ? null : parsed.links.prev,
    );
  }

  Future<NotificationsInfo?> markRead(String id) async {
    final response = await client.patch<Object?>(
      '/api/notifications/$id',
      data: {
        'data': {
          'type': 'notifications',
          'id': id,
          'attributes': {'isRead': true},
        },
      },
    );
    return parseNotification(response.data);
  }

  Future<bool> readAll() async {
    final response = await client.post<Object?>('/api/notifications/read');
    return response.statusCode == 200 || response.statusCode == 204;
  }

  Future<bool> clearAll() async {
    final response = await client.post<Object?>(
      '/api/notifications',
      options: Options(headers: {'X-HTTP-Method-Override': 'DELETE'}),
    );
    return response.statusCode == 200 || response.statusCode == 204;
  }
}
