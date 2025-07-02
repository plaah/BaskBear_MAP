import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:skillswap/views/bookings/my_booking_screen.dart';
import '../../models/session_model.dart';
import '../../viewmodels/session_view_model.dart';
import '../../widgets/course_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/empty_state.dart';
import '../bookings/advanced_booking_screen.dart';
import '../profile/student/student_profile_screen.dart';
import '../onboarding/splash_screen.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../models/booking_model.dart';
import '../../views/reviews/review_dialog.dart';
import '../../viewmodels/review_view_model.dart';
import '../../widgets/session_card.dart';

// Extension untuk firstWhereOrNull
extension IterableExtension<T> on Iterable<T> {
  T? firstWhereOrNull(bool Function(T element) test) {
    for (final element in this) {
      if (test(element)) return element;
    }
    return null;
  }
}

class StudentDashboardScreen extends StatefulWidget {
  final String studentId;
  final String studentName;

  const StudentDashboardScreen({
    super.key,
    required this.studentId,
    required this.studentName,
  });

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _selectedTab = 'available';
  int _selectedIndex = 0;

  final List<String> _categories = [
    'All',
    'Design',
    'Development',
    'Business',
    'Marketing',
    'Photography',
    'Music',
    'Language',
    'Science',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().loadSessions();
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        context.read<BookingViewModel>().fetchBookingsByUserId(user.uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 245, 252, 255),

      body: CustomScrollView(
        slivers: [
          _buildAppBar(),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: SearchWithFilters(
                searchController: _searchController,
                selectedCategory: _selectedCategory,
                categories: _categories,
                onCategoryChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });
                },
                onSearchChanged: (query) {
                  setState(() {});
                },
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: _buildTabBar(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            sliver: Consumer<SessionViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const SliverToBoxAdapter(
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final filteredSessions = _getFilteredSessions(
                  viewModel.sessions,
                );

                if (filteredSessions.isEmpty) {
                  return SliverToBoxAdapter(
                    child: NoCoursesEmptyState(
                      onRefresh: () => viewModel.loadSessions(),
                    ),
                  );
                }

                return SliverList(
                  delegate: SliverChildBuilderDelegate((context, index) {
                    final session = filteredSessions[index];
                    BookingModel? booking;
                    if (_selectedTab == 'enrolled') {
                      final bookings = context.watch<BookingViewModel>().bookings;
                      // Explicitly use the extension from this file to resolve ambiguity
                      booking = IterableExtension<BookingModel>(bookings).firstWhereOrNull((b) => b.sessionId == session.id);
                      return SessionCard(
                        session: session,
                        isDone: booking?.isDone ?? false,
                        isReviewed: booking?.isReview ?? false,
                        onDone: (booking != null && !(booking.isDone))
                          ? () async {
                              final b = booking;
                              if (b == null) return;
                              await context.read<BookingViewModel>().updateBookingFields(b.id, {'isDone': true});
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await context.read<BookingViewModel>().fetchBookingsByUserId(user.uid);
                              }
                              setState(() {});
                            }
                          : null,
                        onReview: (booking != null && booking.isDone && !booking.isReview)
                          ? () async {
                              final b = booking;
                              if (b == null) return;
                              final result = await showDialog(
                                context: context,
                                builder: (context) => ChangeNotifierProvider(
                                  create: (_) => ReviewViewModel(),
                                  child: ReviewDialog(
                                    sessionId: b.sessionId,
                                    instructorId: session.instructorId,
                                    sessionTitle: session.title,
                                    instructorName: session.instructor,
                                  ),
                                ),
                              );
                              if (result != null) {
                                await context.read<BookingViewModel>().updateBookingFields(b.id, {'isReview': true});
                                final user = FirebaseAuth.instance.currentUser;
                                if (user != null) {
                                  await context.read<BookingViewModel>().fetchBookingsByUserId(user.uid);
                                }
                              }
                            }
                          : null,
                        showEnrollButton: false,
                      );
                    }
                    return CourseCard(
                      session: session,
                      showEnrollButton: _selectedTab == 'available',
                      onEnroll: () => _enrollInSession(session),
                      onTap: () => _showSessionDetails(session, booking),
                      isDone: booking?.isDone ?? false,
                      isReview: booking?.isReview ?? false,
                      onReview: (booking != null && !booking.isReview)
                        ? () async {
                            final b = booking;
                            if (b == null) return;
                            final result = await showDialog(
                              context: context,
                              builder: (context) => ChangeNotifierProvider(
                                create: (_) => ReviewViewModel(),
                                child: ReviewDialog(
                                  sessionId: b.sessionId,
                                  instructorId: session.instructorId,
                                  sessionTitle: session.title,
                                  instructorName: session.instructor,
                                ),
                              ),
                            );
                            if (result != null) {
                              await context.read<BookingViewModel>().updateBookingFields(b.id, {'isReview': true});
                              final user = FirebaseAuth.instance.currentUser;
                              if (user != null) {
                                await context.read<BookingViewModel>().fetchBookingsByUserId(user.uid);
                              }
                            }
                          }
                        : null,
                    );
                  }, childCount: filteredSessions.length),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildAppBar() {
    return SliverAppBar(
      expandedHeight: 110,
      floating: false,
      pinned: true,
      backgroundColor: Colors.white,
      elevation: 0,
      automaticallyImplyLeading: false,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF66A4EA), Color(0xFF66A4EA), Color(0xFFA5E7FF)],
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Clickable profile avatar
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StudentProfileScreen(),
                        ),
                      );
                    },
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      child: Text(
                        widget.studentName.isNotEmpty
                            ? widget.studentName[0].toUpperCase()
                            : 'S',
                        style: GoogleFonts.poppins(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Welcome',
                          style: GoogleFonts.poppins(
                            color: Colors.white,
                            fontSize: 19,
                            fontWeight: FontWeight.bold,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Ready to learn something new?',
                          style: GoogleFonts.poppins(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.logout,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: () async {
                      final shouldLogout = await showDialog<bool>(
                        context: context,
                        barrierDismissible: true,
                        builder: (context) {
                          return AlertDialog(
                            backgroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            title: const Text(
                              'Confirm Logout',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Colors.black,
                              ),
                            ),
                            content: const Padding(
                              padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                              child: Text(
                                'Are you sure you want to logout?',
                                style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                            actionsPadding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            actions: [
                              TextButton(
                                onPressed:
                                    () => Navigator.of(context).pop(false),
                                child: const Text(
                                  'Cancel',
                                  style: TextStyle(color: Colors.black87),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF667eea),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                onPressed:
                                    () => Navigator.of(context).pop(true),
                                child: const Text('Logout'),
                              ),
                            ],
                          );
                        },
                      );
                      if (shouldLogout == true) {
                        await FirebaseAuth.instance.signOut();
                        Navigator.of(context).pushAndRemoveUntil(
                          MaterialPageRoute(
                            builder: (context) => const SplashScreen(),
                          ),
                          (route) => false,
                        );
                      }
                    },
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildTabButton('Available Courses', 'available'),
          _buildTabButton('My Enrollments', 'enrolled'),
        ],
      ),
    );
  }

  Widget _buildTabButton(String title, String tabKey) {
    final isSelected = _selectedTab == tabKey;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = tabKey),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              color: isSelected ? Colors.white : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home, 'Home', 0),
              _buildNavItem(Icons.explore, 'Explore', 1),
              _buildNavItem(Icons.bookmark, 'Bookings', 2),
              _buildNavItem(Icons.person, 'Profile', 3),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final isSelected = _selectedIndex == index;
    return GestureDetector(
      onTap: () => _onItemTapped(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color:
                  isSelected
                      ? const Color(0xFF667eea).withOpacity(0.13)
                      : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color:
                  isSelected ? const Color(0xFF667eea) : Colors.grey.shade600,
              size: 24,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: GoogleFonts.poppins(
              fontSize: 12,
              color:
                  isSelected ? const Color(0xFF667eea) : Colors.grey.shade600,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  List<Session> _getFilteredSessions(List<Session> allSessions) {
    List<Session> sessions = allSessions;
    if (_selectedTab == 'enrolled') {
      sessions =
          sessions
              .where((session) => session.enrolledStudentId == widget.studentId)
              .toList();
    } else {
      sessions = sessions.where((session) => session.isAvailable).toList();
    }
    if (_selectedCategory != 'All') {
      sessions =
          sessions
              .where((session) => session.category == _selectedCategory)
              .toList();
    }
    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      sessions =
          sessions
              .where(
                (session) =>
                    session.title.toLowerCase().contains(query) ||
                    session.category.toLowerCase().contains(query) ||
                    session.instructor.toLowerCase().contains(query),
              )
              .toList();
    }
    return sessions;
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        break;
      case 1:
        setState(() {
          _selectedTab = 'available';
        });
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const MyBookingScreen()),
        );
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const StudentProfileScreen()),
        );
        break;
    }
  }

  Future<void> _enrollInSession(Session session) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder:
            (context) => AdvancedBookingScreen(
              session: session,
              studentId: widget.studentId,
              studentName: widget.studentName,
            ),
      ),
    );
    if (result == true) {
      context.read<SessionViewModel>().loadSessions();
    }
  }

  void _showSessionDetails(Session session, BookingModel? booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder:
          (context) => ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.white.withOpacity(0.88),
                      Colors.blue.shade50.withOpacity(0.85),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(28),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blueGrey.withOpacity(0.15),
                      blurRadius: 30,
                      offset: const Offset(0, -6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(24),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 40,
                        height: 5,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(2.5),
                        ),
                      ),
                      if (session.image.isNotEmpty)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(18),
                          child: Image.network(
                            session.image,
                            width: double.infinity,
                            height: 170,
                            fit: BoxFit.cover,
                          ),
                        ),
                      const SizedBox(height: 18),
                      Text(
                        session.title,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: Colors.blue.shade100,
                            child: Icon(
                              Icons.person,
                              color: Colors.blue.shade700,
                              size: 18,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            session.instructor,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              color: Colors.blueGrey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _modernDetailRow(
                        Icons.category,
                        'Category',
                        session.category,
                      ),
                      _modernDetailRow(
                        Icons.access_time,
                        'Duration',
                        '${session.durationHours} hours',
                      ),
                      _modernDetailRow(
                        Icons.calendar_today,
                        'Date',
                        _formatDate(session.startDate),
                      ),
                      _modernDetailRow(
                        Icons.attach_money,
                        'Price',
                        '\$${session.price}',
                      ),
                      const SizedBox(height: 28),
                      if (session.isAvailable)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.check_circle_outline),
                            label: const Text(
                              'Enroll Now',
                              style: TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF667eea),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                              elevation: 2,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _enrollInSession(session);
                            },
                          ),
                        ),
                      const SizedBox(height: 10),
                      if (booking != null && booking.isDone) ...[
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Text(
                            'Done',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        if (!booking.isReview)
                          ElevatedButton.icon(
                            onPressed: () async {
                              // Show review dialog and update booking after review
                            },
                            icon: const Icon(Icons.rate_review, color: Colors.white, size: 18),
                            label: const Text('Write Review', style: TextStyle(color: Colors.white)),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
    );
  }

  Widget _modernDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 163, 211, 255),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: const Color.fromARGB(255, 9, 97, 169),
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Text(
            '$label: ',
            style: GoogleFonts.poppins(
              color: const Color.fromARGB(255, 3, 59, 87),
              fontWeight: FontWeight.w500,
              fontSize: 15,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.w600,
                fontSize: 15,
                color: Colors.black87,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}