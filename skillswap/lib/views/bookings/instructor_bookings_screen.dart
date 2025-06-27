import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';
import '../../models/session_model.dart';
import '../../viewmodels/booking_view_model.dart';

class InstructorBookingsScreen extends StatefulWidget {
  const InstructorBookingsScreen({super.key});

  @override
  State<InstructorBookingsScreen> createState() => _InstructorBookingsScreenState();
}

class _InstructorBookingsScreenState extends State<InstructorBookingsScreen> {
  late BookingViewModel _viewModel;
  User? _currentUser;
  List<BookingModel> _allBookings = [];
  List<Session> _instructorSessions = [];
  bool _isLoading = true;
  String _selectedFilter = 'all'; // all, pending, confirmed, completed

  @override
  void initState() {
    super.initState();
    _viewModel = Provider.of<BookingViewModel>(context, listen: false);
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadInstructorBookings();
  }

  Future<void> _loadInstructorBookings() async {
    if (_currentUser == null) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // Get instructor's sessions
      final sessionsSnapshot = await FirebaseFirestore.instance
          .collection('sessions')
          .where('instructorId', isEqualTo: _currentUser!.uid)
          .get();

      _instructorSessions = sessionsSnapshot.docs
          .map((doc) => Session.fromMap(doc.data(), doc.id))
          .toList();

      // Get all bookings for instructor's sessions
      final sessionIds = _instructorSessions.map((s) => s.id).toList();
      
      if (sessionIds.isNotEmpty) {
        final bookingsSnapshot = await FirebaseFirestore.instance
            .collection('bookings')
            .where('sessionId', whereIn: sessionIds)
            .orderBy('bookingDate', descending: true)
            .get();

        _allBookings = bookingsSnapshot.docs
            .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
            .toList();
      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorSnackBar('Failed to load bookings: $e');
    }
  }

  List<BookingModel> get _filteredBookings {
    switch (_selectedFilter) {
      case 'pending':
        return _allBookings.where((b) => b.status == 'pending').toList();
      case 'confirmed':
        return _allBookings.where((b) => b.status == 'confirmed').toList();
      case 'completed':
        return _allBookings.where((b) => b.status == 'completed').toList();
      default:
        return _allBookings;
    }
  }

  Session? _getSessionForBooking(String sessionId) {
    try {
      return _instructorSessions.firstWhere((s) => s.id == sessionId);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Bookings'),
        centerTitle: true,
        backgroundColor: Colors.blueAccent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadInstructorBookings,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                _buildFilterChips(),
                Expanded(
                  child: _filteredBookings.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _filteredBookings.length,
                          itemBuilder: (context, index) {
                            final booking = _filteredBookings[index];
                            final session = _getSessionForBooking(booking.sessionId);
                            return _buildBookingCard(booking, session);
                          },
                        ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('All', 'all'),
            const SizedBox(width: 8),
            _buildFilterChip('Pending', 'pending'),
            const SizedBox(width: 8),
            _buildFilterChip('Confirmed', 'confirmed'),
            const SizedBox(width: 8),
            _buildFilterChip('Completed', 'completed'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      backgroundColor: Colors.grey.shade200,
      selectedColor: Colors.blueAccent,
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking, Session? session) {
    if (session == null) {
      return const SizedBox.shrink(); // Skip if session not found
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              children: [
                Expanded(
                  child: Text(
                    session.title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                _buildStatusChip(booking.status),
              ],
            ),
            const SizedBox(height: 12),
            
            // Booking details
            _buildDetailRow('Student ID', booking.userId),
            _buildDetailRow('Booking Date', _formatDate(booking.bookingDate)),
            _buildDetailRow('Payment', booking.paymentStatus ? 'Paid' : 'Unpaid'),
            if (booking.additionalNotes != null && booking.additionalNotes!.isNotEmpty)
              _buildDetailRow('Notes', booking.additionalNotes!),
            
            const SizedBox(height: 16),
            
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _showBookingDetails(booking, session),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('View Details'),
                  ),
                ),
                const SizedBox(width: 8),
                if (booking.status == 'pending')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _updateBookingStatus(booking.id, 'confirmed'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Confirm'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    IconData icon;
    
    switch (status) {
      case 'pending':
        color = Colors.orange;
        icon = Icons.pending;
        break;
      case 'confirmed':
        color = Colors.blue;
        icon = Icons.check_circle;
        break;
      case 'completed':
        color = Colors.green;
        icon = Icons.done_all;
        break;
      default:
        color = Colors.grey;
        icon = Icons.info;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            status.toUpperCase(),
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.bookmark_border,
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            'No bookings found',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bookings will appear here when students enroll in your sessions',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showBookingDetails(BookingModel booking, Session session) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Booking Details'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDetailRow('Session', session.title),
              _buildDetailRow('Student ID', booking.userId),
              _buildDetailRow('Booking Date', _formatDate(booking.bookingDate)),
              _buildDetailRow('Status', booking.status),
              _buildDetailRow('Payment', booking.paymentStatus ? 'Paid' : 'Unpaid'),
              if (booking.additionalNotes != null && booking.additionalNotes!.isNotEmpty)
                _buildDetailRow('Notes', booking.additionalNotes!),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBookingStatus(String bookingId, String newStatus) async {
    try {
      await _viewModel.updateBookingStatus(bookingId, newStatus);
      
      // Also update session status if needed
      if (newStatus == 'confirmed') {
        // Find the booking to get sessionId
        final booking = _allBookings.firstWhere((b) => b.id == bookingId);
        final session = _getSessionForBooking(booking.sessionId);
        
        if (session != null) {
          await FirebaseFirestore.instance
              .collection('sessions')
              .doc(session.id)
              .update({
            'status': 'confirmed',
            'updatedAt': Timestamp.now(),
          });
        }
      }
      
      _showSuccessSnackBar('Booking status updated successfully!');
      _loadInstructorBookings(); // Refresh the list
    } catch (e) {
      _showErrorSnackBar('Failed to update booking status: $e');
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }
} 