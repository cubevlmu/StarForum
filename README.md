# Forum

A cross-platform **Flutter** forum client application, targeting **Android, iOS, and Desktop (Windows / macOS / Linux)**.

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
│   └── repository/
├── pages/           # UI pages
│   ├── discussion/
│   ├── post_detail/
│   └── settings/
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
flutter build apk --release
# Recommended
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

### Desktop

```bash
flutter build windows --release
flutter build macos --release
flutter build linux --release
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

---

## 📄 License

This project is intended for learning and research purposes. Please define a license according to your needs.

---

Feel free to explore, modify, and optimize this project. Contributions and discussions are welcome ✨
