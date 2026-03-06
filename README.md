# StarForum

A cross-platform **Flutter** flarum forum client application, targeting **Android, iOS, and Desktop (Windows / macOS / Linux)**.

This project focuses on:

* Performance and memory efficiency
* Local caching and offline-friendly experience
* A clean, maintainable project architecture

---

## ✨ Features

* 📱 Cross-platform support (Android / iOS / Windows / macOS / Linux)
* 🚀 High-performance list rendering with pagination and lazy loading
* 🧠 Local caching (database + in-memory cache)
* 🖼️ Image caching with memory control
* 📝 Rich text / HTML content rendering
* 🔌 Modular API & Repository-based architecture

---

## 🧰 Tech Stack

* **Flutter** (Dart)
* **Dio** – HTTP networking
* **Drift / SQLite** – local persistence
* **Flutter HTML / Custom HTML parsing** – post content rendering
* **Provider / Riverpod / Custom state management** (depending on implementation)

---

## 📂 Project Structure (Example)

```text
lib/
├── data/            # Data layer (API / DB / Models)
│   ├── api/
│   ├── dao/
│   ├── model/
│   ├── repository/
│   └── ...
├── pages/           # UI pages
│   ├── discussion/
│   ├── post_detail/
│   ├── settings/
│   └── ...
├── widgets/         # Reusable UI components
├── utils/           # Utilities (network / HTML / cache, etc.)
└── main.dart        # Application entry point
```

---

## 🚀 Getting Started

### 1️⃣ Requirements

* Flutter SDK (stable channel recommended)
* Dart SDK (bundled with Flutter)
* Android Studio or VS Code

Verify your environment:

```bash
flutter doctor
```

---

### 2️⃣ Install Dependencies

```bash
flutter pub get
flutter gen-l10n
dart run flutter_launcher_icons
dart run build_runner build --delete-conflicting-outputs
```

---

### 3️⃣ Run the App

#### Android / iOS

```bash
flutter run
```

#### Windows

```bash
flutter run -d windows
```

#### macOS

```bash
flutter run -d macos
```

#### Linux

```bash
flutter run -d linux
```

---

## 🏗️ Build Release Versions

### Android

```bash
# Play Store (smaller download size per device)
flutter build appbundle --release --obfuscate --split-debug-info=./symbols --tree-shake-icons

# Sideload APK (arm64 only)
flutter build apk --release --target-platform android-arm64 --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### iOS

```bash
flutter build ios --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

### Desktop

```bash
flutter build windows --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build macos --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
flutter build linux --release --obfuscate --split-debug-info=./symbols --tree-shake-icons
```

---

## ⚠️ Notes

* Android 9+ blocks cleartext HTTP by default. If your API uses HTTP, configure `networkSecurityConfig`.
* Release builds enable R8 / ProGuard. Make sure to keep required model and reflection-related classes.
* Pages with large lists or images should be carefully optimized to avoid excessive memory usage.

---

## 🧠 Performance & Memory Optimization

* All lists use `ListView.builder` for lazy rendering
* Image cache size is explicitly limited via `ImageCache`
* Streams, controllers, and subscriptions are properly disposed
* HTML content is parsed lazily and widgets are not globally cached

---

## 📖 References

* Flutter Documentation: [https://docs.flutter.dev/](https://docs.flutter.dev/)
* Dart Language: [https://dart.dev/](https://dart.dev/)
* Dio: [https://pub.dev/packages/dio](https://pub.dev/packages/dio)
* BiliYou: [https://github.com/lucinhu/bili_you](https://github.com/lucinhu/bili_you)

---

## 📄 License

This project is under GNU GENERAL PUBLIC LICENSE V2.

---

Feel free to explore, modify, and optimize this project. Contributions and discussions are welcome ✨
