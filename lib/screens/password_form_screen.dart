import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../models/password_entry.dart';
import '../services/storage_service.dart';
import '../services/encryption_service.dart';

/// Password Form Screen acts as a dual-purpose screen.
/// If 'existingEntry' is passed in, it acts as an "Edit" screen
/// If 'existingEntry' is null, it acts as an "Add New" screen

class PasswordFormScreen extends StatefulWidget {
  final PasswordEntry? existingEntry;
  const PasswordFormScreen({super.key, this.existingEntry});
  @override
  State<PasswordFormScreen> createState() => _PasswordFormScreenState();
}

class _PasswordFormScreenState extends State<PasswordFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final StorageService _storageService = StorageService();
  final EncryptionService _encryptionService = EncryptionService();

  // Static Text Controllers for the main form fields
  final TextEditingController _siteController = TextEditingController();
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _pinController = TextEditingController();

  // Dynamic list to hold controllers for however many challenge questions the user adds
  final List<Map<String, TextEditingController>> _challengeControllers = [];

  // State flags to determine if the user has successfully entered their master password
  bool _isPasswordUnlocked = false;
  bool _isPinUnlocked = false;

  @override
  void initState() {
    super.initState();
    // INITIALIZATION LOGIC: If we are editing an existing entry, populate the fields.
    if (widget.existingEntry != null) {
      _siteController.text = widget.existingEntry!.siteName;
      _userController.text = widget.existingEntry!.username;

      // Mask the sensitive data initially until the user unlocks it
      _passController.text = '********';
      _pinController.text = widget.existingEntry!.pin != null ? '********' : '';
      
      _isPasswordUnlocked = false;
      _isPinUnlocked = false;

      // Dynamically generate controllers for existing challenge questions
      for (var challenge in widget.existingEntry!.challenges) {
        _challengeControllers.add({
          'question': TextEditingController(text: challenge['question']),
          'answer': TextEditingController(text: challenge['answer']),
        });
      }
    } else {
      // If adding a new entry, fields start unlocked so the user can type
      _isPasswordUnlocked = true;
      _isPinUnlocked = true;
    }
  }

  //=== MEMORY MANAGEMENT ===
  @override
  void dispose() {
    // Dispose of all static controllers
    _siteController.dispose();
    _userController.dispose();
    _passController.dispose();
    _pinController.dispose();

    // Loop through and dispose of all dynamically created challenge controllers
    for (var controllers in _challengeControllers) {
      controllers['question']?.dispose();
      controllers['answer']?.dispose();
    }
    super.dispose();
  }
  
  // === DYNAMIC UI LOGIC ===
  void _addChallengeField() {
    setState(() {
      _challengeControllers.add({
        'question': TextEditingController(),
        'answer': TextEditingController(),
      });
    });
  }

  void _removeChallengeField(int index) {
    setState(() {
      // Must dispose of the specific controllers before removing them from the list
      _challengeControllers[index]['question']?.dispose();
      _challengeControllers[index]['answer']?.dispose();
      _challengeControllers.removeAt(index);
    });
  }

  // === SECURITY DIALOG LOGIC ===
  Future<void> _showUnlockDialog({required bool isPinField}) async {
    final TextEditingController masterPassController = TextEditingController();
    String errorMessage = '';

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              backgroundColor: Colors.grey[900],
              title: const Text('Security Verification', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Enter your Master Password to decrypt this data.', style: TextStyle(color: Colors.white70, fontSize: 14)),
                  const SizedBox(height: 15),
                  TextField(
                    controller: masterPassController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      hintText: 'Master Password',
                      hintStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.black,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
                    ),
                  ),
                  if (errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(errorMessage, style: const TextStyle(color: Colors.redAccent, fontSize: 12, fontWeight: FontWeight.bold)),
                  ]
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(backgroundColor: Colors.tealAccent, foregroundColor: Colors.black),
                  onPressed: () async {
                    Map<String, String?> account = await _storageService.getMasterAccount();

                    if (!context.mounted) return;
                    
                    if (masterPassController.text == account['password']) {
                      Navigator.pop(context);
                      setState(() {
                        if (isPinField) {
                          _isPinUnlocked = true;
                          _pinController.text = _encryptionService.decryptData(widget.existingEntry!.pin!, account['password']!);
                        } else {
                          _isPasswordUnlocked = true;
                          _passController.text = _encryptionService.decryptData(widget.existingEntry!.password, account['password']!);
                        }
                      });
                    } else {
                      setDialogState(() { errorMessage = 'Incorrect Master Password!'; });
                    }
                  },
                  child: const Text('Unlock', style: TextStyle(fontWeight: FontWeight.bold)),
                )
              ],
            );
          }
        );
      }
    );
  }

  // === SAVE / UPDATE LOGIC ===
  Future<void> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      Map<String, String?> account = await _storageService.getMasterAccount();
      String masterPass = account['password']!;

      String finalPasswordToSave;
      if (widget.existingEntry != null && !_isPasswordUnlocked) {
        finalPasswordToSave = widget.existingEntry!.password;
      } else {
        finalPasswordToSave = _encryptionService.encryptData(_passController.text, masterPass);
      }

      String? finalPinToSave;
      if (widget.existingEntry != null && !_isPinUnlocked && _pinController.text == '********') {
        finalPinToSave = widget.existingEntry!.pin;
      } else if (_pinController.text.isNotEmpty) {
        finalPinToSave = _encryptionService.encryptData(_pinController.text, masterPass);
      }

      List<Map<String, String>> finalChallenges = [];
      for (var controllers in _challengeControllers) {
        String q = controllers['question']!.text;
        String a = controllers['answer']!.text;
        if (q.isNotEmpty && a.isNotEmpty) {
          finalChallenges.add({'question': q, 'answer': a});
        }
      }

      final entry = PasswordEntry(
        id: widget.existingEntry?.id ?? const Uuid().v4(),
        siteName: _siteController.text,
        username: _userController.text,
        password: finalPasswordToSave,
        pin: finalPinToSave,
        challenges: finalChallenges,
      );

      if (widget.existingEntry == null) {
        await _storageService.addPassword(entry);
      } else {
        await _storageService.updatePassword(entry);
      }

      if (mounted) Navigator.of(context).pop();
    }
  }

  InputDecoration _buildInputDecoration(String label, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[900],
      suffixIcon: suffixIcon,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: Colors.tealAccent, width: 2),
      ),
    );
  }

  Widget _buildSecurityInfoCard() {
    if (widget.existingEntry == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black,
        border: Border.all(color: Colors.tealAccent.withValues(alpha:0.5)),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.shield_outlined, color: Colors.tealAccent, size: 20),
              SizedBox(width: 10),
              Text('AES-256 Encryption Active', style: TextStyle(color: Colors.tealAccent, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 10),
          const Text('Raw Database Ciphertext:', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const SizedBox(height: 5),
          Text(
            widget.existingEntry!.password,
            style: const TextStyle(color: Colors.white54, fontSize: 10, fontFamily: 'Courier'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.existingEntry != null;

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(isEditing ? 'Vault Entry' : 'Add New Password', style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.8),
                  radius: 0.8,
                  colors: [Colors.tealAccent.withValues(alpha:0.2), Colors.black.withValues(alpha:0.0)],
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Required Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),
                    
                    TextFormField(
                      controller: _siteController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Site Name (e.g., Google)'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a site name' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _userController,
                      style: const TextStyle(color: Colors.white),
                      decoration: _buildInputDecoration('Username or Email'),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a username or email' : null,
                    ),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _passController,
                      obscureText: !_isPasswordUnlocked, 
                      readOnly: !_isPasswordUnlocked, 
                      style: TextStyle(color: _isPasswordUnlocked ? Colors.white : Colors.tealAccent),
                      decoration: _buildInputDecoration(
                        'Password',
                        suffixIcon: (!_isPasswordUnlocked)
                          ? IconButton(
                              icon: const Icon(Icons.lock, color: Colors.tealAccent),
                              onPressed: () => _showUnlockDialog(isPinField: false),
                            )
                          : const Icon(Icons.lock_open, color: Colors.grey),
                      ),
                      validator: (value) => value == null || value.isEmpty ? 'Please enter a password' : null,
                    ),
                    
                    const SizedBox(height: 35),
                    const Text('Optional Features (Extra Security)', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                    const SizedBox(height: 15),

                    TextFormField(
                      controller: _pinController,
                      keyboardType: TextInputType.number,
                      obscureText: !_isPinUnlocked && widget.existingEntry?.pin != null,
                      readOnly: !_isPinUnlocked && widget.existingEntry?.pin != null,
                      style: TextStyle(color: _isPinUnlocked ? Colors.white : Colors.tealAccent),
                      decoration: _buildInputDecoration(
                        'PIN Number (Optional)',
                        suffixIcon: (!_isPinUnlocked && widget.existingEntry?.pin != null)
                          ? IconButton(
                              icon: const Icon(Icons.lock, color: Colors.tealAccent),
                              onPressed: () => _showUnlockDialog(isPinField: true),
                            )
                          : (widget.existingEntry?.pin != null ? const Icon(Icons.lock_open, color: Colors.grey) : null),
                      ),
                    ),
                    const SizedBox(height: 25),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Challenge Questions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                        TextButton.icon(
                          onPressed: _addChallengeField,
                          icon: const Icon(Icons.add, color: Colors.tealAccent, size: 18),
                          label: const Text('Add Question', style: TextStyle(color: Colors.tealAccent)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),

                    ..._challengeControllers.asMap().entries.map((entry) {
                      int index = entry.key;
                      var controllers = entry.value;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.grey[900],
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: Colors.white12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () => _removeChallengeField(index),
                              child: const Icon(Icons.close, color: Colors.redAccent, size: 20),
                            ),
                            TextField(
                              controller: controllers['question'],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Challenge Question (e.g.,First Pet)',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                            const Divider(color: Colors.white24),
                            TextField(
                              controller: controllers['answer'],
                              style: const TextStyle(color: Colors.white),
                              decoration: const InputDecoration(
                                hintText: 'Answer (e.g., Cat)',
                                hintStyle: TextStyle(color: Colors.grey, fontSize: 14),
                                border: InputBorder.none,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),

                    const SizedBox(height: 40),
                    ElevatedButton.icon(
                      onPressed: _saveForm,
                      icon: const Icon(Icons.save, color: Colors.black),
                      label: const Text('Save Entry', style: TextStyle(fontWeight: FontWeight.bold)),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        textStyle: const TextStyle(fontSize: 18),
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                    
                    _buildSecurityInfoCard(),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}