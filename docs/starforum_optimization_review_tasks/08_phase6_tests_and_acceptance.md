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
