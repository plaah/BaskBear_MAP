import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:skillswap/views/sessions/create_session_screen.dart';
import 'package:skillswap/views/profile/instructor/instructor_profile_screen.dart';
import 'package:skillswap/views/sessions/session_list_screen.dart';
import 'package:skillswap/views/auth/login_screen.dart';
import 'package:skillswap/views/timetable/timetable_screen.dart';
import 'package:skillswap/views/notifications/notification_screen.dart';
import 'package:skillswap/firebase_options.dart'; // Import the provided Firebase options
import '../bookings/instructor_bookings_screen.dart';

class InstructorHomeScreen extends StatefulWidget {
  const InstructorHomeScreen({super.key});

  @override
  State<InstructorHomeScreen> createState() => _InstructorHomeScreenState();
}

class _InstructorHomeScreenState extends State<InstructorHomeScreen> {
  int _selectedIndex = 0;
  String _instructorName =
      'Instructor'; // Default name until fetched from Firebase

  @override
  void initState() {
    super.initState();
    _initializeFirebaseAndFetchUser();
  }

  // Initialize Firebase and fetch user data
  Future<void> _initializeFirebaseAndFetchUser() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final User? user = FirebaseAuth.instance.currentUser;
    if (user != null &&
        user.displayName != null &&
        user.displayName!.isNotEmpty) {
      setState(() {
        _instructorName = user.displayName!;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == 3) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const InstructorProfileScreen(),
        ),
      );
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _logout(BuildContext context) {
    // Show styled confirmation dialog before logout
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          elevation: 5,
          title: const Text(
            'Confirm Logout',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A237E),
            ),
          ),
          content: const Text(
            'Are you sure you want to logout?',
            style: TextStyle(color: Colors.black87),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('No', style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text(
                'Yes, Logout',
                style: TextStyle(
                  color: Color(0xFF1976D2),
                  fontWeight: FontWeight.bold,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                // Navigate to LoginScreen and clear the navigation stack
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => LoginScreen()),
                  (Route<dynamic> route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFE3F2FD), // Light Blue for a calming base
              Color(0xFFF5F5F5), // Neutral White for balance
              Color(0xFFE1F5FE), // Soft Sky Blue for a cohesive gradient
            ],
          ),
        ),
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 180,
              floating: false,
              pinned: true,
              backgroundColor: Colors.white,
              automaticallyImplyLeading: false, // Removes the back button
              flexibleSpace: FlexibleSpaceBar(
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color.fromARGB(
                          227,
                          21,
                          101,
                          192,
                        ), // Deep Blue for primary branding
                        Color.fromARGB(171, 21, 101, 192),
                        Color.fromARGB(171, 21, 101, 192),
                      ],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) =>
                                              const InstructorProfileScreen(),
                                    ),
                                  );
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.5),
                                      width: 2.5,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        blurRadius: 6,
                                        offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: const CircleAvatar(
                                    radius: 24,
                                    backgroundColor: Color(0xFF42A5F5),
                                    child: Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 30,
                                    ),
                                  ),
                                ),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                tooltip: 'Notifications',
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder:
                                          (context) => NotificationScreen(),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.exit_to_app,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                tooltip: 'Logout',
                                onPressed: () => _logout(context),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Hello, $_instructorName 👋',
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Manage your courses and students efficiently.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white70,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 24,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Features',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A237E),
                      ),
                    ),
                    const SizedBox(height: 16),
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                      children: [
                        _buildFeatureCard(
                          icon: Icons.add_circle,
                          title: 'Create Course',
                          iconColor: const Color(0xFF1976D2), // Bright Blue
                          backgroundGradient: const LinearGradient(
                            colors: [Color(0xFFE3F2FD), Color(0xFFBBDEFB)],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CreateSessionScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.library_books,
                          title: 'My Courses',
                          iconColor: const Color(0xFF388E3C), // Deep Green
                          backgroundGradient: const LinearGradient(
                            colors: [Color(0xFFE8F5E9), Color(0xFFC8E6C9)],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SessionListScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.people,
                          title: 'Students',
                          iconColor: const Color(0xFFF57C00), // Warm Orange
                          backgroundGradient: const LinearGradient(
                            colors: [Color(0xFFFFF3E0), Color(0xFFFFE0B2)],
                          ),
                          onTap: () {},
                        ),
                        _buildFeatureCard(
                          icon: Icons.bookmark,
                          title: 'Bookings',
                          iconColor: const Color(0xFFE91E63), // Pink
                          backgroundGradient: const LinearGradient(
                            colors: [Color(0xFFFCE4EC), Color(0xFFF8BBD9)],
                          ),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const InstructorBookingsScreen(),
                              ),
                            );
                          },
                        ),
                        _buildFeatureCard(
                          icon: Icons.analytics,
                          title: 'Analytics',
                          iconColor: const Color(0xFF7C4DFF), // Vibrant Purple
                          backgroundGradient: const LinearGradient(
                            colors: [Color(0xFFF3E5F5), Color(0xFFE1BEE7)],
                          ),
                          onTap: () {},
                        ),
                        _buildFeatureCard(
                          icon: Icons.calendar_today,
                          title: 'Timetable',
                          iconColor: const Color(0xFFD32F2F), // Bold Red
                          backgroundGradient: const LinearGradient(
                            colors: [Color(0xFFFFEBEE), Color(0xFFFFCDD2)],
                          ),
                          onTap: () {
                            final user = FirebaseAuth.instance.currentUser;
                            if (user != null) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => InstructorTimetableScreen(
                                    instructorId: user.uid,
                                    instructorName: _instructorName,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: const Color(
              0xFF1565C0,
            ), // Deep Blue for consistency
            unselectedItemColor: Colors.grey.shade500,
            showSelectedLabels: false,
            showUnselectedLabels: false,
            elevation: 0,
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.home_filled),
                label: 'Home',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.library_books),
                label: 'Courses',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.analytics),
                label: 'Analytics',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color iconColor,
    required LinearGradient backgroundGradient,
    VoidCallback? onTap,
  }) {
    const Color textColor = Color(0xFF1A237E);
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: backgroundGradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  padding: const EdgeInsets.all(14),
                  child: Icon(icon, size: 30, color: iconColor),
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
