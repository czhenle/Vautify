import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../models/password_entry.dart';

class StorageService {
  final _storage = const FlutterSecureStorage();
  final String _activeUserKey = 'active_session_user';

  Future<String?> getActiveUser() async {
    return await _storage.read(key: _activeUserKey);
  }

  Future<void> logout() async {
    await _storage.delete(key: _activeUserKey);
  }

  Future<void> registerAccount(String username, String password) async {
    await _storage.write(key: '${username}_password', value: password);
  }

  Future<bool> verifyLogin(String username, String password) async {
    String? savedPassword = await _storage.read(key: '${username}_password');
    
    if (savedPassword != null && savedPassword == password) {
      await _storage.write(key: _activeUserKey, value: username);
      return true;
    }
    return false;
  }

  Future<Map<String, String?>> getMasterAccount() async {
    String? currentUser = await getActiveUser();
    if (currentUser == null) return {'username': null, 'password': null};
    
    String? pass = await _storage.read(key: '${currentUser}_password');
    return {'username': currentUser, 'password': pass};
  }

  Future<void> updateMasterPassword(String newPassword) async {
    String? currentUser = await getActiveUser();
    if (currentUser != null) {
      await _storage.write(key: '${currentUser}_password', value: newPassword);
    }
  }

  Future<void> saveProfileImagePath(String path) async {
    String? currentUser = await getActiveUser();
    await _storage.write(key: '${currentUser}_image', value: path);
  }

  Future<String?> getProfileImagePath() async {
    String? currentUser = await getActiveUser();
    return await _storage.read(key: '${currentUser}_image');
  }

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