import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/session_view_model.dart';
import '../../models/session_model.dart';

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
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Courses'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: Consumer<SessionViewModel>(
        builder: (context, viewModel, _) {
          if (viewModel.sessions.isEmpty && !viewModel.isLoading) {
            return _buildEmptyState();
          }


          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: viewModel.sessions.length,
            itemBuilder: (context, index) {
              final session = viewModel.sessions[index];
              return _buildSessionCard(session, index, viewModel);
            },
          );
        },
      ),
    );
  }

  Widget _buildSessionCard(Session session, int index, SessionViewModel vm) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          // Header with action buttons
          ListTile(
            leading: session.image.startsWith('http')
                ? Image.network(session.image, width: 60, height: 60)
                : Image.file(File(session.image), width: 60, height: 60),
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Booking Status: ${session.isBooked ? 'Booked' : 'Not booked'}',
                  style: TextStyle(
                    fontSize: 12,
                    color: session.isBooked ? Colors.green[800] : Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Icon(Icons.category, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(session.category),
                  ],
                ),
              ],
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.edit, color: Colors.indigo),
                  onPressed: () {
                    // Show edit dialog
                    _showEditDialog(context, session, vm);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: () {
                    _showDeleteConfirmation(context, session, vm);
                  },
                ),
              ],
            ),
          ),
          // Expandable content
          ExpansionTile(
            title: const Text('View Details'),
            children: [
              Padding(
                padding: const EdgeInsets.all(16).copyWith(top: 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildDetailRow(Icons.description, session.description),
                    _buildDetailRow(Icons.calendar_today,
                        '${_formatDate(session.startDate)} - ${_formatDate(session.endDate)}'),
                    _buildDetailRow(Icons.access_time, '${session.durationHours} Hours'),
                    if (!session.isOnline)
                      _buildDetailRow(Icons.location_on, session.location ?? ''),
                    _buildDetailRow(Icons.attach_money,
                        session.price > 0 ? '\$${session.price}' : 'Free'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showEditDialog(BuildContext context, Session session, SessionViewModel vm) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: const Color(0xFF1E1E1E),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            width: MediaQuery.of(context).size.width * 0.9,
            height: MediaQuery.of(context).size.height * 0.8,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Course Details',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      IconButton(
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(Icons.close, color: Colors.white),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Course Image
                  if (session.image.isNotEmpty)
                    Center(
                      child: Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: const Color(0xFF404040)),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: session.image.startsWith('http')
                              ? Image.network(
                            session.image,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF2D2D2D),
                                child: const Icon(Icons.image, color: Colors.grey, size: 40),
                              );
                            },
                          )
                              : Image.file(
                            File(session.image),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: const Color(0xFF2D2D2D),
                                child: const Icon(Icons.image, color: Colors.grey, size: 40),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Course Details Section
                  _buildDisplaySection('Course Information'),
                  const SizedBox(height: 16),

                  _buildDisplayItem('Course Title', session.title, Icons.title),
                  const SizedBox(height: 12),

                  _buildDisplayItem('Description', session.description, Icons.description),
                  const SizedBox(height: 12),

                  _buildDisplayItem('Category', session.category, Icons.category),
                  const SizedBox(height: 12),

                  _buildDisplayItem(
                      'Price',
                      session.price > 0 ? '\$${session.price.toStringAsFixed(2)}' : 'Free',
                      Icons.attach_money
                  ),
                  const SizedBox(height: 12),

                  _buildDisplayItem('Duration', '${session.durationHours} Hours', Icons.access_time),
                  const SizedBox(height: 24),

                  // Delivery Method Section
                  _buildDisplaySection('Delivery Method'),
                  const SizedBox(height: 16),
                  _buildDisplayItem(
                      'Type',
                      session.isOnline ? 'Online Course' : 'In-Person Course',
                      session.isOnline ? Icons.computer : Icons.location_on
                  ),
                  const SizedBox(height: 12),

                  if (!session.isOnline && session.location != null && session.location!.isNotEmpty)
                    _buildDisplayItem('Location', session.location!, Icons.place),
                  const SizedBox(height: 24),

                  // Schedule Section
                  _buildDisplaySection('Schedule'),
                  const SizedBox(height: 16),
                  _buildDisplayItem(
                      'Start Date',
                      session.startDate != null
                          ? '${session.startDate!.day}/${session.startDate!.month}/${session.startDate!.year}'
                          : 'Not set',
                      Icons.calendar_today
                  ),
                  const SizedBox(height: 12),

                  _buildDisplayItem(
                      'End Date',
                      session.endDate != null
                          ? '${session.endDate!.day}/${session.endDate!.month}/${session.endDate!.year}'
                          : 'Not set',
                      Icons.event
                  ),
                  const SizedBox(height: 24),

                  // Booking Status Section
                  _buildDisplaySection('Booking Status'),
                  const SizedBox(height: 16),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: session.isBooked ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: session.isBooked ? Colors.green : Colors.grey,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          session.isBooked ? Icons.check_circle : Icons.pending,
                          color: session.isBooked ? Colors.green : Colors.grey,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          session.isBooked ? 'Booked' : 'Not Booked',
                          style: TextStyle(
                            color: session.isBooked ? Colors.green : Colors.grey,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Close Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDisplaySection(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildDisplayItem(String label, String value, IconData icon) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2D2D),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFF404040)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.grey, size: 20),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, Session session, SessionViewModel vm) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Course'),
          content: Text(
              'Are you sure you want to delete "${session.title}"? This action cannot be undone.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                vm.deleteSession(session.id);
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.indigo),
          const SizedBox(width: 12),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    return date != null
        ? '${date.day}/${date.month}/${date.year}'
        : 'Not set';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_circle, size: 80, color: Colors.grey[400]),
          const SizedBox(height: 20),
          const Text(
            'No Courses Created Yet',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          const Text('Tap the + button to create your first course'),
        ],
      ),
    );
  }
}
