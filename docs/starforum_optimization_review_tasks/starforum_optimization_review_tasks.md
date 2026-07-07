# StarForum 优化 Review 与任务包



---

<!-- 00_strict_review.md -->

# StarForum 严格 Review：UI / 数据层 / 性能 / 减负优化计划

扫描对象：`lib(13).zip`
范围：`lib/` 下 Dart 代码。没有完整 `pubspec.yaml`，所以本报告基于静态扫描和文件级阅读，不声称已经完成运行时验证。

## 0. 总体结论

项目已经完成 UI 风格迁移的大部分外观工作，但底层还没有收口：

- UI 页面仍大量依赖旧 `widgets/`，尤其是刷新、列表卡片、内容渲染、Notice、Dialog、头像和图片组件。
- 数据层存在新旧两套解析模型并存：`JsonApiDocument/JsonApiResource/mappers` 与 `BaseBean/BaseData/BaseListBean` 同时使用。
- 请求慢不只是服务器慢，客户端还存在额外请求、重复 hydration、过短缓存、启动清空图片缓存、首帖缓存表未使用等问题。
- CPU 性能风险主要在 HTML 解析、列表大量 Obx/RepaintBoundary/Animated shimmer、头像使用 `NetworkImage` 无解码尺寸控制、内容图片解析与缓存策略不统一。
- 代码库负担主要来自 transitional 层没有收口、旧组件未删除、模型承担过多职责、repository/controller 边界不清、EasyRefresh 强耦合到 controller。

本任务包按“先验收、再优化、最后减负”分阶段执行。不要一次性全局乱改。

## 1. 静态扫描关键指标

非生成 Dart 文件约 206 个，Dart 总行数约 38959 行。明显的大文件包括：

- `widgets/content_view.dart`：850 行，HTML 解析、渲染、图片、链接跳转混在一起。
- `pages/assets/view.dart`：627 行。
- `pages/editor/view.dart`：605 行。
- `pages/main/view.dart`：588 行。
- `pages/user/controller.dart`：574 行。
- `pages/notification/controller.dart`：498 行。
- `data/api/api_guard.dart`：481 行。
- `data/repository/discussion_repo.dart`：448 行。
- `data/model/discussions.dart`：411 行。
- `data/model/notifications.dart`：343 行。

### 1.1 旧 UI 依赖仍然很多

扫描到 `package:star_forum/widgets/` 引用 61 处，分布在 32 个文件。高风险页面：

- `pages/post_list/view.dart`：仍用 `PostCard`、`PostListLoadingSkeleton`、`SimpleEasyRefresher`、`NoticeWidget`。
- `pages/post_detail/view.dart`：仍用 `PostListLoadingSkeleton`、`SimpleEasyRefresher`、`SettingsPageHeader`。
- `pages/user/view.dart`：旧 `AvatarWidget`、旧 skeleton、旧 refresh。
- `pages/search_result/view.dart`、`pages/theme_list/view.dart`、`pages/subscription/view.dart`：仍用旧 `PostCard` 或旧刷新组件。
- `pages/assets/view.dart`、`pages/badge/view.dart`、`pages/notification/view.dart`：旧 Notice、Skeleton、Refresh 仍存在。

### 1.2 Material 默认组件还没完全替换

扫描到：

- `AppBar(`：4 处。
- `TabBar(`：3 处。
- `FloatingActionButton(`：2 处，位于 `pages/post_list/view.dart`、`pages/post_detail/view.dart`。
- `TextField(`：12 处，分布在 editor、search、reply sheet、user bio、create discussion、shared dialog 等。
- `FilledButton/ElevatedButton/OutlinedButton`：11 处。
- `ListTile(`：5 处。

这说明 UI 风格迁移尚未完成，只是核心页面部分换了。

### 1.3 数据模型有两套解析链路

旧链路：

- `data/model/base.dart`
- `BaseBean`
- `BaseListBean`
- `BaseData`
- `BaseIncluded`
- 各 model 的 `fromBaseData/fromBase/fromMap`

新链路：

- `data/api/json_api/json_api_document.dart`
- `data/api/json_api/json_api_resource.dart`
- `data/api/mappers/*.dart`

当前状态：新 mapper 已经存在，但仍依赖 `data/model/base.dart` 里的 `JsonReader/JsonValue/asJsonMap/asJsonList`，并且很多老 model factory 还没删除。

扫描到 `BaseBean/BaseData/BaseListBean/PrivateBaseBean` 相关引用 74 处，其中 `data/model/base.dart` 本身 40 处，`notifications/discussions/posts/users/uploads/tags/group_info/badge/forum_info` 都还在用。

