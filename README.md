# StarForum

<a id="readme-top"></a>

[简体中文](README.zh-CN.md) | English

[![Flutter][flutter-shield]][flutter-url]
[![Dart][dart-shield]][dart-url]
[![License][license-shield]][license-url]

<br />
<div align="center">
  <img src="assets/images/logo.svg" alt="StarForum Logo" width="120" height="120">

  <h3 align="center">StarForum</h3>

  <p align="center">
    A cross-platform Flutter forum client for Flarum-based communities.
    <br />
    Focused on performance, desktop/mobile adaptation, local caching, and a polished Material 3 experience.
  </p>
</div>

## Table of Contents

- [About The Project](#about-the-project)
- [Built With](#built-with)
- [Features](#features)
- [Project Structure](#project-structure)
- [Getting Started](#getting-started)
- [Build Release](#build-release)
- [Notes](#notes)
- [Roadmap](#roadmap)
- [License](#license)

## About The Project

StarForum is a Flutter-based forum client designed for Flarum communities, with support for Android, iOS, Windows, macOS, and Linux.

The project focuses on:

- Responsive UI across mobile and desktop
- Material 3 based interaction and visual design
- Local caching and offline-friendly behavior
- Efficient large-list, image, and rich content rendering
- Maintainable architecture built around API, repository, and reusable widget layers

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Built With

- [Flutter](https://flutter.dev/)
- [Dart](https://dart.dev/)
- [GetX](https://pub.dev/packages/get)
- [Dio](https://pub.dev/packages/dio)
- [Drift / SQLite](https://pub.dev/packages/drift)
- [cached_network_image](https://pub.dev/packages/cached_network_image)
- [easy_refresh](https://pub.dev/packages/easy_refresh)
- [dynamic_color](https://pub.dev/packages/dynamic_color)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Features

- Cross-platform support for Android, iOS, Windows, macOS, and Linux
- Material 3 based UI with theme mode, color, language, and personalization settings
- Desktop split-view navigation with preserved detail-page state
- Silent first-load skeleton animations for major list and detail pages
- Flarum post detail rendering with optimized content parsing and image loading
- Notification center, search result pages, user profile pages, and theme/category browsing
- Local data persistence and cache management support
- Multi-language support with English, Simplified Chinese, and Chinese locale variants

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Project Structure

```text
lib/
├── app/        # App-level controllers and startup state
├── data/       # API, database, models, repository layer
├── di/         # Dependency injection setup
├── l10n/       # Generated and source localization files
├── pages/      # Screens and feature modules
├── utils/      # Shared utilities
├── widgets/    # Reusable widgets and loading components
└── main.dart   # App entry point
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Getting Started

### Prerequisites

- Flutter SDK stable channel
- Dart SDK bundled with Flutter
- Android Studio, VS Code, or another Flutter-capable IDE

Check the local environment:

```sh
flutter doctor
```

### Installation

1. Clone the repository.

   ```sh
   git clone <your-repo-url>
   cd forum
   ```

2. Install dependencies.

   ```sh
   flutter pub get
   ```

3. Generate localization files.

   ```sh
   flutter gen-l10n
   ```

4. Generate launcher icons if needed.

   ```sh
   dart run flutter_launcher_icons
   ```

5. Generate Drift-related code if schema or annotations changed.

   ```sh
   dart run build_runner build --delete-conflicting-outputs
   ```

### Run

```sh
flutter run
```

Examples:

```sh
flutter run -d android
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Build Release

### Android

```sh
flutter build appbundle --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### iOS

```sh
flutter build ios --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### Desktop

```sh
flutter build windows --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build macos --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build linux --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Notes

- Android 9+ blocks cleartext HTTP by default. Configure network security if your forum endpoint is not HTTPS.
- Some generated files depend on `flutter gen-l10n` and `build_runner`.
- Release builds use obfuscation and split debug symbols in the provided commands.
- To lock the app to a forum at build time, add `--dart-define=FIXED_API=https://forum.example.com`. When set, the app will prefer that address and hide runtime site reconfiguration.
- Large lists, rich text rendering, and image-heavy pages are optimized, but should still be tested in release mode on target devices.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Roadmap

- [x] Cross-platform Flarum client foundation
- [x] Material 3 settings, personalization, and theme support
- [x] Multi-language support
- [x] Desktop split-view detail navigation
- [x] Skeleton-based silent first-load experience
- [ ] Additional documentation for architecture and modules
- [ ] Automated testing coverage for more feature modules
- [ ] More complete release and contribution documentation

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## License

This project is licensed under **GNU General Public License v2.0**.

See [LICENSE](LICENSE) and [assets/licenses/GPL-2.0.txt](assets/licenses/GPL-2.0.txt) for details.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

[flutter-shield]: https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter&logoColor=white
[flutter-url]: https://flutter.dev/
[dart-shield]: https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart&logoColor=white
[dart-url]: https://dart.dev/
[m3-shield]: https://img.shields.io/badge/Material%203-Enabled-4E5BA6?style=for-the-badge
[license-shield]: https://img.shields.io/badge/License-GPLv2-blue?style=for-the-badge
[license-url]: ./LICENSE
