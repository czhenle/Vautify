import 'package:flutter/material.dart';
import 'landing_screen.dart';

/// This screen is very first screen the user sees when launching the app.

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isVisible = false;

  @override
  void initState() {
    super.initState();
    
    // 1. TRIGGER ANIMATION: 
    // We wait 100 milliseconds after the screen builds to change the state.
    // This slight delay ensures the build method has finished before the animation starts.
    Future.delayed(const Duration(milliseconds: 100), () {
      if (mounted) {
        setState(() {
          _isVisible = true; // Flipping this triggers all AnimatedOpacity/AnimatedScale widgets!
        });
      }
    });
    
    // 2. TRIGGER NAVIGATION:
    // Start the countdown to move to the next screen.
    _navigateToLanding();
  }

  Future<void> _navigateToLanding() async {
    // Increased the delay slightly to 2.5 seconds so the user can enjoy the animation
    await Future.delayed(const Duration(milliseconds: 2500));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LandingScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D10), // Deep charcoal base
      body: Stack(
        children: [
          // === LAYER 1: AMBIENT GLOWS (Background)===
          Positioned(
            top: -150, left: -100,
            child: Container(
              width: 400, height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.tealAccent.withValues(alpha: 0.12), Colors.transparent],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -200, right: -100,
            child: Container(
              width: 500, height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Colors.tealAccent.withValues(alpha: 0.15), Colors.transparent],
                ),
              ),
            ),
          ),

          // === LAYER 2: ANIMATED CENTER LOGO (Middle) ===
          Center(
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 1200),
              curve: Curves.easeOutCubic,
              opacity: _isVisible ? 1.0 : 0.0,

              // Implicit Animation: Automatically transitions the size.
              child: AnimatedScale(
                duration: const Duration(milliseconds: 1200),
                curve: Curves.easeOutCubic,
                scale: _isVisible ? 1.0 : 0.8, // Starts at 80% size and scales up to 100%

                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // The Glowing Shield Visual
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // The inner glow shadow behind the shield
                        Container(
                          width: 120, height: 120,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.tealAccent.withValues(alpha: 0.3),
                                blurRadius: 50,
                                spreadRadius: 10,
                              ),
                            ],
                          ),
                        ),
                        // The primary shield and key icons
                        Icon(Icons.security, size: 140, color: Colors.grey[900]!.withValues(alpha: 0.9)),
                        const Icon(Icons.key, size: 40, color: Colors.tealAccent),
                      ],
                    ),
                    const SizedBox(height: 35),
                    
                    // App Name
                    const Text(
                      'VAUTIFY',
                      style: TextStyle(
                        fontSize: 36, 
                        fontWeight: FontWeight.bold, 
                        color: Colors.white,
                        letterSpacing: 10.0, 
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                    // Subtitle
                    const Text(
                      'AES-256 ENCRYPTED VAULT',
                      style: TextStyle(
                        fontSize: 12, 
                        fontWeight: FontWeight.w600, 
                        color: Colors.tealAccent,
                        letterSpacing: 3.0,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // === LAYER 3: BOTTOM LOADING STATUS (Top Foreground) ===
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 60.0),
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 1500),
                opacity: _isVisible ? 1.0 : 0.0,
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Prevents column from taking up full screen height
                  children: [
                    const SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(
                        color: Colors.tealAccent,
                        strokeWidth: 2, // Thinner stroke looks more high-tech
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Initializing Secure Engine...',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.5), 
                        fontSize: 12, 
                        letterSpacing: 1.5
                      ),
                    )
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