### 1.4 请求慢的直接原因

#### A. 讨论列表每次都可能补取首帖

`data/repository/discussion_repo.dart` 的 `_saveFirstPostsAndExcerpts()` 会在讨论列表同步后，对缺失 firstPost 的讨论调用：

```dart
postRepo.getPostsById(missingFirstPostIds.toList())
```

问题：

- `FirstPostsDao` 存在，但几乎没有被使用。
- 没有先检查本地 `first_posts` 或 `excerpt_cache` 是否已有可用内容。
- 每次 sync 都可能触发同类后台请求。
- 服务器慢时，列表出现后摘要迟迟补不上；后台请求也会继续占用连接与解析时间。

#### B. 帖子详情至少两个请求，且首帖与回复分开

`pages/post_detail/controller.dart`：

- `discussionRepo.getDiscussionById(discussion.id)` 获取详情头。
- 如果没有 firstPost，再 `postRepo.getFirstPost(discussion.id)`。
- `PostPage.initState()` 又会调 `controller.onReplyLoad()`，回复走 `/api/posts?filter[discussion]=...`。

这导致进入详情页常见链路是：

1. discussion detail
2. first post fallback
3. replies page

服务器慢时体感会很差。更优方案是优先用一次 posts 请求拿 `offset=0, limit=pageSize+1, sort=number`，首帖和首屏回复一起返回；discussion detail 作为后台补充 viewCount/subscription/tags。

#### C. FlarumApiClient 内存缓存 TTL 偏短且不是 stale-while-revalidate

`data/api/flarum_api_client.dart`：

- posts TTL 20s
- users TTL 30s
- discussion detail TTL 30s
- discussion page offset 0 TTL 20s

问题：

- 慢服务器下，20 秒后重复打开页面又重新慢。
- 没有 stale 数据快速返回机制。
- 没有把 repository 的 DB cache 与 API cache 打通。

#### D. 每次启动会清空大部分图片磁盘缓存

`pages/main/view.dart` 启动后调用：

```dart
CacheUtils.deleteAllCacheImage();
```

`utils/cache_utils.dart` 中 `deleteAllCacheImage()` 会清空除头像以外的 image cache。结果：内容图片、资源缩略图每次启动都重新下载，直接影响网络、IO、首屏感知。

### 1.5 CPU / 内存风险

#### A. `ForumUserAvatar` 使用 `NetworkImage`

文件：`ui/forum/forum_user_avatar.dart`

多个页面传入：

- `pages/post_detail/widgets/post_item.dart`
- `pages/post_detail/widgets/post_main.dart`
- `pages/subscription/view.dart`
- `pages/user/pages/topics_page.dart`
- `pages/user_group/view.dart`
- `widgets/post_card.dart`

`NetworkImage` 没有统一 cache manager，也没有 `memCacheWidth/memCacheHeight`，容易让小头像按原图尺寸解码，占内存且滚动时抖。

#### B. `ContentView` 过大且职责过重

`widgets/content_view.dart` 同时负责：

- HTML parse
- HTML AST 转 block
- block 渲染
- 图片组件
- 链接/用户跳转
- shimmer loading
- LRU cache

它已经做了部分优化：

- 内容长度 > 1500 时 `compute()`。
- parsed blocks LRU 24。
- RepaintBoundary。

但仍有问题：

- 长帖同时出现时会创建多个 isolate parse 任务。
- 每个 loading placeholder 自己持有 `AnimationController`。
- LRU 24 对帖子详情和来回进入页面偏小。
- cache key 用全文字符串，长帖 key 内存成本高。

#### C. `htmlToPlainText` 缓存以完整 HTML 字符串为 key

文件：`utils/html_utils.dart`

`_plainTextCache` 最大 600，key 是完整 HTML。长帖多时，key 本身就可能占明显内存。应该换成 hash key + 长度校验或仅缓存短 HTML。

#### D. `watchDiscussionItems` 组合 `watchPaged(limit)` + `excerptDao.watchAll()`

文件：`data/repository/discussion_repo.dart`

`excerptDao.watchAll()` 会监听全部 excerpt，每次 excerpt 表变化都可能让当前列表重新 map。讨论多时应该只 watch 当前 limit 的 excerpt，或 join 查询只取当前可见讨论对应摘要。

### 1.6 明显可疑的编译/兼容点

#### A. `EdgeInsetsGeometry.all(40)` 可疑

文件：`widgets/cached_network_image.dart`

```dart
padding: EdgeInsetsGeometry.all(40),
```

一般应为：

