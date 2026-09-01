# Deployment & Store Release Guide

Instructions for producing store-ready release builds for Google Play Store and Apple App Store.

---

## 🤖 Google Play Store (Android Release)

### 1. App Signing Setup
Generate a production release keystore (never commit this keystore to version control):

```bash
keytool -genkey -v -keystore android/upload-keystore.jks -keyalg RSA -keysize 2048 -validity 10000 -alias upload
```

Create `android/key.properties`:
```properties
storePassword=<STORE_PASSWORD>
keyPassword=<KEY_PASSWORD>
keyAlias=upload
storeFile=../upload-keystore.jks
```

### 2. Build Android App Bundle (AAB)
```bash
flutter build appbundle --release --dart-define=ENVIRONMENT=production
```
Output artifact located at: `build/app/outputs/bundle/release/app-release.aab`.

---

## 🍏 Apple App Store (iOS Release)

### 1. Configure Certificates & Provisioning Profiles
* Open `ios/Runner.xcworkspace` in Xcode.
* Select the **Runner** target -> **Signing & Capabilities**.
* Assign your Apple Developer Team and Provisioning Profile.

### 2. Build iOS IPA Archive
```bash
flutter build ipa --release --dart-define=ENVIRONMENT=production
```
Output archive located at: `build/ios/archive/Runner.xcarchive`.

Upload to App Store Connect via Xcode Organizer or `xcrun altool`.
