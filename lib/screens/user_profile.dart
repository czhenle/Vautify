import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/storage_service.dart';
import '../services/encryption_service.dart';
import '../models/password_entry.dart';
import 'landing_screen.dart';

class UserProfile extends StatefulWidget {
  const UserProfile({super.key});

  @override
  State<UserProfile> createState() => _UserProfileState();
}

class _UserProfileState extends State<UserProfile> {
  final StorageService _storageService = StorageService();
  final EncryptionService _encryptionService = EncryptionService();
  final ImagePicker _picker = ImagePicker();

  String _username = 'Loading...';
  int _passwordCount = 0;
  String? _imagePath;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    Map<String, String?> account = await _storageService.getMasterAccount();
    final passwords = await _storageService.getPasswords();
    String? savedImage = await _storageService.getProfileImagePath();

    setState(() {
      _username = account['username'] ?? 'User';
      _passwordCount = passwords.length;
      _imagePath = savedImage;
    });
  }

  Future<void> _pickImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imagePath = image.path;
      });
      await _storageService.saveProfileImagePath(image.path);
    }
  }

  void _showChangePasswordDialog() {
    final TextEditingController oldPassController = TextEditingController();
    final TextEditingController newPassController = TextEditingController();
    String errorMessage = '';
    bool isReEncrypting = false;
    
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Change Master Password', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: isReEncrypting 
              ? const Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(color: Colors.tealAccent),
                    SizedBox(height: 20),
                    Text('Re-encrypting Vault...\nPlease wait.', textAlign: TextAlign.center, style: TextStyle(color: Colors.tealAccent)),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: oldPassController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter CURRENT master password',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    const SizedBox(height: 15),
                    
                    TextField(
                      controller: newPassController,
                      obscureText: true,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Enter NEW master password',
                        hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                        filled: true,
                        fillColor: Colors.black,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                      ),
                    ),
                    
                    if (errorMessage.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      Text(errorMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                    ]
                  ],
                ),
              actions: isReEncrypting 
              ? []
              : [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
                    onPressed: () async {
                      Map<String, String?> account = await _storageService.getMasterAccount();
                      
                      if (oldPassController.text != account['password']) {
                        setDialogState(() { errorMessage = 'Current password is incorrect!'; });
                        return;
                      }
                      if (newPassController.text.isEmpty) {
                        setDialogState(() { errorMessage = 'New password cannot be empty!'; });
                        return;
                      }

                      setDialogState(() { isReEncrypting = true; errorMessage = ''; });

                      List<PasswordEntry> allEntries = await _storageService.getPasswords();

                      for (var entry in allEntries) {
                        String decryptedPass = _encryptionService.decryptData(entry.password, oldPassController.text);
                        String reEncryptedPass = _encryptionService.encryptData(decryptedPass, newPassController.text);

                        String? reEncryptedPin;
                        if (entry.pin != null && entry.pin!.isNotEmpty) {
                          String decryptedPin = _encryptionService.decryptData(entry.pin!, oldPassController.text);
                          reEncryptedPin = _encryptionService.encryptData(decryptedPin, newPassController.text);
                        }

                        PasswordEntry updatedEntry = PasswordEntry(
                          id: entry.id,
                          siteName: entry.siteName,
                          username: entry.username,
                          password: reEncryptedPass,
                          pin: reEncryptedPin,
                          challenges: entry.challenges,
                        );
                        await _storageService.updatePassword(updatedEntry);
                      }

                      await _storageService.updateMasterPassword(newPassController.text);

                      if (context.mounted) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Vault successfully re-encrypted with new key!'), backgroundColor: Colors.teal),
                        );
                      }
                    },
                    child: const Text('Update Vault', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
            );
          }
        );
      },
    );
  }

  Future<void> _logout() async {
    await _storageService.logout(); 

    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const LandingScreen()),
        (Route<dynamic> route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Profile', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.topCenter,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.5),
                  radius: 0.8,
                  colors: [Colors.tealAccent.withValues(alpha:0.2), Colors.black.withValues(alpha:0.0)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
              child: Column(
                children: [
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[900],
                          backgroundImage: _imagePath != null ? FileImage(File(_imagePath!)) : null,
                          child: _imagePath == null ? const Icon(Icons.person, size: 60, color: Colors.tealAccent) : null,
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: const BoxDecoration(color: Colors.tealAccent, shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.black, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(_username, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 5),
                  Text('$_passwordCount Entries Secured', style: const TextStyle(fontSize: 16, color: Colors.tealAccent, fontWeight: FontWeight.w500)),
                  const SizedBox(height: 40),

                  _buildMenuCard(
                    icon: Icons.lock_reset,
                    title: 'Change Master Password',
                    subtitle: 'Requires vault re-encryption',
                    onTap: _showChangePasswordDialog,
                  ),
                  const SizedBox(height: 15),
                  
                  _buildMenuCard(
                    icon: Icons.badge,
                    title: 'Developer Info',
                    subtitle: 'Tan Cheng Lock • ID: 2205118',
                    onTap: () {}, 
                  ),
                  const SizedBox(height: 15),

                  _buildMenuCard(
                    icon: Icons.logout,
                    title: 'Logout',
                    subtitle: 'Securely lock the vault and exit',
                    iconColor: Colors.redAccent,
                    onTap: _logout,
                  ),
                  const SizedBox(height: 100), 
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon, required String title, required String subtitle, required VoidCallback onTap, Color iconColor = Colors.tealAccent,
  }) {
    return Card(
      color: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: iconColor),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle, style: const TextStyle(color: Colors.white54)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white38, size: 16),
        onTap: onTap,
      ),
    );
  }
}