```dart
padding: EdgeInsets.all(40),
```

让 agent 优先跑 `flutter analyze` 确认。

#### B. enum dot shorthand 依赖 Dart SDK 版本

文件：`data/repository/user_repo.dart`、`pages/post_list/controller.dart`

例如：

```dart
UserRepoState _state = .unknown;
_state == .loggedIn;
refreshController.finishRefresh(.fail);
```

如果项目 SDK 约束不支持，会直接 analyze 失败。需要以当前 `pubspec.yaml` 为准。若不支持，统一改回完整枚举名。

## 2. 优化总原则

1. 先建立性能基线，再改代码。
2. 先修请求链路，后删旧代码。
3. 列表先保证首屏快，不强求摘要立刻完整。
4. 详情页首帖 + 首屏回复优先合并请求。
5. model 只保留业务实体，不继续承担 JSON:API 解析职责。
6. UI 组件统一走 `ui/`，旧 `widgets/` 只保留临时桥接，最终删除。
7. 每一阶段必须 `flutter analyze` 通过。
8. 每一阶段输出修改文件列表、性能变化和遗留问题。


---

<!-- 01_master_task_table.md -->

# StarForum 优化任务总表

## 执行规则

- 每个阶段单独提交，不要一次性全局重构。
- 每个阶段必须跑 `flutter analyze`。
- 涉及数据层的阶段补最小单测或 fixture。
- 涉及 UI 性能的阶段至少手工验证：滚动列表、帖子详情、搜索、用户页、通知页。
- 不要改变已有业务功能和导航行为。
- 不要在页面层直接新增网络请求。
- 不要继续扩大 `widgets/` 目录依赖。

## 阶段顺序

1. Phase 0：验收基线与明显错误修复。
2. Phase 1：请求链路性能优化。
3. Phase 2：数据模型减负，收口 JSON:API mapper。
4. Phase 3：列表/详情缓存与本地 DB 优化。
5. Phase 4：UI 滚动性能与图片/头像内存优化。
6. Phase 5：旧 widgets 清理与组件统一。
7. Phase 6：测试、回归与性能验收。

## 最终完成标准

- `flutter analyze` 零错误。
- 页面层不直接使用 `HttpUtils().get/post/patch/delete`。
- 普通 access token 不拼 `; userId=`。
- discussion detail 不依赖 discussion endpoint 返回 posts。
- 进入帖子详情首屏请求减少到 1 个优先 posts 请求 + 1 个后台 discussion metadata 请求。
- 讨论列表刷新不再无条件补取首帖。
- `FirstPostsDao` 不再闲置。
- 旧 `BaseBean/BaseData/BaseListBean` 不再被新 API service/mappers 依赖。
- `widgets/` 目录仅保留仍有必要的通用组件；旧 UI 桥接组件删除或迁入 `ui/legacy/` 并标记 deprecated。
- 内容图片缓存不再每次启动清空。
- 头像统一使用带 cacheManager 和 decode size 的组件。


---

<!-- 02_phase0_baseline.md -->

# Phase 0：基线验收与明显错误修复

目标：先确保当前代码能稳定 analyze，建立后续性能对比基线。

## 任务 0.1 跑基础命令

执行：

```bash
flutter analyze
```

如果项目有测试：

```bash
flutter test
```

输出：

- analyze 错误列表。
- warning 中和性能/废弃 API 有关的项。
- 当前 Flutter / Dart 版本。
- 当前 `pubspec.yaml` 的 environment SDK 约束。

## 任务 0.2 修复明显编译风险

检查并修复：

- `widgets/cached_network_image.dart` 的 `EdgeInsetsGeometry.all(40)`，若 analyze 报错，改为 `EdgeInsets.all(40)`。
- 如果 SDK 不支持 enum dot shorthand，修复：
  - `data/repository/user_repo.dart`
  - `pages/post_list/controller.dart`
  - 其他 `.unknown/.loggedIn/.fail` 类 shorthand。

## 任务 0.3 加性能日志开关

新增轻量性能开关：

```text
lib/data/perf/perf_config.dart
lib/data/perf/perf_log.dart
```

要求：

- debug 模式默认启用。
- release 模式默认关闭。
- 可输出 requestMs / parseMs / dbMs / render hint。
- 不要在 release 下打印大量日志。

## 任务 0.4 记录基线

手工记录以下操作的耗时感知：

- 冷启动到首页。
- 首页首次加载讨论列表。
- 下拉刷新。
- 点进帖子详情到首帖显示。
- 帖子详情首屏回复显示。
- 用户页打开。
- 通知页打开。

输出到：

