# 🛡️ Vautify

Vautify is a modern, privacy-first password manager designed to keep your digital credentials secure on your own device. Built with Flutter, it combines military-grade AES-256 encryption with a highly polished, premium user interface. 

Unlike cloud-based alternatives, Vautify utilizes a zero-knowledge local architecture. Your data never leaves your device, and there are no subscription fees—just your passwords, locked safely behind your Master Password and layered security protocols.

### ✨ Key Features
* **AES-256 Encryption:** All vault entries (passwords, PINs, and challenge answers) are heavily encrypted before being saved to the local database.
* **Multi-Layered Security:** Protect your vault with a global Master Password, plus optional entry-specific PINs and custom Challenge Questions.
* **Zero-Knowledge Architecture:** 100% offline local storage using `flutter_secure_storage`. No servers, no tracking, no breaches.
* **Premium UI/UX:** Features a sleek dark-mode interface with ambient gradients, customized native page transitions (Android Zoom & iOS Slide), and buttery-smooth Hero animations.

### 🛠️ Tech Stack
* **Framework:** Flutter / Dart
* **Security:** `encrypt`, `crypto`
* **Storage:** `flutter_secure_storage`
* **Authentication:** `local_auth` 
