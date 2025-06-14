import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillswap/views/auth/login_screen.dart';
import 'package:skillswap/firebase_options.dart'; // Import the provided Firebase options

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

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
            // User is authenticated, display the timetable screen
            return Scaffold(
              appBar: AppBar(
                title: const Text('Timetable'),
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
                        'Your Schedule',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: ListView(
                          children: const [
                            // Placeholder for timetable entries
                            // Replace with actual data from Firestore or backend
                            TimetableEntry(
                              time: '9:00 AM - 10:00 AM',
                              subject: 'Mathematics',
                              location: 'Room 101',
                            ),
                            TimetableEntry(
                              time: '10:30 AM - 11:30 AM',
                              subject: 'Physics',
                              location: 'Room 202',
                            ),
                            TimetableEntry(
                              time: '1:00 PM - 2:00 PM',
                              subject: 'Programming',
                              location: 'Lab 301',
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

// Widget to display individual timetable entries
class TimetableEntry extends StatelessWidget {
  final String time;
  final String subject;
  final String location;

  const TimetableEntry({
    super.key,
    required this.time,
    required this.subject,
    required this.location,
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
            const Icon(Icons.access_time, color: Color(0xFF1976D2), size: 28),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color.fromARGB(255, 255, 255, 255),
                  ),
                ),
                Text(
                  subject,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  location,
                  style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
