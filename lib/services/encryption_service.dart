import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

/// EncryptionService handles the localized AES-256 encryption and decryptionfor all sensitive vault data using the user's Master Password.

class EncryptionService {

  /// Generates a consistent 256-bit (32-byte) encryption key from the Master Password.
  /// It uses SHA-256 hashing to ensure the key is exactly the right length for AES-256,
  /// regardless of how long or short the user's actual password is.
  Key _generateKey(String masterPassword) {
    final bytes = utf8.encode(masterPassword);
    final digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }

  /// Encrypts plaintext using AES-256 in Cipher Block Chaining (CBC) mode.
  String encryptData(String plainText, String masterPassword) {
    if (plainText.isEmpty) return plainText;

    final key = _generateKey(masterPassword);

    // An Initialization Vector (IV) adds randomness to the encryption.
    // By using a secure random IV for every single encryption, identical 
    // passwords will yield completely different ciphertext.
    final iv = IV.fromSecureRandom(16); 


    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);

    // We must save the random IV alongside the ciphertext, otherwise we can 
    // never decrypt it later. We separate them with a colon (:).
    return '${iv.base64}:${encrypted.base64}';
  }

  /// Extracts the IV and decrypts the ciphertext back to readable data.
  String decryptData(String encryptedText, String masterPassword) {
    if (encryptedText.isEmpty || !encryptedText.contains(':')) return encryptedText;

    try {
      // Split the saved string back into the IV and the CipherText
      final parts = encryptedText.split(':');
      final iv = IV.fromBase64(parts[0]);
      final cipherText = Encrypted.fromBase64(parts[1]);

      final key = _generateKey(masterPassword);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));

      return encrypter.decrypt(cipherText, iv: iv);
    } catch (e) {
      // Catching the error prevents the app from crashing if a user 
      // types the wrong master password attempting to view a locked entry.
      return 'Error: Decryption Failed'; 
    }
  }
}