import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillswap/views/auth/login_screen.dart';
import 'package:skillswap/firebase_options.dart'; // Import the provided Firebase options

class NotificationScreen extends StatelessWidget {
  const NotificationScreen({super.key});

  // Initialize Firebase if not already initialized
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  @override
  Widget build(BuildContext context) {
    // Ensure Firebase is initialized
    return FutureBuilder(
      future: _initializeFirebase(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            body: Center(
              child: Text('Error initializing Firebase: ${snapshot.error}'),
            ),
          );
        }
        // Firebase is initialized, now check authentication state
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!authSnapshot.hasData) {
              // User is not authenticated, redirect to login screen
              return const LoginScreen();
            }
            // User is authenticated, display the notification screen
            return Scaffold(
              appBar: AppBar(
                title: const Text('Notifications'),
                backgroundColor: const Color.fromARGB(255, 2, 56, 131),
                foregroundColor: Colors.white,
              ),
              body: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color.fromARGB(255, 204, 204, 253),
                      Color.fromARGB(255, 252, 253, 255),
                      Color.fromARGB(255, 206, 239, 255),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Updates',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(221, 0, 0, 0),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: const [
                            // Placeholder for notification entries
                            // Replace with actual data from Firestore or FCM
                            NotificationEntry(
                              title: 'New Student Enrollment',
                              message:
                                  'John Doe has enrolled in your Mathematics course.',
                              time: '10 minutes ago',
                              icon: Icons.person_add,
                              iconColor: Color(0xFFF57C00), // Warm Orange
                            ),
                            NotificationEntry(
                              title: 'Course Update',
                              message:
                                  'Your Physics course schedule has been updated.',
                              time: '2 hours ago',
                              icon: Icons.update,
                              iconColor: Color(0xFF1976D2), // Bright Blue
                            ),
                            NotificationEntry(
                              title: 'New Student Enrollment',
                              message:
                                  'Jane Smith has enrolled in your Programming course.',
                              time: '1 day ago',
                              icon: Icons.person_add,
                              iconColor: Color(0xFFF57C00), // Warm Orange
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}

// Widget to display individual notification entries
class NotificationEntry extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final Color iconColor;

  const NotificationEntry({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.icon,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              padding: const EdgeInsets.all(10),
              child: Icon(icon, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color.fromARGB(255, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Color.fromARGB(221, 255, 255, 255),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    time,
                    style: TextStyle(
                      fontSize: 12,
                      color: const Color.fromARGB(255, 232, 232, 232),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
