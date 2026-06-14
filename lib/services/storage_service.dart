import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';

/// StorageService acts as the local database for Vautify.
/// It uses `flutter_secure_storage` to ensure all data is protected by the 
/// device's native hardware encryption (Android Keystore / iOS Keychain)

class StorageService {
  // Creating a constant instance of the secure storage package
  final _storage = const FlutterSecureStorage();

  // This key acts as our "session token" to remember who is currently logged in
  final String _activeUserKey = 'active_session_user';

  // === SESSION & AUTHENTICATION MANAGEMENT ===

  /// Checks if a user is currently logged into the app.
  Future<String?> getActiveUser() async {
    return await _storage.read(key: _activeUserKey);
  }

  /// Destroys the active session token, locking the vault.
  Future<void> logout() async {
    await _storage.delete(key: _activeUserKey);
  }
  
  /// Saves a new user's master credentials. 
  /// The key is dynamically generated based on the username.
  Future<void> registerAccount(String username, String password) async {
    await _storage.write(key: '${username}_password', value: password);
  }

  /// Validates login credentials. If successful, it sets the active session.
  Future<bool> verifyLogin(String username, String password) async {
    String? savedPassword = await _storage.read(key: '${username}_password');
    
    if (savedPassword != null && savedPassword == password) {
      // Login successful: Save this username as the active session
      await _storage.write(key: _activeUserKey, value: username);
      return true;
    }
    return false; // Login failed
  }

  /// Retrieves the credentials of the currently logged-in user.
  /// This is critical for the EncryptionService to derive its AES key.
  Future<Map<String, String?>> getMasterAccount() async {
    String? currentUser = await getActiveUser();
    if (currentUser == null) return {'username': null, 'password': null};
    
    String? pass = await _storage.read(key: '${currentUser}_password');
    return {'username': currentUser, 'password': pass};
  }

  /// Updates the master password after a successful vault re-encryption.
  Future<void> updateMasterPassword(String newPassword) async {
    String? currentUser = await getActiveUser();
    if (currentUser != null) {
      await _storage.write(key: '${currentUser}_password', value: newPassword);
    }
  }


  // === PROFILE MEDIA MANAGEMENT ===

  /// Saves the local file path of the user's profile picture.
  Future<void> saveProfileImagePath(String path) async {
    String? currentUser = await getActiveUser();
    await _storage.write(key: '${currentUser}_image', value: path);
  }

  /// Retrieves the saved profile picture path for the active user.
  Future<String?> getProfileImagePath() async {
    String? currentUser = await getActiveUser();
    return await _storage.read(key: '${currentUser}_image');
  }

  // === VAULT (CRUD) OPERATIONS ===

  /// Reads the raw JSON string from secure storage and converts it back into a List of PasswordEntry Dart objects.
  Future<List<PasswordEntry>> getPasswords() async {
    String? currentUser = await getActiveUser();
    String? data = await _storage.read(key: '${currentUser}_vault');
    
    if (data == null || data.isEmpty) return [];

    List<dynamic> decodedList = json.decode(data);
    return decodedList.map((item) => PasswordEntry.fromJson(item)).toList();
  }

  Future<void> _savePasswords(List<PasswordEntry> passwords) async {
    String? currentUser = await getActiveUser();
    String encodedData = json.encode(passwords.map((e) => e.toJson()).toList());
    await _storage.write(key: '${currentUser}_vault', value: encodedData);
  }

  Future<void> addPassword(PasswordEntry newEntry) async {
    List<PasswordEntry> currentPasswords = await getPasswords();
    currentPasswords.add(newEntry);
    await _savePasswords(currentPasswords);
  }

  Future<void> updatePassword(PasswordEntry updatedEntry) async {
    List<PasswordEntry> currentPasswords = await getPasswords();
    int index = currentPasswords.indexWhere((entry) => entry.id == updatedEntry.id);   
    if (index != -1) {
      currentPasswords[index] = updatedEntry;
      await _savePasswords(currentPasswords);
    }
  }

  Future<void> deletePassword(String id) async {
    List<PasswordEntry> currentPasswords = await getPasswords();
    currentPasswords.removeWhere((entry) => entry.id == id); 
    await _savePasswords(currentPasswords);
  }
}