```text
docs/perf_baseline.md
```

没有 docs 目录就新建。


---

<!-- 03_phase1_request_performance.md -->

# Phase 1：请求链路性能优化

目标：减少慢服务器下的额外请求，让首屏更快出现。

## 任务 1.1 重写帖子详情加载链路

当前问题：

`pages/post_detail/controller.dart` 进入详情后可能发：

1. `/api/discussions/{id}`
2. `/api/posts?filter[discussion]=id&page[limit]=1`
3. `/api/posts?filter[discussion]=id&page[offset]=1&page[limit]=10`

改造目标：

- 首屏优先发一次 posts 请求：

```text
GET /api/posts?filter[discussion]=<id>&sort=number&page[offset]=0&page[limit]=11&include=user
```

- 返回后：
  - 第一条 comment 作为 firstPost。
  - 后续 10 条作为首屏 replies。
- `/api/discussions/{id}` 改为后台 metadata 请求，只更新：
  - viewCount
  - subscription
  - tags
  - commentCount
  - title 修正

具体改动：

- `data/api/services/post_api.dart`
  - 新增 `listInitialByDiscussion()` 或扩展 `listByDiscussion(offset: 0, includeFirstPost: true)`。
- `data/repository/post_repo.dart`
  - 新增 `getInitialPostPage()`，返回 `DiscussionPostBundle(firstPost, replies, nextUrl, hasMore)`。
- `pages/post_detail/controller.dart`
  - onInit 不再先等 discussion detail。
  - 首屏内容由 posts bundle 驱动。
  - metadata 请求后台执行，失败不影响首屏。

验收：

- 打开帖子详情首帖和首屏回复只依赖一次 posts 请求。
- 慢服务器下详情页先显示已有缓存/骨架，再尽快显示首帖。
- discussion metadata 失败不导致页面空白。

## 任务 1.2 讨论列表不要无条件补取首帖

当前问题：

`data/repository/discussion_repo.dart` 的 `_saveFirstPostsAndExcerpts()` 每次 sync 后都会对 missing firstPost 发请求，未先查本地缓存。

改造要求：

1. 使用 `FirstPostsDao`。
2. 新增批量查询：

```dart
Future<Map<String, DbFirstPost>> getByDiscussionIds(List<String> ids)
Future<void> upsertAll(List<DbFirstPostsCompanion> items)
```

3. `_saveFirstPostsAndExcerpts()` 流程改成：

```text
remote discussions
-> 先从 discussion.firstPost 生成 excerpt
-> 对没有 firstPost 的 discussion，查 first_posts 表
-> 本地有且未过期，直接生成 excerpt
-> 只对真正缺失/过期的 firstPostId 批量请求 /api/posts?filter[id]=...
-> 写入 first_posts + excerpt_cache
```

4. 刷新第一页时，首屏列表不等待 excerpt hydration。

验收：

- 连续刷新首页时，不再重复请求相同 firstPostId。
- 首次加载可无摘要，但不能卡主列表。
- 摘要后台补齐后列表自动更新。

## 任务 1.3 API 缓存改为 stale-while-revalidate

当前 `FlarumApiClient` 只有短 TTL 内存缓存。

新增策略：

```dart
class ApiCacheEntry<T> {
  final T value;
  final DateTime freshUntil;
  final DateTime staleUntil;
}
```

要求：

- fresh 命中：直接返回，不发请求。
- stale 命中：先返回旧数据，同时后台刷新。
- expired：正常请求。
- 写操作后精确 invalidation。

建议 TTL：

- `/api` forum info：fresh 5 min，stale 1 day。
- `/api/tags`：fresh 10 min，stale 1 day。
- `/api/discussions` offset 0：fresh 15-20s，stale 10 min。
- `/api/discussions` offset > 0：fresh 60s，stale 30 min。
- `/api/posts?filter[discussion]`：fresh 30s，stale 30 min。
- `/api/users/{id}`：fresh 2 min，stale 1 day。

不要直接缓存 mutation 请求。

## 任务 1.4 请求取消与页面生命周期

要求：

- `PostPageController`、`PostListController`、`SearchResultController`、`UserController` 持有页面级 `CancelToken`。
- 页面关闭时取消未完成请求。
- `FlarumApiClient.get/post/patch/delete` 支持传入 `CancelToken`。
- 被取消的请求映射为 `RepoErrorType.cancelled`，页面不弹错误 toast。

## 任务 1.5 降低字段与 include 体积

检查 `data/api/flarum_endpoint.dart`：

