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
      child: ExpansionTile(
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
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(Icons.category, size: 14, color: Colors.grey[600]),
                const SizedBox(width: 4),
                Text(session.category),
              ],
            ),
          ],
        ),
        trailing: Chip(
          label: Text(session.isBooked ? 'Booked' : 'Not booked'),
          backgroundColor: session.isBooked ? Colors.green[100] : Colors.grey[200],
          labelStyle: TextStyle(
            color: session.isBooked ? Colors.green[800] : Colors.grey[800],
          ),
        ),
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
