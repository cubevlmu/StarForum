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