- 列表 query 不要拿正文 HTML。
- 详情 posts query 只拿首屏需要字段。
- 用户列表不要拿 email/bio 等详情字段。
- 头像 `avatarSrcset` 可选，只有需要时请求。

验收：

- discussion list response 不包含 posts 正文。
- user directory 不请求 email/bio。
- post detail 首屏只请求当前显示需要字段。


---

<!-- 04_phase2_model_simplification.md -->

# Phase 2：数据模型减负与解析层收口

目标：去掉“两层模型”，让 JSON:API 解析链路唯一化。

## 任务 2.1 拆分 `data/model/base.dart`

当前 `data/model/base.dart` 同时包含：

- JSON helper：`asJsonMap/asJsonList/JsonValue/JsonReader`
- 旧 JSON:API model：`BaseBean/BaseData/BaseListBean/BaseIncluded/Links`

改造：

新建：

```text
lib/data/json/json_reader.dart
```

移动并保留：

- `JsonMap`
- `asJsonMap`
- `asJsonList`
- `JsonValue`
- `JsonReader`

然后所有 mapper/model 引用 JSON helper 的地方改 import 新文件。

## 任务 2.2 新 mapper 不得依赖旧 BaseBean/BaseData

检查：

- `data/api/mappers/discussion_mapper.dart`
- `data/api/mappers/post_mapper.dart`
- `data/api/mappers/user_mapper.dart`
- `data/api/mappers/notification_mapper.dart`
- `data/api/mappers/tag_mapper.dart`
- `data/api/mappers/forum_mapper.dart`
- `data/api/mappers/auth_mapper.dart`

要求：

- 不 import `data/model/base.dart`。
- 只 import `data/json/json_reader.dart`。
- 只处理 `JsonApiDocument/JsonApiResource`。

## 任务 2.3 清理 model 的旧 factory

逐个迁移：

- `data/model/discussions.dart`
- `data/model/posts.dart`
- `data/model/users.dart`
- `data/model/notifications.dart`
- `data/model/tags.dart`
- `data/model/uploads.dart`
- `data/model/badge.dart`
- `data/model/forum_info.dart`
- `data/model/group_info.dart`

要求：

- 业务 model 只保留字段、构造、少量 UI 转换方法。
- 删除或 deprecated：`fromBaseData/fromBase/fromMapFast/fromBaseList`。
- 如果扩展接口暂时依赖旧解析，先迁到对应 mapper：`UploadMapper`、`BadgeMapper`。

## 任务 2.4 删除 `BaseBean/BaseData` 旧类型

当 grep 无业务引用后，删除：

- `BaseBean`
- `BaseListBean`
- `PrivateBaseBean`
- `BaseData`
- `BaseDataList`
- `BaseIncluded`

保留 `Links` 也应移动到更合适位置，例如：

```text
lib/data/api/flarum_links.dart
```

或者直接使用 `FlarumPage.nextUrl/prevUrl` 替代。

## 任务 2.5 统一排序枚举

当前重复：

- `data/api/services/post_api.dart` 的 `PostSort`
- `data/repository/post_repo.dart` 的 `PostSort`

改造：

- 如果 repository 要屏蔽 API，保留 repo enum，但命名为 `PostPageSort`。
- 或者统一放到 `data/repository/post_query.dart`。
- 不要两个同名 `PostSort`。

验收：

- `grep -R "BaseBean\|BaseData\|BaseListBean" lib/data` 只剩删除前的兼容注释或为 0。
- mapper 单测全部通过。
- model 文件行数明显下降。


---

<!-- 05_phase3_db_cache.md -->

# Phase 3：本地缓存与 DB 优化

目标：让慢服务器下 App 先用本地数据响应，再后台刷新。

## 任务 3.1 使用 first_posts 表

当前 `DbFirstPosts` 与 `FirstPostsDao` 存在但基本闲置。

补充 DAO：

```dart
Future<Map<String, DbFirstPost>> getByDiscussionIds(List<String> discussionIds)
Future<void> upsertAll(List<DbFirstPostsCompanion> items)
Future<int> deleteOlderThan(DateTime threshold)
```

改造 repository：

- 列表摘要优先来自 `DbDiscussionExcerptCache`。
- 缺摘要时从 `DbFirstPosts` 生成。
- 真缺时才请求 `/api/posts?filter[id]=...`。

## 任务 3.2 优化 `watchDiscussionItems`

当前：

```dart
Rx.combineLatest2(discussionsDao.watchPaged(limit), excerptDao.watchAll(), ...)
```

问题：excerpt 全表变化会导致当前列表重新 map。

改造方向二选一：

### 方案 A：DAO join 查询

