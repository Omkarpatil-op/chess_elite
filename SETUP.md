# Setup & Local Development Guide

This guide assists engineers in setting up and contributing to Chess Elite with a seamless, error-free developer experience.

---

## 🛠️ Required Tools

* **Flutter SDK**: 3.24.0 or newer ([Install Flutter](https://docs.flutter.dev/get-started/install))
* **Dart SDK**: 3.5.0 or newer
* **Java Development Kit (JDK)**: OpenJDK 17
* **Android SDK**: API 34+ (Android 14)
* **Xcode**: 15+ (for iOS development on macOS)

---

## 🚀 Step-by-Step Setup

### 1. Clone & Fetch Dependencies
```bash
git clone https://github.com/your-org/chess_elite.git
cd chess_elite
flutter pub get
```

### 2. Validate Tooling & Environment
```bash
flutter doctor
```

### 3. Run Static Code Analyzer
```bash
flutter analyze
```

### 4. Execute Test Suite
```bash
flutter test
```

### 5. Launch Locally
```bash
# Run on connected Android or iOS device
flutter run

# Run on Chrome Web
flutter run -d chrome

# Run on Windows Desktop
flutter run -d windows
```
