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
                    // Navigate to edit screen or open edit dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Edit ${session.title}')),
                    );
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
