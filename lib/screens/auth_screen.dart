import 'package:flutter/material.dart';
import '../services/storage_service.dart';
import 'home_screen.dart'; 

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _userController = TextEditingController();
  final TextEditingController _passController = TextEditingController();
  final StorageService _storageService = StorageService();
  
  final String _welcomeMessage = 'Hey, welcome back!';
  String _authMessage = '';
  bool _isError = false;

  Future<void> _login() async {
    String enteredUser = _userController.text;
    String enteredPass = _passController.text;
    
    if (enteredUser.isEmpty || enteredPass.isEmpty) {
      setState(() {
        _isError = true;
        _authMessage = 'Please fill in both fields.';
      });
      return;
    }

    bool isSuccess = await _storageService.verifyLogin(enteredUser, enteredPass);

    if (isSuccess) {
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
          (Route<dynamic> route) => false,
        );
      }
    } else {
      setState(() {
        _isError = true;
        _authMessage = 'Incorrect username or password.';
        _passController.clear(); 
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true, 
      appBar: AppBar(
        backgroundColor: Colors.transparent, 
        foregroundColor: Colors.white, 
        elevation: 0
      ),
      
      body: Stack(
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 400,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, 0.8),
                  radius: 0.8, 
                  colors: [Colors.tealAccent.withValues(alpha:0.3), Colors.black],
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
                            boxShadow: [BoxShadow(color: Colors.tealAccent.withValues(alpha:0.4), blurRadius: 40, spreadRadius: 10)],
                          ),
                        ),
                        Icon(Icons.security, size: 120, color: Colors.grey[900]!.withValues(alpha: 0.8)),
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
                  const Text('Login', textAlign: TextAlign.center, style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white)),
                  const SizedBox(height: 10),
                  Text(_welcomeMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 18, color: Colors.white70)),
                  const SizedBox(height: 40),
                  
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
                  const SizedBox(height: 20),

                  TextField(
                    controller: _passController,
                    obscureText: true,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: const TextStyle(color: Colors.grey),
                      filled: true,
                      fillColor: Colors.grey[900],
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  
                  if (_isError && _authMessage.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(_authMessage, textAlign: TextAlign.center, style: const TextStyle(fontSize: 14, color: Colors.redAccent, fontWeight: FontWeight.bold)),
                  ],
                  
                  const SizedBox(height: 30),
                  
                  ElevatedButton(
                    onPressed: _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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