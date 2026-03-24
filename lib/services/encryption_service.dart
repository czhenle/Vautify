import 'dart:convert';
import 'dart:typed_data';
import 'package:encrypt/encrypt.dart';
import 'package:crypto/crypto.dart';

class EncryptionService {
  Key _generateKey(String masterPassword) {
    final bytes = utf8.encode(masterPassword);
    final digest = sha256.convert(bytes);
    return Key(Uint8List.fromList(digest.bytes));
  }

  String encryptData(String plainText, String masterPassword) {
    if (plainText.isEmpty) return plainText;
    final key = _generateKey(masterPassword);
    final iv = IV.fromSecureRandom(16); 
    final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
    final encrypted = encrypter.encrypt(plainText, iv: iv);
    return '${iv.base64}:${encrypted.base64}';
  }

  String decryptData(String encryptedText, String masterPassword) {
    if (encryptedText.isEmpty || !encryptedText.contains(':')) return encryptedText;

    try {
      final parts = encryptedText.split(':');
      final iv = IV.fromBase64(parts[0]);
      final cipherText = Encrypted.fromBase64(parts[1]);
      final key = _generateKey(masterPassword);
      final encrypter = Encrypter(AES(key, mode: AESMode.cbc));
      return encrypter.decrypt(cipherText, iv: iv);
    } catch (e) {
      return 'Error: Decryption Failed'; 
    }
  }
}