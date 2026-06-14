import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'auth_screen.dart';

/// Registration Screen allows new users to create their account.

class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  State<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  // Controllers to read the text input from the user in real-time
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();
  
  final StorageService _storageService = StorageService();
  String _errorMessage = '';

  // === MEMORY MANAGEMENT ===
  @override
  void dispose() {
    // Always dispose of TextEditingControllers when the widget is removed from the widget tree.
    // This prevents memory leaks and keeps the app running smoothly.
    _userController.dispose();
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }
  
  // === REGISTRATION LOGIC & VALIDATION ===
  Future<void> _registerAccount() async {
    String user = _userController.text;
    String pass = _passController.text;
    String confirmPass = _confirmPassController.text;

    // 1. Basic Validation: Check for empty fields
    if (user.isEmpty || pass.isEmpty || confirmPass.isEmpty) {
      setState(() { _errorMessage = 'All fields are required to register.'; });
      return;
    }
    // 2. Security Validation: Ensure passwords match
    if (pass != confirmPass) {
      setState(() { _errorMessage = 'Passwords do not match!'; });
      return;
    }
    // 3. Database Operation: Await the storage service to securely save the credentials
    await _storageService.registerAccount(user, pass);
    // 4. Navigation: Ensure the widget is still on screen before navigating
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, // Allows the background gradient to flow under the app bar
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.white, 
        elevation: 0
      ),
      
      body: Stack(
        children: [
          // Background Glow
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.8),
                  radius: 0.8, 
                  colors: [Colors.tealAccent.withValues(alpha: 0.2), Colors.black],
                ),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // --- SHIELD GRAPHIC ---
                  SizedBox(
                    height: 160,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 100, height: 100,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [BoxShadow(color: Colors.tealAccent.withValues(alpha: 0.4), blurRadius: 40, spreadRadius: 10)],
                          ),
                        ),
                        Icon(Icons.security, size: 120, color: Colors.grey[900]!.withValues(alpha:0.8)),
                        Positioned(
                          top: 10, right: 30,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              border: Border.all(color: Colors.tealAccent.withValues(alpha:0.5)),
                              borderRadius: BorderRadius.circular(15),
                            ),
                            child: const Text('AES-256', style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),
                  const Text('Create Account', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  const Text('Set up your master credentials.', textAlign: TextAlign.center, style: TextStyle(fontSize: 16, color: Colors.white70)),
                  const SizedBox(height: 30),
                  
                  // --- FORM INPUTS ---
                  TextField(
                    controller: _userController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),
                  
                  TextField(
                    controller: _passController,
                    obscureText: true, // Masks the password input for security
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 15),

                  TextField(
                    controller: _confirmPassController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Confirm Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),

                  // --- CONDITIONAL ERROR DISPLAY ---
                  // Only renders this block if there is actually an error to show
                  if (_errorMessage.isNotEmpty) ...[
                    const SizedBox(height: 15),
                    Text(_errorMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],

                  const SizedBox(height: 30),
                  
                  // --- SUBMIT BUTTON ---
                  ElevatedButton(
                    onPressed: _registerAccount,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.tealAccent,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Register & Continue', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}