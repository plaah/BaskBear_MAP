import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// Import your BrowseSessionScreen here (adjust the import path as needed)
import '../sessions/browse_sessions_screen.dart';

class StudentDashboardScreen extends StatelessWidget {
  const StudentDashboardScreen({super.key});

  // Fetch the user's full name from Firestore using their UID
  Future<String?> getUserName() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return null;
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    return doc.data()?['fullName'] as String?;
  }

  @override
  Widget build(BuildContext context) {
    // Dummy course data
    final List<Map<String, String>> recommendedCourses = [
      {
        'title': 'UI Design Basics',
        'instructor': 'Sophia Yeshi',
        'duration': '5h',
        'level': 'Beginner',
        'rating': '4.8',
        'image':
            'https://images.unsplash.com/photo-1503676382389-4809596d5290?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Python Bootcamp',
        'instructor': 'John Doe',
        'duration': '12h',
        'level': 'Intermediate',
        'rating': '4.9',
        'image':
            'https://images.unsplash.com/photo-1519389950473-47ba0277781c?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Marketing 101',
        'instructor': 'Jane Smith',
        'duration': '8h',
        'level': 'Beginner',
        'rating': '4.7',
        'image':
            'https://images.unsplash.com/photo-1461749280684-dccba630e2f6?auto=format&fit=crop&w=400&q=80',
      },
      {
        'title': 'Business Communication',
        'instructor': 'Alex Lee',
        'duration': '6h',
        'level': 'All Levels',
        'rating': '4.5',
        'image':
            'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?auto=format&fit=crop&w=400&q=80',
      },
    ];

    const avatarUrl =
        'https://images.unsplash.com/photo-1594744803329-e58b31de8bf5?q=80&w=1974&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D';

    return Scaffold(
      backgroundColor: const Color(0xFF11131A),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF001950), Color(0xFF162447), Color(0xFF1F4068)],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 18.0,
                vertical: 16,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Welcome Header
                  Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.blueAccent,
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.blueAccent.withOpacity(0.35),
                              blurRadius: 14,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 28,
                          backgroundColor: Colors.transparent,
                          backgroundImage: NetworkImage(avatarUrl),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  'SkillSwap',
                                  style: TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                const Spacer(),
                              ],
                            ),
                            const SizedBox(height: 4),
                            FutureBuilder<String?>(
                              future: getUserName(),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return const Text(
                                    'Hi! 👋',
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  );
                                }
                                final name = snapshot.data ?? 'User';
                                return Text(
                                  'Hi, $name! 👋',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white.withOpacity(0.95),
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'What do you want to learn today?',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.blueAccent.withOpacity(0.18),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            Icons.notifications_none_rounded,
                            color: Colors.blueAccent.shade100,
                            size: 28,
                          ),
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  // Search Bar
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF22263A),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 4),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.blueAccent.withOpacity(0.11),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Search for courses, topics, or instructors',
                        hintStyle: TextStyle(
                          color: Colors.white.withOpacity(0.35),
                        ),
                        prefixIcon: Icon(
                          Icons.search_rounded,
                          color: Colors.blueAccent.shade100,
                        ),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),
                  // Feature Cards (Grid)
                  Text(
                    'Features',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white.withOpacity(0.85),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GridView.count(
                    crossAxisCount: 3,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.75,
                    children: [
                      _buildFeatureCard(
                        icon: Icons.search_rounded,
                        title: 'Find Courses',
                        color: Colors.blueAccent,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF1A2980), Color(0xFF26D0CE)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => const BrowseSessionScreen(),
                            ),
                          );
                        },
                      ),
                      _buildFeatureCard(
                        icon: Icons.book_rounded,
                        title: 'My Courses',
                        color: Colors.indigoAccent,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF283E51), Color(0xFF485563)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildFeatureCard(
                        icon: Icons.assignment_turned_in_rounded,
                        title: 'Assignments',
                        color: Colors.tealAccent,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF134E5E), Color(0xFF71B280)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildFeatureCard(
                        icon: Icons.chat_bubble_rounded,
                        title: 'Messages',
                        color: Colors.purpleAccent,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF41295A), Color(0xFF2F0743)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildFeatureCard(
                        icon: Icons.star_rounded,
                        title: 'Achievements',
                        color: Colors.amberAccent,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFFB347), Color(0xFFFFCC33)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      _buildFeatureCard(
                        icon: Icons.settings_rounded,
                        title: 'Settings',
                        color: Colors.grey,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF232526), Color(0xFF414345)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  // Recommended Courses
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Recommended Courses',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white.withOpacity(0.85),
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: Text(
                          'See All',
                          style: TextStyle(
                            color: Colors.blueAccent.shade100,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 220,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: recommendedCourses.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 16),
                      itemBuilder: (context, index) {
                        final course = recommendedCourses[index];
                        return _buildCourseCard(course);
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
      // Floating Rounded Bottom Navigation
      bottomNavigationBar: Container(
        height: 80,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF11131A), Color(0xFF1F4068)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.blueAccent.withOpacity(0.18),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  Icons.home_rounded,
                  color: Colors.white,
                  size: 28,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.search_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 26,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.bookmark_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 26,
                ),
                onPressed: () {},
              ),
              IconButton(
                icon: Icon(
                  Icons.person_rounded,
                  color: Colors.white.withOpacity(0.7),
                  size: 26,
                ),
                onPressed: () {},
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Feature Card Builder
  static Widget _buildFeatureCard({
    required IconData icon,
    required String title,
    required Color color,
    required Gradient gradient,
    VoidCallback? onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: gradient,
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.37),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.07),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: color.withOpacity(0.25),
                        blurRadius: 16,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(10),
                  child: Icon(icon, size: 22, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
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

  // Course Card Builder
  static Widget _buildCourseCard(Map<String, String> course) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: const Color(0xFF23263A),
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.blueAccent.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(
          color: Colors.blueAccent.withOpacity(0.13),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            child: Stack(
              children: [
                Image.network(
                  course['image']!,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder:
                      (context, error, stackTrace) => Container(
                        height: 100,
                        color: Colors.grey[900],
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white38,
                            size: 40,
                          ),
                        ),
                      ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blueAccent,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blueAccent.withOpacity(0.25),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          course['rating']!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  course['title']!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.92),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  course['instructor']!,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.6),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.schedule,
                      color: Colors.white.withOpacity(0.5),
                      size: 16,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      course['duration']!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blueAccent.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        course['level']!,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.blueAccent.shade100,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