新增：

```dart
Stream<List<DiscussionItem>> watchDiscussionItems(int limit)
```

在 SQL 中 left join excerpt 表，只返回当前 limit 的摘要。

### 方案 B：分步 watch 当前 ID

- 先 watch 当前 discussions。
- 根据当前 discussion ids watch excerpts by ids。
- 不 watch 全表。

推荐方案 A。

## 任务 3.3 DB migration 不要每次升级都 drop all

当前 `AppDatabase.onUpgrade` 直接 drop 三张表并重建。短期开发可以接受，但这会导致缓存失效与冷启动慢。

改造：

- schemaVersion 增加时按 from/to 做增量迁移。
- 只在不兼容时清表。
- 给缓存表加可重建策略，但不要清主讨论表。

## 任务 3.4 首页 stale cache 优先显示

`PostListController` 当前 `_restorePagingState()` 只恢复 count，并没有立刻保证首屏刷新逻辑最优。

要求：

- 有本地数据时，首页立即显示本地 discussions。
- 后台刷新第一页，不阻塞 UI。
- 刷新失败时保留旧列表，不显示空态。
- 只在首次安装/无缓存时显示 skeleton。

## 任务 3.5 搜索和用户页缓存

- 搜索结果缓存短 TTL，按 keyword + tag + offset。
- 用户信息缓存至少 2 分钟 fresh，1 天 stale。
- 用户目录扩展不可用时缓存 feature unavailable，避免每次进入都 404。

验收：

- 断网后首页能显示已有讨论缓存。
- 重启 App 不清空内容图片缓存，也不清空讨论摘要缓存。
- 首页列表刷新失败不丢旧数据。


---

<!-- 06_phase4_ui_runtime_performance.md -->

# Phase 4：UI 滚动性能、图片与内容渲染优化

目标：降低滚动卡顿、内存占用和图片重复解码。

## 任务 4.1 头像统一使用缓存组件

当前 `ForumUserAvatar` 接收 `ImageProvider`，页面多处传 `NetworkImage`，无 decode size 控制。

改造：

```dart
class ForumUserAvatar extends StatelessWidget {
  final String? imageUrl;
  final double size;
}
```

内部使用项目自己的 `CachedNetworkImage`，并传入：

- `CacheUtils.avatarCacheManager`
- `cacheWidth = size * devicePixelRatio`
- `cacheHeight = size * devicePixelRatio`

替换这些文件里的 `NetworkImage(...)`：

- `widgets/post_card.dart`
- `pages/post_detail/widgets/post_item.dart`
- `pages/post_detail/widgets/post_main.dart`
- `pages/subscription/view.dart`
- `pages/user/pages/topics_page.dart`
- `pages/user_group/view.dart`

## 任务 4.2 不要启动清空图片磁盘缓存

文件：`pages/main/view.dart`

移除启动时：

```dart
CacheUtils.deleteAllCacheImage();
```

改为：

- 只清 memory cache，不清 disk cache。
- 或者按设置页手动清理。
- 资源缩略图和内容图片保留磁盘缓存。

`CacheUtils` 增加：

```dart
clearImageMemoryCache()
clearExpiredImageDiskCacheIfNeeded()
clearAllImageDiskCacheByUserAction()
```

## 任务 4.3 拆分 `ContentView`

当前 `widgets/content_view.dart` 850 行，职责过重。

拆分为：

```text
lib/ui/content/content_view.dart
lib/ui/content/content_parser.dart
lib/ui/content/content_models.dart
lib/ui/content/content_cache.dart
lib/ui/content/content_blocks.dart
lib/ui/content/content_inline_image.dart
lib/ui/content/content_link_handler.dart
```

要求：

- parse service 做 in-flight dedupe。
- cache key 改 hash，不用完整 HTML 字符串作为 Map key。
- LRU 从 24 提高到 80，但限制总字符数或估算内存。
- 长帖 parse 排队，避免一次创建太多 compute isolate。
- loading skeleton 不要每个 ContentView 一个 AnimationController；复用现有 `SkeletonShimmer` 或静态 skeleton。

## 任务 4.4 列表卡片进一步轻量化

当前 `ForumDiscussionTile` 每条都是 `AppSurface`，如果外层已经是 section，会重复 surface/border。

新增：

```text
ui/forum/forum_discussion_row.dart
ui/forum/forum_discussion_section.dart
```

要求：

- `ForumDiscussionRow` 是轻量行，不创建外层 AppSurface。
- `ForumDiscussionSection` 外层统一一个 `AppSurface`，内部用 Divider。
- 首页、搜索结果、订阅、标签列表优先使用 section/row。

