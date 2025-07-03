import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../models/session_model.dart';
import '../../models/booking_model.dart';

class InstructorTimetableScreen extends StatefulWidget {
  final String instructorId;
  final String instructorName;

  const InstructorTimetableScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
  });

  @override
  State<InstructorTimetableScreen> createState() =>
      _InstructorTimetableScreenState();
}

class _InstructorTimetableScreenState extends State<InstructorTimetableScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  bool _isLoading = true;
  List<Session> _sessions = [];
  List<BookingModel> _bookings = [];

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch sessions for this instructor
      final sessionsSnapshot =
          await FirebaseFirestore.instance
              .collection('sessions')
              .where('instructorId', isEqualTo: widget.instructorId)
              .get();
      _sessions =
          sessionsSnapshot.docs
              .map((doc) => Session.fromMap(doc.data(), doc.id))
              .toList();

      // Fetch bookings for those sessions
      final sessionIds = _sessions.map((s) => s.id).toList();
      if (sessionIds.isNotEmpty) {
        final bookingsSnapshot =
            await FirebaseFirestore.instance
                .collection('bookings')
                .where('sessionId', whereIn: sessionIds)
                .orderBy('bookingDate', descending: false)
                .get();
        _bookings =
            bookingsSnapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                .toList();
      } else {
        _bookings = [];
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load timetable: $e')));
    }
    setState(() => _isLoading = false);
  }

  Map<DateTime, List<Session>> _groupSessionsByDate() {
    Map<DateTime, List<Session>> grouped = {};
    for (var session in _sessions) {
      final date = DateTime(
        session.startDate.year,
        session.startDate.month,
        session.startDate.day,
      );
      grouped.putIfAbsent(date, () => []).add(session);
    }
    return grouped;
  }

  List<Session> _getSessionsForDay(DateTime day) {
    final date = DateTime(day.year, day.month, day.day);
    return _groupSessionsByDate()[date] ?? [];
  }

  List<BookingModel> _getBookingsForSession(String sessionId) {
    return _bookings.where((b) => b.sessionId == sessionId).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.instructorName}\'s Timetable'),
        centerTitle: true,
        backgroundColor: const Color(0xFF1565c0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _fetchData,
          ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 198, 225, 255),
              Color.fromARGB(255, 75, 111, 162),
              Color(0xFF1565c0),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Column(
                    children: [
                      _buildCalendar(),
                      const Divider(height: 0),
                      Expanded(child: _buildSessionList()),
                    ],
                  ),
        ),
      ),
    );
  }

  Widget _buildCalendar() {
    final events = _groupSessionsByDate();
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      color: Colors.white,
      child: TableCalendar<Session>(
        firstDay: DateTime(2020),
        lastDay: DateTime(2030),
        focusedDay: _focusedDay,
        calendarFormat: _calendarFormat,
        selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
        onDaySelected: (selectedDay, focusedDay) {
          setState(() {
            _selectedDay = selectedDay;
            _focusedDay = focusedDay;
          });
        },
        onFormatChanged: (format) {
          if (_calendarFormat != format) {
            setState(() {
              _calendarFormat = format;
            });
          }
        },
        onPageChanged: (focusedDay) {
          _focusedDay = focusedDay;
        },
        eventLoader:
            (day) => events[DateTime(day.year, day.month, day.day)] ?? [],
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(
            color: Color(0xFF5B81F7),
            shape: BoxShape.circle,
          ),
          selectedDecoration: BoxDecoration(
            color: Color(0xFFF76B6B),
            shape: BoxShape.circle,
          ),
          markerDecoration: BoxDecoration(
            color: Color(0xFF1565c0),
            shape: BoxShape.circle,
          ),
          outsideDaysVisible: false,
        ),
        headerStyle: const HeaderStyle(
          formatButtonVisible: true,
          titleCentered: true,
          titleTextStyle: TextStyle(
            color: Color(0xFF1565c0),
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildSessionList() {
    final sessions = _getSessionsForDay(_selectedDay ?? DateTime.now());
    if (sessions.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.event_busy, size: 56, color: Colors.blue.shade200),
              const SizedBox(height: 16),
              const Text(
                'No sessions for this day.',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.builder(
      itemCount: sessions.length,
      itemBuilder: (context, idx) {
        final session = sessions[idx];
        final bookings = _getBookingsForSession(session.id);
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 3,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Color(0xFF1565c0),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  session.isOnline
                      ? 'Online'
                      : (session.location ?? 'Location TBD'),
                  style: TextStyle(
                    color: Colors.blueGrey.shade600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      size: 16,
                      color: Colors.blueGrey.shade500,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_formatTime(session.startDate)} - ${session.endDate != null ? _formatTime(session.endDate!) : 'End?'}',
                      style: const TextStyle(fontSize: 14),
                    ),
                  ],
                ),
                const Divider(height: 24),
                Text(
                  'Bookings:',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Colors.blueGrey.shade700,
                  ),
                ),
                if (bookings.isEmpty)
                  const Padding(
                    padding: EdgeInsets.only(top: 8.0),
                    child: Text(
                      'No bookings yet.',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ...bookings.map(
                  (b) => ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.person, color: Color(0xFF1565c0)),
                    title: Text(
                      b.userId,
                      style: const TextStyle(fontWeight: FontWeight.w500),
                    ),
                    subtitle: Text(
                      'Status: ${b.status}\nBooked at: ${_formatDateTime(b.bookingDate)}',
                      style: const TextStyle(fontSize: 13),
                    ),
                    trailing: Icon(
                      _getStatusIcon(b.status),
                      color: _getStatusColor(b.status),
                    ),
                    onTap: () => _showBookingDetails(b, session),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showBookingDetails(BookingModel booking, Session session) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color.fromARGB(255, 75, 111, 162),
                        Color(0xFF1565c0),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.info, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Booking Details',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDetailRow(Icons.school, 'Session', session.title),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.person, 'Student ID', booking.userId),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    Icons.calendar_today,
                    'Booking Date',
                    _formatDateTime(booking.bookingDate),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow(Icons.info, 'Status', booking.status),
                  const SizedBox(height: 12),
                  _buildDetailRow(
                    booking.paymentStatus ? Icons.check_circle : Icons.pending,
                    'Payment',
                    booking.paymentStatus ? 'Paid' : 'Unpaid',
                    valueColor:
                        booking.paymentStatus ? Colors.green : Colors.orange,
                  ),
                  if (booking.additionalNotes != null &&
                      booking.additionalNotes!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      Icons.note,
                      'Notes',
                      booking.additionalNotes!,
                    ),
                  ],
                ],
              ),
            ),
            actions: [
              Container(
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color.fromARGB(255, 75, 111, 162),
                      Color(0xFF1565c0),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                  ),
                  child: const Text(
                    'Close',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Widget _buildDetailRow(
    IconData icon,
    String label,
    String value, {
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color.fromARGB(255, 75, 111, 162), Color(0xFF1565c0)],
            ),
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: Color(0xFF2c3e50),
            fontSize: 14,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: valueColor ?? Colors.grey.shade700,
              fontWeight:
                  valueColor != null ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';

  String _formatDateTime(DateTime dt) =>
      '${dt.day}/${dt.month}/${dt.year} at ${_formatTime(dt)}';

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return const Color(0xFF1565c0);
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.pending;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }
}
