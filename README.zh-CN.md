# StarForum

<div align="center">
  <img src="./assets/images/logo.svg" alt="StarForum Logo" width="112" height="112">
</div>

简体中文 | [English](README.md)

StarForum 是面向 Flarum 社区的跨平台 Flutter 客户端。当前 2.0 开发线处于公开测试阶段，主要目标是提供行为可预测的本地优先数据访问、统一的 FinUI 界面，以及一致的移动端和桌面端体验。

## 应用截图

<!-- 将最终应用截图放在 assets/images/snapshot.png。 -->
<div align="center">
  <img src="./assets/images/snapshot.png" alt="StarForum 应用截图">
</div>

## 当前状态

项目正在进行稳定性收尾。测试版本适合功能反馈和兼容性验证，但在下一个稳定版本发布前，数据库迁移和部分功能行为仍可能调整。

支持的平台：

- Android、iOS
- Windows、macOS、Linux

支持的界面语言（初始翻译由 ChatGPT 辅助完成）：

- 英语
- 简体中文
- 繁体中文（台湾）
- 日语
- 韩语
- 越南语

## 主要功能

- 基于 FinUI 的移动端、侧边栏和分栏自适应导航
- 基于 Drift 与 SQLite 的 Flarum 增量同步
- 缓存优先页面、明确的数据有效期和后台刷新
- 请求合并、结构化网络错误和有界内容缓存
- 讨论信息流、标签、搜索、通知、用户资料、用户组和资源管理
- 富文本帖子、回复编辑、标签选择、点赞和评论时间排序
- 主题模式、动态强调色、多语言和缓存管理

## 工程结构

```text
lib/
|-- app/             应用外壳、导航、语言和布局状态
|-- data/
|   |-- api/         Flarum JSON:API 传输、服务与映射
|   |-- db/          Drift 表、DAO 与缓存映射
|   |-- repository/  缓存策略、同步与数据修改
|   |-- session/     提供给表现层的认证状态快照
|   `-- perf/        运行时与数据层性能指标
|-- di/              依赖注册
|-- l10n/            ARB 源文件和生成的多语言代码
|-- pages/           功能控制器与页面
|-- utils/           单一职责工具
`-- widgets/         共享领域展示组件
```

页面只与 Repository 和 SessionState 交互，不直接访问数据库。Repository 负责 API 调用、缓存写入、有效期判断和失败回退；领域模型不依赖 Drift 数据行或 JSON:API Resource。

## 开发环境

需要 Flutter stable、Dart 3.12 或更高版本，以及目标平台对应的构建工具链。

```sh
flutter pub get
flutter gen-l10n
dart run flutter_launcher_icons
dart run build_runner build --delete-conflicting-outputs
```

运行示例：

```sh
flutter run -d android
flutter run -d windows
```

项目默认使用 Pub 发布的 `fin_ui`。联调 FinUI 源码时，可以临时将依赖切换到同级本地仓库 `../../ClassTool/fui`。

## 质量检查

```sh
dart format --output=none --set-exit-if-changed lib test benchmark
flutter analyze
flutter test
flutter test benchmark/data_layer_benchmark_test.dart
```

Benchmark 只适合在相同设备和构建模式下比较。具体流程见 [benchmark/README.md](benchmark/README.md)。

## 测试构建

Android ARM64 APK：

```sh
flutter build apk --release --target-platform android-arm64 \
  --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

Android App Bundle：

```sh
flutter build appbundle --release \
  --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

固定论坛地址并隐藏运行时重新配置入口：

```sh
flutter build apk --release \
  --dart-define=FIXED_API=https://forum.example.com
```

请保留生成的 `symbols/` 用于崩溃符号化。Drift 的 `*.g.dart` 不提交到仓库，数据库结构变化后需要重新生成。

## 兼容性说明

Flarum 扩展可能增加字段、权限和接口。StarForum 会将可选扩展作为能力检测，并在接口不可用时回退。提交问题时请附带应用版本、平台、Flarum 版本、启用的扩展，以及开发者页面导出的相关日志。

开发者入口 Tile 只在 Debug 构建中显示。其他构建可以在“关于”页面连续点击版本号六次打开诊断页面。

## 许可证

StarForum 使用 GNU General Public License v2.0，详见 [LICENSE](LICENSE) 和 [assets/licenses/GPL-2.0.txt](assets/licenses/GPL-2.0.txt)。
