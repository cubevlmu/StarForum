# StarForum

<div align="center">
  <img src="./assets/images/logo.svg" alt="StarForum logo" width="112" height="112">
</div>

[Simplified Chinese](README.zh-CN.md) | English

StarForum is an open-source, cross-platform client built specifically for
Flarum communities. It gives forum members a focused native experience on
phones and desktops while preserving the structure, permissions, and extension
capabilities of each connected site.

Instead of rebuilding every screen from a fresh network request, StarForum
opens useful local data first and incrementally synchronizes what may have
changed. Its responsive interface keeps navigation and everyday actions
consistent across Android, iOS, Windows, macOS, and Linux.

## Snapshot

<!-- Replace this reserved path with the final screenshot asset. -->
<div align="center">
  <img src="./assets/images/snapshot.png" alt="StarForum application snapshot">
</div>

## Status

This repository is under active stabilization. Test releases are suitable for
feedback and compatibility testing, but migrations and feature behavior may
still change before the next stable release.

Supported targets:

- Android and iOS
- Windows, macOS, and Linux

Supported interface languages (initial translations assisted by ChatGPT):

- English
- Simplified Chinese
- Traditional Chinese (Taiwan)
- Japanese
- Korean
- Vietnamese

## Product Highlights

- **Local-first reading:** open cached discussions, profiles, and content
  immediately, then refresh only data that may have changed.
- **Adaptive interface:** use consistent navigation and controls across
  compact mobile layouts, desktop rails, and split-pane views.
- **Complete community workflows:** browse feeds, tags, search, notifications,
  profiles, groups, and assets; publish, reply, react, and manage content.
- **Resilient networking:** request coalescing, structured transport errors,
  bounded caches, and background hydration reduce unnecessary work.
- **User-controlled experience:** theme modes, dynamic accent colors,
  localization, cache controls, diagnostics, and data export remain accessible.

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
dart run flutter_launcher_icons
dart run build_runner build --delete-conflicting-outputs
```

Run the application:

```sh
flutter run -d android
flutter run -d windows
```

The project consumes its published shared UI package. During coordinated UI
development, the dependency can temporarily be changed to the sibling local
repository at `../../ClassTool/fui`.

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
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

Android App Bundle:

```sh
flutter build appbundle --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

Desktop builds:

```sh
flutter build windows --release --obfuscate --split-debug-info=./symbols
flutter build macos --release --obfuscate --split-debug-info=./symbols
flutter build linux --release --obfuscate --split-debug-info=./symbols
```

To lock a build to one forum and hide runtime site reconfiguration:

```sh
flutter build apk --release --dart-define=FIXED_API=https://forum.example.com
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
