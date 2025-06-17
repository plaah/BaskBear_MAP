import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:skillswap/views/onboarding/splash_screen.dart';
import 'package:skillswap/viewmodels/auth_view_model.dart';
import 'package:skillswap/viewmodels/session_view_model.dart';
import 'package:skillswap/services/auth_service.dart';
import 'package:skillswap/services/session_service.dart';
import 'package:provider/provider.dart';
import 'package:skillswap/viewmodels/instructor_view_model.dart'; // Import InstructorViewModel

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AuthViewModel(AuthService()),
        ),
        ChangeNotifierProvider(
          create: (_) => SessionViewModel(FirestoreSessionService()),
        ),
        ChangeNotifierProvider( // Tambahkan provider untuk InstructorViewModel
          create: (_) => InstructorViewModel(),
        ),
      ],
      child: MaterialApp(
        title: 'SkillSwap',
        theme: ThemeData.dark().copyWith(
          primaryColor: Colors.blueAccent,
          scaffoldBackgroundColor: Colors.black,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            backgroundColor: Colors.transparent,
          ),
        ),
        home: const SplashScreen(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}