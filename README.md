# Vautify 🛡️

A secure, offline-first password manager built with Flutter. Vautify stores and encrypts all your credentials locally on your device using AES-256 encryption — no cloud, no servers, no data leaving your phone.

---

## 📋 Table of Contents

- [🏪 About](#-about)
- [✨ Features](#-features)
- [🔐 Security Architecture](#-security-architecture)
- [📱 Screens](#-screens)
- [📁 Project Structure](#-project-structure)
- [🚀 Getting Started](#-getting-started)
- [🛠️ Technologies Used](#️-technologies-used)
- [📦 Dependencies](#-dependencies)
- [📜 License](#-license)

---

## 🏪 About

Vautify is a Flutter-based password vault application designed for users who want full control over their data. Every password entry is encrypted with AES-256 in CBC mode, derived from the user's master password using SHA-256. All encrypted data is stored natively on the device using Android Keystore and iOS Keychain — meaning your credentials never leave your device.

---

## ✨ Features

- 🔒 **AES-256 Encryption** — All vault entries are encrypted locally using the user's master password before being stored
- 🗄️ **Local-First Storage** — No cloud sync, no servers; data lives entirely on the device via `flutter_secure_storage`
- 👤 **Master Account System** — Register and log in with a username and master password that derives the encryption key
- ➕ **Vault CRUD** — Add, view, edit, and delete password entries (site name, username, password, PIN, security challenges)
- 🔍 **Search** — Filter vault entries by site name in real-time
- ☑️ **Bulk Selection & Delete** — Select multiple vault entries and delete them at once
- 🧑 **User Profile** — View and manage your account, including updating your master password (re-encrypts the entire vault)
- 🖼️ **Profile Picture** — Set a custom profile image using the device camera or gallery
- 💫 **Animated Splash Screen** — Animated logo with fade-in and scale-up effects on app launch
- 🌑 **Dark Theme UI** — Immersive dark design with teal accent glows throughout

---

## 🔐 Security Architecture

Vautify's security is built on two layers:

**Layer 1 — Device-Level (Storage)**
All data is stored using `flutter_secure_storage`, which uses Android Keystore on Android and iOS Keychain on iOS. This ensures that even if the device storage is accessed directly, the data is protected by hardware-backed encryption.

**Layer 2 — Application-Level (Encryption)**
Before any password entry is written to storage, the app encrypts it using `EncryptionService`:

1. The user's master password is hashed using **SHA-256** to produce a consistent 256-bit key
2. A cryptographically secure random **Initialization Vector (IV)** is generated for every encryption operation
3. The data is encrypted using **AES-256 in CBC mode**
4. The IV and ciphertext are stored together as `iv:ciphertext` (Base64 encoded) so decryption is always possible with the correct master password
5. If the wrong master password is provided, decryption fails gracefully and returns an error string rather than crashing the app

---

## 📱 Screens

| Screen | File | Description |
|--------|------|-------------|
| Splash | `splash_screen.dart` | Animated launch screen with logo fade-in and loading indicator |
| Landing | `landing_screen.dart` | Welcome gateway with Login and Register entry points |
| Auth | `auth_screen.dart` | Login screen with credential validation against secure storage |
| Register | `registration_screen.dart` | New account creation with password confirmation validation |
| Home | `home_screen.dart` | Main vault dashboard — list, search, select, and manage entries |
| Password Form | `password_form_screen.dart` | Add or edit a vault entry (site, username, password, PIN, challenges) |
| User Profile | `user_profile.dart` | Account management, master password update, profile picture, and logout |

---

## 📁 Project Structure

```
Vautify/
├── assets/
│   └── vautify_icon.png              # App launcher icon
├── lib/
│   ├── main.dart                     # App entry point and MaterialApp setup
│   ├── models/
│   │   └── password_entry.dart       # PasswordEntry data model with JSON serialisation
│   ├── screens/
│   │   ├── splash_screen.dart        # Animated splash/launch screen
│   │   ├── landing_screen.dart       # Welcome screen with login/register CTAs
│   │   ├── auth_screen.dart          # Login screen
│   │   ├── registration_screen.dart  # New user registration
│   │   ├── home_screen.dart          # Main vault list screen
│   │   ├── password_form_screen.dart # Add/edit password entry form
│   │   └── user_profile.dart         # User account and settings screen
│   └── services/
│       ├── encryption_service.dart   # AES-256 CBC encryption/decryption logic
│       └── storage_service.dart      # Secure local storage and session management
├── android/                          # Android platform configuration
├── ios/                              # iOS platform configuration
├── pubspec.yaml                      # Flutter dependencies and project config
└── analysis_options.yaml             # Dart lint rules
```

---

## 🚀 Getting Started

### 🔧 Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (Dart SDK `^3.11.1`)
- Android Studio or Xcode (for running on a device or emulator)
- A physical device or emulator running Android 5.0+ or iOS 12+

### 💻 Running Locally

1. Clone the repository:
   ```bash
   git clone -b Vautify https://github.com/czhenle/Vautify.git
   cd Vautify
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

3. Run on a connected device or emulator:
   ```bash
   flutter run
   ```

4. Build a release APK:
   ```bash
   flutter build apk --release
   ```

> **Note:** `flutter_secure_storage` requires a physical device or an emulator with Google Play Services enabled. Some features may not work on emulators.

---

## 🛠️ Technologies Used

| Technology | Purpose |
|------------|---------|
| Flutter | Cross-platform mobile UI framework |
| Dart | Application logic and state management |
| AES-256 CBC | Application-level encryption of vault entries |
| SHA-256 | Master password key derivation |
| Android Keystore / iOS Keychain | Device-level hardware-backed secure storage |

---

## 📦 Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_secure_storage` | ^9.0.0 | Encrypted local storage via Android Keystore / iOS Keychain |
| `encrypt` | ^5.0.3 | AES-256 CBC encryption and decryption |
| `crypto` | ^3.0.7 | SHA-256 hashing for master password key derivation |
| `local_auth` | ^2.1.0 | Biometric and device authentication support |
| `uuid` | ^4.3.0 | Unique ID generation for each vault entry |
| `image_picker` | ^1.2.1 | Profile picture selection from camera or gallery |
| `flutter_launcher_icons` | ^0.14.4 | Custom app launcher icon generation |

---

## 📜 License

This project is licensed under the MIT License. See the [LICENSE](LICENSE) file for details.