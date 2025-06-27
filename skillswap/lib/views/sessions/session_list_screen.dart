import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_view_model.dart';
import '../../models/session_model.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../bookings/booking_screen.dart';

class SessionListScreen extends StatefulWidget {
  const SessionListScreen({super.key});

  @override
  State<SessionListScreen> createState() => _SessionListScreenState();
}

class _SessionListScreenState extends State<SessionListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SessionViewModel>().loadSessions();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Modern gradient background
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Available Sessions',
          style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 0.5),
        ),
        backgroundColor: const Color.fromARGB(34, 70, 158, 241),
        elevation: 0,
        foregroundColor: Colors.white,
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 1, 56, 83),
              Color.fromARGB(255, 77, 155, 232),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Consumer<SessionViewModel>(
          builder: (context, viewModel, _) {
            // FILTER: hanya sesi yang available
            final availableSessions = viewModel.sessions.where((session) =>
              session.isBooked == false &&
              session.status == 'scheduled' &&
              session.enrolledStudentId == null
            ).toList();
            if (availableSessions.isEmpty && !viewModel.isLoading) {
              return _buildEmptyState();
            }
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(20, 100, 20, 20),
              itemCount: availableSessions.length,
              itemBuilder: (context, index) {
                final session = availableSessions[index];
                return _buildSessionCard(session, index, viewModel);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildSessionCard(Session session, int index, SessionViewModel vm) {
    // Glassmorphism effect
    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.15), width: 1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Column(
          children: [
            ListTile(
              leading:
                  session.image.startsWith('http')
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          session.image,
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 56,
                                color: Colors.grey,
                              ),
                        ),
                      )
                      : session.image.isNotEmpty
                      ? ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          File(session.image),
                          width: 56,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.image_not_supported,
                                size: 56,
                                color: Colors.grey,
                              ),
                        ),
                      )
                      : Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(
                            255,
                            173,
                            213,
                            232,
                          ).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.school,
                          size: 36,
                          color: Color.fromARGB(255, 136, 198, 255),
                        ),
                      ),
              title: Text(
                session.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.2,
                ),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(Icons.category, size: 15, color: Colors.blue[200]),
                    const SizedBox(width: 5),
                    Text(
                      session.category,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.edit_rounded,
                      color: Color.fromARGB(255, 152, 177, 250),
                    ),
                    onPressed: () {
                      _showEditDialog(context, session, vm);
                    },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      color: Color(0xFFF76B6B),
                    ),
                    onPressed: () {
                      _showDeleteConfirmation(context, session, vm);
                    },
                  ),
                ],
              ),
            ),
            // Divider with gradient
            Container(
              height: 1,
              margin: const EdgeInsets.symmetric(horizontal: 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFF5B81F7), Color(0xFFF76B6B)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
            // Tombol Book
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 24.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    minimumSize: const Size(double.infinity, 45),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => BookingScreen(sessionId: session.id),
                      ),
                    );
                  },
                  child: const Text('Book Session', style: TextStyle(fontSize: 16)),
                ),
              ),
            ),
            // Expandable details
            Theme(
              data: Theme.of(context).copyWith(
                dividerColor: Colors.transparent,
                unselectedWidgetColor: Colors.white70,
                colorScheme: ColorScheme.dark(primary: Color(0xFF5B81F7)),
              ),
              child: ExpansionTile(
                title: const Text(
                  'View Details',
                  style: TextStyle(
                    color: Colors.white70,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                iconColor: const Color(0xFF5B81F7),
                collapsedIconColor: Colors.white54,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildDetailRow(Icons.description, session.description),
                        _buildDetailRow(
                          Icons.calendar_today,
                          '${_formatDate(session.startDate)} - ${_formatDate(session.endDate)}',
                        ),
                        _buildDetailRow(
                          Icons.access_time,
                          '${session.durationHours} Hours',
                        ),
                        if (!session.isOnline && session.location != null)
                          _buildDetailRow(Icons.location_on, session.location!),
                        _buildDetailRow(
                          Icons.attach_money,
                          session.price > 0 ? '\$${session.price}' : 'Free',
                        ),
                      ],
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

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: const Color.fromARGB(255, 253, 254, 255)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Color.fromARGB(255, 175, 209, 255),
                fontSize: 15,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null ? '${date.day}/${date.month}/${date.year}' : 'Not set';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_circle_outline_rounded,
            size: 90,
            color: Colors.white24,
          ),
          const SizedBox(height: 24),
          const Text(
            'No Courses Created Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white70,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Tap the + button to create your first course',
            style: TextStyle(color: Colors.white54, fontSize: 15),
          ),
        ],
      ),
    );
  }

  // Keep your dialog and delete confirmation logic as is, but update their colors for consistency
  void _showEditDialog(
    BuildContext context,
    Session session,
    SessionViewModel vm,
  ) {
    // ... keep your dialog logic, but update colors:
    // - Dialog background: Color(0xFF232526)
    // - TextFields: Color(0xFF2D2D2D), borderRadius 12, border color Color(0xFF5B81F7) on focus
    // - Buttons: backgroundColor: Color(0xFF5B81F7), textColor: Colors.white
    // - Use modern icons (edit_rounded, delete_outline_rounded)
    // - Use white and blue accent for text/buttons
    // - Use rounded corners throughout
    // (For brevity, not repeating the full dialog code here. Just update colors/styles as above.)
  }

  void _showDeleteConfirmation(
    BuildContext context,
    Session session,
    SessionViewModel vm,
  ) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF232526),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Text(
            'Delete Course',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            'Are you sure you want to delete "${session.title}"? This action cannot be undone.',
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancel',
                style: TextStyle(color: Colors.white54),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                vm.deleteSession(session.id);
              },
              child: const Text(
                'Delete',
                style: TextStyle(
                  color: Color(0xFFF76B6B),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
