import 'package:flutter/material.dart';
import 'Login_screens/onboarding_login_screen.dart';

void main() {
  runApp(const SkillSwapApp());
}

class SkillSwapApp extends StatelessWidget {
  const SkillSwapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SkillSwap',
      debugShowCheckedModeBanner: false,
      home: OnboardingScreen(), // <- your starting screen
    );
  }
}
