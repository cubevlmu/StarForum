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
