import 'package:flutter/material.dart';
import 'screens/splash_screen.dart'; 

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const PasswordManagerApp());
}

class PasswordManagerApp extends StatelessWidget {
  const PasswordManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vautify',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[100],
      ),
      
      home: const SplashScreen(), 
    );
  }
}