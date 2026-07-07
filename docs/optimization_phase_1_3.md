# StarForum Phase 1–3 源码改造记录

记录日期：2026-06-25

## 验证边界

本轮按要求未运行：

- `flutter analyze`
- `flutter test`
- Flutter 编译、启动、模拟器或真机验证

以下结论来自源码链路核对，不等同于运行时验收。

## Phase 1：请求链路

### 帖子详情

首屏改为优先请求：

```text
/api/posts?filter[discussion]=<id>&sort=number&page[offset]=0&page[limit]=11&include=user
```

该响应同时提供首帖和首屏回复。discussion detail 改为后台 metadata 请求，不再阻塞正文显示。

理论请求变化：

| 场景 | 改造前 | 改造后 |
| --- | ---: | ---: |
| 帖子详情首帖与首屏回复 | 2–3 个串行/分散请求 | 1 个首屏 posts 请求 |
| discussion metadata | 首屏阻塞 | 1 个后台请求 |
| App 启动进入主页面 | 同步等待 1 个 `/api` | 0 个阻塞网络请求 |

### 请求缓存与取消

- `FlarumApiClient` 改为 fresh/stale 双时限缓存。
- stale 命中立即返回旧数据，同时后台刷新。
- mutation 后仍执行路径级失效。
- 帖子详情、首页列表、搜索结果、用户页增加页面级 `CancelToken`。
- 取消请求映射到 `RepoErrorType.cancelled`，页面生命周期结束后不继续等待。

### 字段收缩

- discussion list 不 include posts 正文。
- 用户目录不再请求 email/bio。
- 用户详情仍保留 email/bio，避免破坏资料页。

## Phase 2：模型与 mapper

- JSON helper 移至 `lib/data/json/json_reader.dart`。
- Links 移至 `lib/data/api/flarum_links.dart`。
- 新 JSON:API mapper 不再 import `data/model/base.dart`。
- 新增 `BadgeMapper`、`UploadMapper`。
- `TagMapper` 负责标签树组装。
- 删除旧 `data/model/base.dart`。
- 删除业务 model 中未被调用的 `fromBaseData/fromBase/fromMapFast` 解析工厂。
- repository 排序枚举改名为 `PostPageSort`，避免与 API 层 `PostSort` 同名。

源码检索结果：

```text
BaseBean/BaseData/BaseListBean/PrivateBaseBean: 0
data/model/base.dart imports: 0
```

## Phase 3：DB 与 stale 数据

- `FirstPostsDao` 增加批量读取、批量写入、过期删除和清空。
- 摘要补全先读取 `first_posts`，七天内缓存可直接生成摘要。
- 只对真正缺失或过期的 firstPost 发批量请求。
- `watchDiscussionItems` 只监听当前可见 discussion IDs 对应的摘要，不再监听摘要全表。
- 首页 controller 启动后立即订阅 DB；本地有数据时停止显示 skeleton。
- 数据库升级不再 drop discussions、first_posts 和 excerpt_cache。
- App 启动不再清空内容图片缓存。

## 移动端修复

- navbar 切换时统一释放输入焦点。
- 搜索页取消自动 autofocus，避免进入主页面或切换 tab 时拉起键盘。
- 帖子详情、标签主页和标签详情补充移动端 SafeArea。
- 顶部图标按钮固定为 36×36，图标保持 20。
- 首页副标题固定显示截断后的纯文本站点介绍，不再显示登录用户名或用户 ID。
- forum info 写入本地缓存，首页可先显示上次站点标题和介绍，再后台刷新。

## 待运行时验收

- Android 状态栏、导航栏与 FAB 的实际间距。
- 键盘在返回、切换 navbar、重新打开搜索页后的行为。
- Flarum 1.x/2.x posts 首屏返回顺序和扩展事件帖兼容。
- stale-while-revalidate 在断网与慢站点下的表现。
- DB 从历史 schema 版本升级后的真实数据保留情况。
