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
