# StarForum

<a id="readme-top"></a>

简体中文 | [English](README.md)

[![Flutter][flutter-shield]][flutter-url]
[![Dart][dart-shield]][dart-url]
[![License][license-shield]][license-url]

<br />
<div align="center">
  <img src="assets/images/logo.svg" alt="StarForum Logo" width="120" height="120">

  <h3 align="center">StarForum</h3>

  <p align="center">
    一个面向 Flarum 社区的跨平台 Flutter 论坛客户端。
    <br />
    重点关注性能、桌面与移动端适配、本地缓存，以及更完整的 Material 3 使用体验。
  </p>
</div>

## 目录

- [项目简介](#项目简介)
- [技术栈](#技术栈)
- [功能特性](#功能特性)
- [项目结构](#项目结构)
- [快速开始](#快速开始)
- [构建发布版](#构建发布版)
- [说明](#说明)
- [路线图](#路线图)
- [许可证](#许可证)

## 项目简介

StarForum 是一个基于 Flutter 构建的 Flarum 论坛客户端，支持 Android、iOS、Windows、macOS 和 Linux。

项目目前主要关注：

- 移动端与桌面端的一致性体验
- 基于 Material 3 的界面和交互设计
- 本地缓存与更友好的离线使用体验
- 大列表、图片与富文本内容的性能优化
- 以 API、Repository、可复用组件为核心的可维护架构

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 技术栈

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [GetX](https://pub.dev/packages/get)
- [Dio](https://pub.dev/packages/dio)
- [Drift / SQLite](https://pub.dev/packages/drift)
- [cached_network_image](https://pub.dev/packages/cached_network_image)
- [easy_refresh](https://pub.dev/packages/easy_refresh)
- [dynamic_color](https://pub.dev/packages/dynamic_color)

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 功能特性

- 支持 Android、iOS、Windows、macOS、Linux 的跨平台运行
- 基于 Material 3 的主题、颜色、语言和个性化设置
- 桌面端分栏详情导航，并支持详情页状态保活
- 多个页面接入静默首屏加载与骨架动画
- 帖子详情页支持优化后的正文解析、图片加载与评论交互
- 支持通知页、搜索结果页、用户主页、主题分类浏览等主要功能
- 支持本地数据缓存与缓存管理
- 支持英文、简体中文以及中文相关语言环境

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 项目结构

```text
lib/
├── app/        # 应用级控制器与启动状态
├── data/       # API、数据库、数据模型、仓储层
├── di/         # 依赖注入配置
├── l10n/       # 国际化源文件与生成文件
├── pages/      # 页面与功能模块
├── utils/      # 通用工具
├── widgets/    # 可复用组件与加载动画组件
└── main.dart   # 应用入口
```

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 快速开始

### 环境要求

- Flutter SDK，建议使用稳定版
- Flutter 自带 Dart SDK
- Android Studio、VS Code 或其他 Flutter 开发环境

检查本地环境：

```sh
flutter doctor
```

### 安装

1. 克隆仓库

   ```sh
   git clone <your-repo-url>
   cd forum
   ```

2. 安装依赖

   ```sh
   flutter pub get
   ```

3. 生成国际化文件

   ```sh
   flutter gen-l10n
   ```

4. 如有需要，生成应用图标

   ```sh
   dart run flutter_launcher_icons
   ```

5. 如果数据库结构或注解有改动，重新生成相关代码

   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```

### 运行

```sh
flutter run
```

示例：

```sh
flutter run -d android
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run
```

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 构建发布版

### Android

```sh
flutter build appbundle --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### iOS

```sh
flutter build ios --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### 桌面端

```sh
flutter build windows --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build macos --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build linux --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 说明

- Android 9 及以上默认会限制明文 HTTP，请在论坛接口未启用 HTTPS 时额外配置网络安全策略。
- 一部分生成文件依赖 `flutter gen-l10n` 和 `build_runner`。
- 上面给出的发布命令默认启用了混淆与符号分离。
- 如果要在编译时固定论坛地址，可追加 `--dart-define=FIXED_API=https://forum.example.com`。设置后应用会优先使用这个地址，并隐藏运行时“重新配置站点”入口。
- 大列表、富文本和图片较多的页面，建议优先在 release 模式下测试真实性能。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 路线图

- [x] 跨平台 Flarum 客户端基础能力
- [x] Material 3 设置页、个性化和主题支持
- [x] 多语言支持
- [x] 桌面端分栏详情导航
- [x] 静默首屏骨架加载体验
- [ ] 补充更完整的架构和模块文档
- [ ] 增加更多功能模块的自动化测试覆盖
- [ ] 完善发布与贡献说明

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

## 许可证

本项目使用 **GNU General Public License v2.0**。

详见 [LICENSE](LICENSE) 与 [assets/licenses/GPL-2.0.txt](assets/licenses/GPL-2.0.txt)。

<p align="right">(<a href="#readme-top">返回顶部</a>)</p>

[flutter-shield]: https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white
[flutter-url]: https://flutter.dev/
[dart-shield]: https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white
[dart-url]: https://dart.dev/
[m3-shield]: https://img.shields.io/badge/Material%203-Enabled-4E5BA6?style=for-the-badge
[license-shield]: https://img.shields.io/badge/License-GPLv2-blue?style=for-the-badge
[license-url]: ./LICENSE
