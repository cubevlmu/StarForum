# StarForum 性能基线

记录日期：2026-06-25

## 验证状态

本阶段按当前执行要求仅完成源码检查和修改，未运行以下命令：

- `flutter analyze`
- `flutter test`
- Flutter 编译、启动或真机运行

因此本文不把 IDE 状态或静态阅读结果表述为编译、运行时验收结论。涉及实际耗时的项目需在后续允许运行后补测。

## 工具链与 SDK 约束

- Flutter SDK：3.44.0 stable
- Dart SDK：3.12.0
- `pubspec.yaml` Dart 约束：`>=3.12.0 <4.0.0`
- `pubspec.lock` Flutter 约束：`>=3.44.0`

版本来自本机 Flutter SDK 缓存元数据和项目配置文件，未调用 Flutter 命令。

## 源码规模

- `lib/` 下 Dart 文件：210 个
- 排除 `*.g.dart` 和生成的本地化文件后：203 个
- 排除上述生成文件后的 Dart 行数：30762 行
- `package:star_forum/widgets/` 引用：61 处，分布于 32 个文件
- `BaseBean/BaseData/BaseListBean/PrivateBaseBean` 引用：72 处
- 页面、`widgets/`、`ui/` 中直接调用 `HttpUtils().get/post/patch/delete` 或 `HttpUtils.setToken`：0 处

## 当前大文件

| 文件 | 行数 |
| --- | ---: |
| `lib/widgets/content_view.dart` | 850 |
| `lib/pages/assets/view.dart` | 627 |
| `lib/pages/editor/view.dart` | 605 |
| `lib/pages/main/view.dart` | 588 |
| `lib/pages/user/pages/avatar_crop_dialog.dart` | 578 |
| `lib/pages/user/controller.dart` | 574 |
| `lib/pages/notification/controller.dart` | 498 |
| `lib/pages/user/pages/info_widgets.dart` | 486 |
| `lib/data/api/api_guard.dart` | 481 |
| `lib/pages/user_group/view.dart` | 464 |
| `lib/pages/notification/widgets/notify_card.dart` | 463 |
| `lib/data/repository/discussion_repo.dart` | 448 |

## 请求与缓存静态基线

- 讨论列表同步后，`DiscussionRepo._saveFirstPostsAndExcerpts()` 会为缺失首帖的讨论额外批量请求帖子。
- `FirstPostsDao` 已存在，但当前摘要补取流程没有先读取该表。
- 帖子详情当前可能分别请求 discussion metadata、首帖 fallback 和 replies page，慢站点下首屏存在 2 至 3 段等待。
- `FlarumApiClient` 使用短时内存缓存，但没有 stale-while-revalidate。
- `MainPage` 启动后仍调用 `CacheUtils.deleteAllCacheImage()`。
- 多处用户头像仍直接使用 `NetworkImage`，没有统一解码尺寸。

以上属于 Phase 1 及后续阶段范围，本阶段只记录，不提前扩大修改。

## 性能日志基线

已新增：

- `lib/data/perf/perf_config.dart`
- `lib/data/perf/perf_log.dart`

默认策略：

- debug 构建默认开启。
- release 构建默认关闭。
- 支持输出 `requestMs`、`parseMs`、`dbMs` 和 render hint。
- `FlarumApiClient` 已记录新请求链路的网络耗时。
- `ApiGuard` 已记录旧分阶段请求链路的 request/parse/total 耗时。

## 待补运行时耗时

| 操作 | 当前结果 |
| --- | --- |
| 冷启动到首页 | 未测，当前禁止运行 |
| 首页首次加载讨论列表 | 未测，当前禁止运行 |
| 下拉刷新 | 未测，当前禁止运行 |
| 点进帖子详情到首帖显示 | 未测，当前禁止运行 |
| 帖子详情首屏回复显示 | 未测，当前禁止运行 |
| 用户页打开 | 未测，当前禁止运行 |
| 通知页打开 | 未测，当前禁止运行 |

后续运行时测量应同时记录站点版本、网络环境、冷/热缓存状态和至少三次样本，避免只用单次主观感知作结论。

## Phase 0 明显风险处理

- 已将 `EdgeInsetsGeometry.all(40)` 改为明确可用的 `const EdgeInsets.all(40)`。
- enum dot shorthand 保留。当前 Dart 3.12 SDK 约束支持该语法，回退为完整枚举名没有兼容收益。
- analyze、test 和运行时数据未执行，需在允许验证后补齐。