## 任务 4.5 精简 Obx 范围

高频页面检查：

- `pages/assets/view.dart`：6 个 Obx。
- `pages/post_detail/widgets/post_main.dart`：4 个 Obx。
- `pages/main/view.dart`：4 个 Obx。
- `pages/user/view.dart`：3 个 Obx。
- `pages/notification/view.dart`：3 个 Obx。

要求：

- Obx 只包需要响应的最小 Text/Icon/List，不包整个大 subtree。
- 列表 item 不直接依赖大 controller Obx。
- 能用 `ValueListenableBuilder` 或明确状态对象时不要扩大 GetX 响应范围。

## 任务 4.6 EasyRefresh 去 controller 化

当前 controller 里大量持有 `EasyRefreshController`，这让 UI 框架依赖进入业务层。

短期：保留功能，但抽出页面 mixin/helper。

长期：

- Controller 只暴露 `refresh()/loadMore()` 和状态。
- View 层持有 refresh controller。
- 统一为 `AppRefreshList`。

优先处理：

- `PostListController`
- `PostPageController`
- `SearchResultController`
- `UserController`
- `NotificationPageController`

验收：

- 快速滚动帖子列表无明显掉帧。
- 头像不再以原图尺寸解码。
- 重启 App 后内容图片不重新全量下载。
- 长帖进入不阻塞主线程。


---

<!-- 07_phase5_codebase_cleanup.md -->

# Phase 5：代码库减负与旧组件清理

目标：减少重复代码，让项目结构清晰。

## 任务 5.1 旧 widgets 分类

当前 `widgets/` 目录包含：

- 旧 UI：`post_card.dart`、`discussion_list_item_card.dart`、`post_card.dart`。
- 通用弹窗：`shared_dialog.dart`、`sheet_util.dart`。
- 内容渲染：`content_view.dart`。
- 图片：`cached_network_image.dart`、`image_view.dart`。
- skeleton：`shimmer_skeleton.dart`、`post_list_loading_skeleton.dart`、`two_column_loading_skeleton.dart`。
- refresh：`simple_easy_refresher.dart`。

处理规则：

- 真正通用的移动到 `ui/` 或 `ui/common/`。
- 旧桥接组件移动到 `ui/legacy/` 并加 deprecated 注释。
- 完成页面替换后删除不用的旧组件。

## 任务 5.2 页面拆分大文件

优先拆：

- `pages/assets/view.dart`
- `pages/editor/view.dart`
- `pages/main/view.dart`
- `pages/user/controller.dart`
- `pages/notification/controller.dart`
- `pages/user/pages/avatar_crop_dialog.dart`

要求：

- 每个文件尽量控制在 300 行以下。
- 页面 view 只组合 widget，不写复杂业务逻辑。
- controller 不持有 UI framework controller，逐步移出 EasyRefresh/ScrollController。

## 任务 5.3 API Guard 收口

当前有：

- `data/api/api_guard.dart`
- `data/api/flarum_request_guard.dart`
- `FlarumApiClient` 内部 cache/pending
- `RepoRequestCoalescer`

问题：缓存、pending、fallback 逻辑分散。

改造：

- `FlarumApiClient` 负责 transport、auth、URL、GET cache、pending dedupe。
- `RepoRequestCoalescer` 负责 repository 语义级合并。
- 删除或缩小 `ApiGuard`，不要再放一套 phased cache。
- `FlarumRequestGuard` 如果只是转发，应删除。

## 任务 5.4 日志与错误处理统一

- API 错误只在 repository 转成 `RepoError`。
- 页面不直接处理 `FlarumTransportError`。
- 取消请求不弹 snackbar。
- 422 validation 映射到字段错误。
- extension unavailable 映射到功能不可用状态。

## 任务 5.5 删除 transitional barrel 的误导性导出

`data/api/api.dart` 目前是 transitional barrel。等迁移完成后：

- 页面层不应 import `data/api/api.dart`。
- repository/service 可明确 import 具体类型。
- 如果保留 barrel，改名为 `flarum_api.dart`，不要叫旧 `api.dart`。

验收：

- `grep -R "package:star_forum/widgets/" lib/pages` 大幅下降，目标为 0 或仅剩明确 legacy。
- `grep -R "BaseBean\|BaseData\|BaseListBean" lib` 目标为 0。
- `grep -R "HttpUtils().get\|HttpUtils().post\|HttpUtils.setToken" lib/pages lib/data` 目标为 0，update helper 可例外。
- `ApiGuard` 不再承担第二套缓存。


---

