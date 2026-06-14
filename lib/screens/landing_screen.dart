import 'package:flutter/material.dart';
import 'auth_screen.dart';
import 'registration_screen.dart';

/// This screen acts as the welcome gateway for users.

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,

      body: Stack(
        children: [
          // === LAYER 1: AMBIENT BACKGROUND GLOW ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              height: 500,
              decoration: BoxDecoration(
                // RadialGradient creates a soft, fading "spotlight" effect coming from the bottom of the screen.
                gradient: RadialGradient(
                  center: const Alignment(0, 0.8),
                  radius: 0.8,
                  colors: [
                    Colors.tealAccent.withValues(alpha:0.3),
                    Colors.black,
                  ],
                ),
              ),
            ),
          ),
          
          // === LAYER 2: FOREGROUND CONTENT ===
          // SafeArea ensures our UI doesn't get covered by the phone's top notch, status bar, or bottom navigation gestures.
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  // --- TOP HEADER ---
                  const Row(
                    children: [
                      Icon(Icons.shield, color: Colors.tealAccent, size: 30),
                      SizedBox(width: 10),
                      Text(
                        'Vautify',
                        style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  
                  // Spacer() automatically expands to fill empty vertical space. 
                  // This dynamically centers our graphic no matter how tall the phone is.
                  const Spacer(),
                  
                  // --- MIDDLE GRAPHIC ---
                  SizedBox(
                    height: 240,
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        // The Glowing Aura
                        Container(
                          width: 140,
                          height: 140,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withValues(alpha:0.4),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),

                        // The Main Shield Asset
                        Icon(
                          Icons.security, 
                          size: 180, 
                          color: Colors.grey[900]!.withValues(alpha:0.8)
                        ),

                        // Floating AES-256 Badge
                        // Positioned allows absolute placement inside the Stack
                        Positioned(
                          top: 20,
                          right: 40,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.black87,
                              border: Border.all(color: Colors.tealAccent.withValues(alpha:0.5)),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text('AES-256', style: TextStyle(color: Colors.tealAccent, fontSize: 10, fontWeight: FontWeight.bold)),
                          ),
                        ),

                        // Overlapping "Encrypted Card" UI
                        Positioned(
                          bottom: 50,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha:0.8),
                              borderRadius: BorderRadius.circular(30),
                              border: Border.all(color: Colors.tealAccent, width: 1.5),
                              boxShadow: const [
                                BoxShadow(color: Colors.black54, blurRadius: 10, offset: Offset(0, 5)),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.key, color: Colors.tealAccent, size: 20),
                                SizedBox(width: 15),
                                Text(
                                  '•••• •••• •••• ••••', 
                                  style: TextStyle(color: Colors.white, fontSize: 18, letterSpacing: 3, fontWeight: FontWeight.bold)
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Another Spacer pushes the buttons down to the bottom of the screen
                  const Spacer(),
                  
                  // --- BOTTOM TEXT & BUTTONS ---
                  const Text(
                    'Your Digital Life,\nSecured.',
                    style: TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold, height: 1.2),
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'Store, manage, and protect all your passwords in one encrypted vault.',
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                  const SizedBox(height: 50),

                  // Login Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const AuthScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    ),
                    child: const Text('Login', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(height: 15),

                  // Register Button
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const RegistrationScreen()));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[900],
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 20),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      side: BorderSide(color: Colors.white.withValues(alpha:0.1)), 
                    ),
                    child: const Text('Register', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}