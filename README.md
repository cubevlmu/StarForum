# StarForum

[Simplified Chinese](README.zh-CN.md) | English

StarForum is a cross-platform Flutter client for Flarum communities. The 2.0
development line is currently in public testing and focuses on predictable
offline-first data access, responsive FinUI interfaces, and consistent behavior
across mobile and desktop.

## Status

This repository is under active stabilization. Test releases are suitable for
feedback and compatibility testing, but migrations and feature behavior may
still change before the next stable release.

Supported targets:

- Android and iOS
- Windows, macOS, and Linux

Supported interface languages:

- English
- Simplified Chinese
- Traditional Chinese (Taiwan)
- Japanese
- Korean
- Vietnamese

## Highlights

- Adaptive mobile, rail, and split-pane navigation built with FinUI
- Incremental Flarum synchronization backed by Drift and SQLite
- Cache-first screens with explicit freshness windows and background refresh
- Request coalescing, structured transport errors, and bounded content caches
- Discussion feeds, tags, search, notifications, profiles, user groups, and
  asset management
- Rich post rendering, reply composition, tag selection, reactions, and
  chronological reply ordering
- Theme mode, dynamic accent color, localization, and cache controls

## Architecture

```text
lib/
|-- app/             App shell, navigation, locale, and layout state
|-- data/
|   |-- api/         Flarum JSON:API transport, services, and mappers
|   |-- db/          Drift tables, DAOs, and cache mappers
|   |-- repository/  Cache policy, synchronization, and mutations
|   |-- session/     Authentication snapshots shared with presentation code
|   `-- perf/        Runtime and data-layer performance metrics
|-- di/              Dependency registration
|-- l10n/            ARB sources and generated localizations
|-- pages/           Feature controllers and views
|-- utils/           Focused application utilities
`-- widgets/         Shared domain presentation widgets
```

The presentation layer talks to repositories and session state, not directly to
the database. Repositories own API calls, cache writes, freshness decisions, and
fallback behavior. Domain models remain independent of Drift rows and JSON:API
resources.

## Development Setup

Requirements:

- Flutter stable with Dart 3.12 or newer
- Platform toolchains for the targets you intend to build
- A reachable Flarum installation for integration testing

Install dependencies and generate sources:

```sh
flutter pub get
flutter gen-l10n
dart run build_runner build --delete-conflicting-outputs
```

Run the application:

```sh
flutter run -d android
flutter run -d windows
```

The current stabilization branch resolves `fin_ui` from the sibling local
repository at `../../ClassTool/fui`. Before building on CI or another machine,
publish the matching FinUI version or replace the path with an accessible
dependency source.

## Quality Checks

```sh
dart format --output=none --set-exit-if-changed lib test benchmark
flutter analyze
flutter test
flutter test benchmark/data_layer_benchmark_test.dart
```

Benchmarks are diagnostic and should be compared on the same device and build
mode. See [benchmark/README.md](benchmark/README.md) for the workflow and
reported metrics.

## Test Builds

Android ARM64 APK:

```sh
flutter build apk --release --target-platform android-arm64 \
  --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

Android App Bundle:

```sh
flutter build appbundle --release \
  --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

Desktop builds:

```sh
flutter build windows --release --obfuscate --split-debug-info=./symbols
flutter build macos --release --obfuscate --split-debug-info=./symbols
flutter build linux --release --obfuscate --split-debug-info=./symbols
```

To lock a build to one forum and hide runtime site reconfiguration:

```sh
flutter build apk --release \
  --dart-define=FIXED_API=https://forum.example.com
```

Keep the generated `symbols/` directory for crash symbolication. Do not commit
generated Drift `*.g.dart` files; regenerate them after schema changes.

## Compatibility Notes

Flarum extensions can add fields, permissions, and endpoints. StarForum treats
optional extension features as capabilities and falls back when an endpoint is
unavailable. Reports should include the app version, platform, Flarum version,
enabled extensions, and relevant logs from the developer page.

The developer tile is visible in debug builds. In other builds, tap the version
label on the About page six times to open the diagnostic page.

## License

StarForum is licensed under the GNU General Public License v2.0. See
[LICENSE](LICENSE) and [assets/licenses/GPL-2.0.txt](assets/licenses/GPL-2.0.txt).