<!-- 08_phase6_tests_and_acceptance.md -->

# Phase 6：测试、回归与性能验收

目标：确认优化不是“看起来整理了”，而是真的变快且功能不退化。

## 任务 6.1 Mapper fixture 测试

新增 fixtures：

```text
test/fixtures/forum_info_1x.json
test/fixtures/forum_info_2x.json
test/fixtures/discussion_list.json
test/fixtures/discussion_detail_without_posts.json
test/fixtures/posts_by_discussion.json
test/fixtures/user_detail.json
test/fixtures/notifications.json
```

覆盖：

- discussion detail 不包含 posts。
- posts 独立分页。
- avatarSrcset 可选。
- relationships 缺失不崩。
- included 缺失不崩。

## 任务 6.2 Repository 测试

用 fake api 或 mock client 覆盖：

- `PostRepository.getInitialPostPage()`。
- `DiscussionRepository.syncDiscussionPage()` 不重复请求已有 firstPost。
- stale cache 命中后能后台刷新。
- 扩展 endpoint 404 转 feature unavailable。

## 任务 6.3 UI 手工验收清单

必须检查：

- 首页首次打开。
- 首页下拉刷新。
- 首页连续刷新 3 次不会重复补取 first posts。
- 点进帖子详情，首帖和首屏回复尽快出现。
- 帖子详情切换排序。
- 点赞/取消点赞。
- 回复成功后本地插入新回复。
- 搜索。
- 用户页。
- 通知页。
- 资源页。
- 断网重启后首页缓存显示。

## 任务 6.4 性能验收指标

在同一慢服务器上对比 Phase 0 baseline：

- 首页缓存命中时：应小于 300ms 显示本地列表。
- 首页刷新：不阻塞已有列表。
- 帖子详情：首屏 posts 请求数量减少。
- 重启后内容图片不全量重新下载。
- 列表滚动无明显头像解码卡顿。

## 任务 6.5 输出最终报告

生成：

```text
docs/perf_after_optimization.md
```

包含：

- 修改文件列表。
- 删除文件列表。
- 请求链路变化。
- 数据模型变化。
- UI 性能变化。
- 剩余技术债。


---

<!-- agent_instruction.md -->

# 给 Agent 的一次性总指令

你要继续优化 StarForum 当前代码库。不要继续做视觉设计，不要大范围改业务功能。目标是：降低慢服务器下的请求等待、降低 CPU 和内存占用、简化数据层和旧 UI 代码，让项目进入可维护状态。

严格按阶段执行：

1. 先跑 `flutter analyze`，修明显错误，记录基线。
2. 优化请求链路，尤其是帖子详情首帖和首屏回复合并请求，讨论列表首帖摘要不要重复补取。
3. 收口数据模型，逐步删除旧 `BaseBean/BaseData/BaseListBean` 解析层。
4. 使用本地 DB cache，启用 first_posts 表，讨论列表 stale 数据优先显示。
5. 优化 UI 性能：头像统一缓存和解码尺寸，内容图片不启动清空，拆分 ContentView，列表行轻量化。
6. 清理旧 widgets、重复 guard/cache、过大的页面/controller 文件。
7. 补 fixture 和最小测试，输出最终性能对比报告。

硬性限制：

- 每阶段独立提交。
- 每阶段必须 `flutter analyze` 通过。
- 不要在页面层直接请求网络。
- 不要扩大 `widgets/` 旧目录依赖。
- 不要让 controller 继续增加 UI framework controller 依赖。
- 不要删除仍被页面引用的旧组件；先迁移引用，再删除。
- 不要为追求“清理”破坏 Flarum 1.x/2.x 兼容。

优先修的具体点：

- `widgets/cached_network_image.dart` 的 `EdgeInsetsGeometry.all(40)`。
- `pages/main/view.dart` 启动时清空图片磁盘缓存的问题。
- `ui/forum/forum_user_avatar.dart` 使用 `NetworkImage` 导致无 decode size 控制的问题。
- `data/repository/discussion_repo.dart` 的 `_saveFirstPostsAndExcerpts()` 无条件补取 firstPost 的问题。
- `pages/post_detail/controller.dart` 详情页请求拆太散的问题。
- `data/model/base.dart` 与新 mapper 并存的问题。
- `data/api/api_guard.dart` 与 `FlarumApiClient` 双重 cache/guard 的问题。

完成后输出：

- analyze 结果。
- 修改文件列表。
- 删除文件列表。
- 请求数量变化。
- 本地缓存策略说明。
- model/mapper 清理说明。
- UI 性能优化说明。
- 剩余问题。
