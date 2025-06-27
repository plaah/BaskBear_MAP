import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skillswap/views/auth/login_screen.dart';
import 'package:skillswap/firebase_options.dart';
import '../../viewmodels/session_view_model.dart';
import '../../models/session_model.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../models/booking_model.dart';
import '../../widgets/empty_state.dart';

class TimetableScreen extends StatefulWidget {
  const TimetableScreen({super.key});

  @override
  State<TimetableScreen> createState() => _TimetableScreenState();
}

class _TimetableScreenState extends State<TimetableScreen> {
  Future<void> _initializeFirebase() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }

  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  late ValueNotifier<List<Session>> _selectedEvents;

  Map<DateTime, List<Session>> _groupSessionsByDate(List<Session> sessions) {
    Map<DateTime, List<Session>> grouped = {};
    for (var session in sessions) {
      // No null check or '!' needed if startDate is non-nullable
      final date = DateTime(
        session.startDate.year,
        session.startDate.month,
        session.startDate.day,
      );
      if (grouped[date] == null) grouped[date] = [];
      grouped[date]!.add(session);
    }
    return grouped;
  }

  List<Session> _getEventsForDay(
    DateTime day,
    Map<DateTime, List<Session>> events,
  ) {
    return events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  void initState() {
    super.initState();
    _selectedDay = _focusedDay;
    _selectedEvents = ValueNotifier([]);
  }

  @override
  void dispose() {
    _selectedEvents.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, authSnapshot) {
            if (authSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }
            if (!authSnapshot.hasData) {
              return const LoginScreen();
            }
            return Scaffold(
              appBar: AppBar(
                title: const Text(
                  'Timetable',
                  style: TextStyle(
                    color: Color(0xFF222B45),
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
                backgroundColor: const Color.fromARGB(255, 156, 204, 254),
                elevation: 0,
                centerTitle: true,
                iconTheme: const IconThemeData(color: Color(0xFF222B45)),
                actions: [
                  IconButton(
                    icon: Icon(
                      _calendarFormat == CalendarFormat.month
                          ? Icons.view_week
                          : Icons.calendar_month,
                      color: const Color(0xFF222B45),
                    ),
                    onPressed: () {
                      setState(() {
                        _calendarFormat =
                            _calendarFormat == CalendarFormat.month
                                ? CalendarFormat.week
                                : CalendarFormat.month;
                      });
                    },
                    tooltip:
                        _calendarFormat == CalendarFormat.month
                            ? 'Switch to Week View'
                            : 'Switch to Month View',
                  ),
                ],
              ),
              body: Container(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(255, 160, 204, 255),
                ),
                child: Consumer<SessionViewModel>(
                  builder: (context, viewModel, _) {
                    if (viewModel.sessions.isEmpty && !viewModel.isLoading) {
                      return _buildEmptyState();
                    }
                    final events = _groupSessionsByDate(viewModel.sessions);
                    // update selected events for selected day
                    final todayEvents = _getEventsForDay(
                      _selectedDay ?? DateTime.now(),
                      events,
                    );
                    _selectedEvents.value = todayEvents;

                    return Column(
                      children: [
                        Card(
                          margin: const EdgeInsets.all(16),
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          color: Colors.white,
                          child: TableCalendar<Session>(
                            firstDay: DateTime(2020),
                            lastDay: DateTime(2030),
                            focusedDay: _focusedDay,
                            calendarFormat: _calendarFormat,
                            selectedDayPredicate: (day) {
                              return isSameDay(_selectedDay, day);
                            },
                            onDaySelected: (selectedDay, focusedDay) {
                              setState(() {
                                _selectedDay = selectedDay;
                                _focusedDay = focusedDay;
                                _selectedEvents.value = _getEventsForDay(
                                  selectedDay,
                                  events,
                                );
                              });
                              // Show popup with details
                              if (_selectedEvents.value.isNotEmpty) {
                                showDialog(
                                  context: context,
                                  builder:
                                      (context) => AlertDialog(
                                        title: Text(
                                          'Events on ${_formatDate(selectedDay)}',
                                        ),
                                        content: SizedBox(
                                          width: double.maxFinite,
                                          child: ListView(
                                            shrinkWrap: true,
                                            children:
                                                _selectedEvents.value
                                                    .map(
                                                      (session) => ListTile(
                                                        title: Text(
                                                          session.title,
                                                        ),
                                                        subtitle: Text(
                                                          session.description,
                                                        ),
                                                        trailing: Text(
                                                          session.isOnline
                                                              ? 'Online'
                                                              : (session
                                                                      .location ??
                                                                  'Location TBD'),
                                                        ),
                                                      ),
                                                    )
                                                    .toList(),
                                          ),
                                        ),
                                        actions: [
                                          TextButton(
                                            child: const Text('Close'),
                                            onPressed:
                                                () =>
                                                    Navigator.of(context).pop(),
                                          ),
                                        ],
                                      ),
                                );
                              }
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
                            eventLoader: (day) {
                              return events[DateTime(
                                    day.year,
                                    day.month,
                                    day.day,
                                  )] ??
                                  [];
                            },
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
                                color: Color(0xFF5B81F7),
                                shape: BoxShape.circle,
                              ),
                              outsideDaysVisible: false,
                            ),
                            headerStyle: const HeaderStyle(
                              formatButtonVisible: false,
                              titleCentered: true,
                              titleTextStyle: TextStyle(
                                color: Color(0xFF222B45),
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              const Icon(Icons.list, color: Color(0xFF5B81F7)),
                              const SizedBox(width: 8),
                              Text(
                                'Timetable for ${_formatDate(_selectedDay ?? DateTime.now())}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                  color: Color(0xFF222B45),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Expanded(
                          child: ValueListenableBuilder<List<Session>>(
                            valueListenable: _selectedEvents,
                            builder: (context, value, _) {
                              if (value.isEmpty) {
                                return Padding(
                                  padding: const EdgeInsets.all(32.0),
                                  child: Center(
                                    child: Text(
                                      'No events for this day.',
                                      style: TextStyle(
                                        color: const Color.fromARGB(
                                          255,
                                          48,
                                          48,
                                          48,
                                        ),
                                        fontSize: 16,
                                      ),
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                itemCount: value.length,
                                itemBuilder: (context, index) {
                                  final session = value[index];
                                  return TimetableEntry(
                                    time: _formatTimeRange(
                                      session.startDate,
                                      session.endDate,
                                      session.durationHours,
                                    ),
                                    subject: session.title,
                                    location:
                                        session.isOnline
                                            ? 'Online'
                                            : (session.location ??
                                                'Location TBD'),
                                  );
                                },
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.calendar_today_outlined,
            size: 90,
            color: Colors.blue[100],
          ),
          const SizedBox(height: 24),
          const Text(
            'No Courses Available',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF222B45),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Add courses to see your timetable',
            style: TextStyle(
              color: Color.fromARGB(255, 64, 64, 64),
              fontSize: 15,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return 'N/A';
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTimeRange(
    DateTime startDate,
    DateTime? endDate,
    int durationHours,
  ) {
    String start = '${startDate.day}/${startDate.month}/${startDate.year}';
    if (endDate != null) {
      String end = '${endDate.day}/${endDate.month}/${endDate.year}';
      return '$start - $end';
    }
    return '$start (${durationHours}h)';
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
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.access_time, color: Color(0xFF5B81F7), size: 28),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    time,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  Text(
                    subject,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF222B45),
                    ),
                  ),
                  Text(
                    location,
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InstructorTimetableScreen extends StatefulWidget {
  final String instructorId;
  final String instructorName;

  const InstructorTimetableScreen({
    super.key,
    required this.instructorId,
    required this.instructorName,
  });

  @override
  State<InstructorTimetableScreen> createState() => _InstructorTimetableScreenState();
}

class _InstructorTimetableScreenState extends State<InstructorTimetableScreen> {
  DateTime _selectedDate = DateTime.now();
  String _selectedView = 'week'; // 'week' or 'day'

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingViewModel>().loadInstructorBookings(widget.instructorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text('My Timetable'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _selectedDate = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Header with date navigation
          _buildHeader(),
          
          // View toggle
          _buildViewToggle(),
          
          // Timetable content
          Expanded(
            child: Consumer<BookingViewModel>(
              builder: (context, viewModel, child) {
                if (viewModel.isLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                final bookings = _getFilteredBookings(viewModel.bookings);
                
                if (bookings.isEmpty) {
                  return NoBookingsEmptyState(isInstructor: true);
                }

                return _selectedView == 'week' 
                    ? _buildWeekView(bookings)
                    : _buildDayView(bookings);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(
                  _selectedView == 'week' 
                      ? const Duration(days: 7)
                      : const Duration(days: 1)
                );
              });
            },
          ),
          Expanded(
            child: Text(
              _getHeaderText(),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(
                  _selectedView == 'week' 
                      ? const Duration(days: 7)
                      : const Duration(days: 1)
                );
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildViewToggle() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton('Week', 'week'),
          ),
          Expanded(
            child: _buildToggleButton('Day', 'day'),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton(String label, String value) {
    final isSelected = _selectedView == value;
    return GestureDetector(
      onTap: () => setState(() => _selectedView = value),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF667eea) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey.shade600,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  Widget _buildWeekView(List<BookingModel> bookings) {
    final weekStart = _getWeekStart(_selectedDate);
    final weekDays = List.generate(7, (index) => weekStart.add(Duration(days: index)));
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Week days header
        Row(
          children: weekDays.map((date) => Expanded(
            child: _buildDayHeader(date),
          )).toList(),
        ),
        
        const SizedBox(height: 16),
        
        // Week content
        ...weekDays.map((date) => _buildDayColumn(date, bookings)),
      ],
    );
  }

  Widget _buildDayView(List<BookingModel> bookings) {
    final dayBookings = bookings.where((booking) => 
      _isSameDay(booking.bookingDate, _selectedDate)
    ).toList();
    
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Day header
        _buildDayHeader(_selectedDate),
        
        const SizedBox(height: 16),
        
        // Day content
        if (dayBookings.isEmpty)
          Container(
            padding: const EdgeInsets.all(32),
            child: const Center(
              child: Text(
                'No bookings for this day',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
            ),
          )
        else
          ...dayBookings.map((booking) => _buildBookingCard(booking)),
      ],
    );
  }

  Widget _buildDayHeader(DateTime date) {
    final isToday = _isSameDay(date, DateTime.now());
    final isSelected = _isSameDay(date, _selectedDate);
    
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        color: isToday ? const Color(0xFF667eea).withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border: isSelected ? Border.all(color: const Color(0xFF667eea), width: 2) : null,
      ),
      child: Column(
        children: [
          Text(
            _getDayName(date.weekday),
            style: TextStyle(
              fontSize: 12,
              color: isToday ? const Color(0xFF667eea) : Colors.grey.shade600,
              fontWeight: isToday ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${date.day}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              color: isToday ? const Color(0xFF667eea) : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayColumn(DateTime date, List<BookingModel> bookings) {
    final dayBookings = bookings.where((booking) => 
      _isSameDay(booking.bookingDate, date)
    ).toList();
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        children: [
          if (dayBookings.isEmpty)
            Container(
              height: 100,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Text(
                  'No bookings',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ),
            )
          else
            ...dayBookings.map((booking) => _buildBookingCard(booking)),
        ],
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(booking.status).withOpacity(0.1),
          child: Icon(
            _getStatusIcon(booking.status),
            color: _getStatusColor(booking.status),
            size: 20,
          ),
        ),
        title: Text(
          'Session ${booking.sessionId.substring(0, 8)}...',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text(
              'Student ID: ${booking.userId.substring(0, 8)}...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Time: ${_formatTime(booking.bookingDate)}',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: _getStatusColor(booking.status).withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                booking.status,
                style: TextStyle(
                  color: _getStatusColor(booking.status),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) => _handleBookingAction(booking, value),
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility),
                  SizedBox(width: 8),
                  Text('View Details'),
                ],
              ),
            ),
            if (booking.status == 'pending')
              const PopupMenuItem(
                value: 'approve',
                child: Row(
                  children: [
                    Icon(Icons.check, color: Colors.green),
                    SizedBox(width: 8),
                    Text('Approve'),
                  ],
                ),
              ),
            if (booking.status == 'pending')
              const PopupMenuItem(
                value: 'reject',
                child: Row(
                  children: [
                    Icon(Icons.close, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Reject'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  List<BookingModel> _getFilteredBookings(List<BookingModel> allBookings) {
    // Filter out expired bookings
    final now = DateTime.now();
    return allBookings.where((booking) => 
      booking.bookingDate.isAfter(now)
    ).toList();
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: date.weekday - 1));
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year && 
           date1.month == date2.month && 
           date1.day == date2.day;
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String _getHeaderText() {
    if (_selectedView == 'week') {
      final weekStart = _getWeekStart(_selectedDate);
      final weekEnd = weekStart.add(const Duration(days: 6));
      return '${_formatDate(weekStart)} - ${_formatDate(weekEnd)}';
    } else {
      return _formatDate(_selectedDate);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  String _formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      case 'completed':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'confirmed':
        return Icons.check_circle;
      case 'pending':
        return Icons.schedule;
      case 'cancelled':
        return Icons.cancel;
      case 'completed':
        return Icons.done_all;
      default:
        return Icons.info;
    }
  }

  void _handleBookingAction(BookingModel booking, String action) {
    switch (action) {
      case 'view':
        _showBookingDetails(booking);
        break;
      case 'approve':
        _updateBookingStatus(booking, 'confirmed');
        break;
      case 'reject':
        _updateBookingStatus(booking, 'cancelled');
        break;
    }
  }

  void _showBookingDetails(BookingModel booking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              
              // Title
              Text(
                'Booking Details',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Details
              _buildDetailRow('Session', 'Session ${booking.sessionId.substring(0, 8)}...'),
              _buildDetailRow('Student', 'Student ID: ${booking.userId.substring(0, 8)}...'),
              _buildDetailRow('Date', _formatDate(booking.bookingDate)),
              _buildDetailRow('Time', _formatTime(booking.bookingDate)),
              _buildDetailRow('Status', booking.status),
              _buildDetailRow('Payment', booking.paymentStatus ? 'Paid' : 'Pending'),
              
              if (booking.additionalNotes?.isNotEmpty == true) ...[
                const SizedBox(height: 16),
                const Text(
                  'Additional Notes:',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  booking.additionalNotes!,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
              
              const Spacer(),
              
              // Action Buttons
              if (booking.status == 'pending')
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateBookingStatus(booking, 'confirmed');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Approve'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _updateBookingStatus(booking, 'cancelled');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Reject'),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateBookingStatus(BookingModel booking, String newStatus) async {
    try {
      await context.read<BookingViewModel>().updateBookingStatus(
        booking.id,
        newStatus,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Booking ${newStatus.toLowerCase()} successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to update booking: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
