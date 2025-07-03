import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/booking_view_model.dart';
import '../../models/booking_model.dart';
import '../../models/session_model.dart';

class InstructorCalendarScreen extends StatefulWidget {
  final String instructorId;
  const InstructorCalendarScreen({Key? key, required this.instructorId}) : super(key: key);

  @override
  State<InstructorCalendarScreen> createState() => _InstructorCalendarScreenState();
}

class _InstructorCalendarScreenState extends State<InstructorCalendarScreen> {
  CalendarFormat _calendarFormat = CalendarFormat.month;
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay;
  Map<DateTime, List<BookingModel>> _events = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BookingViewModel>().fetchInstructorBookings(widget.instructorId);
    });
  }

  List<BookingModel> _getEventsForDay(DateTime day) {
    return _events[DateTime(day.year, day.month, day.day)] ?? [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Instructor Calendar'),
        backgroundColor: const Color(0xFF667eea),
        actions: [
          IconButton(
            icon: Icon(_calendarFormat == CalendarFormat.month ? Icons.view_week : Icons.calendar_month),
            onPressed: () {
              setState(() {
                _calendarFormat = _calendarFormat == CalendarFormat.month ? CalendarFormat.week : CalendarFormat.month;
              });
            },
            tooltip: _calendarFormat == CalendarFormat.month ? 'Weekly View' : 'Monthly View',
          ),
        ],
      ),
      body: Consumer<BookingViewModel>(
        builder: (context, vm, _) {
          if (vm.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (vm.error != null) {
            return Center(child: Text('Error: ${vm.error}'));
          }
          if (vm.bookings.isEmpty) {
            return const Center(child: Text('No sessions found.'));
          }
          // Group bookings by date
          _events = {};
          for (var booking in vm.bookings) {
            final date = DateTime(booking.bookingDate.year, booking.bookingDate.month, booking.bookingDate.day);
            _events.putIfAbsent(date, () => []).add(booking);
          }
          return Column(
            children: [
              TableCalendar<BookingModel>(
                firstDay: DateTime.utc(2020, 1, 1),
                lastDay: DateTime.utc(2100, 12, 31),
                focusedDay: _focusedDay,
                calendarFormat: _calendarFormat,
                selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
                eventLoader: _getEventsForDay,
                onDaySelected: (selectedDay, focusedDay) {
                  setState(() {
                    _selectedDay = selectedDay;
                    _focusedDay = focusedDay;
                  });
                },
                calendarStyle: const CalendarStyle(
                  markerDecoration: BoxDecoration(
                    color: Color(0xFF667eea),
                    shape: BoxShape.circle,
                  ),
                ),
                headerStyle: const HeaderStyle(
                  formatButtonVisible: false,
                  titleCentered: true,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _selectedDay == null || _getEventsForDay(_selectedDay!).isEmpty
                    ? const Center(child: Text('No sessions on this day.'))
                    : ListView(
                        children: _getEventsForDay(_selectedDay!).map((booking) {
                          // You may want to fetch session details for each booking
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            child: ListTile(
                              title: Text('Session: ${booking.sessionId}'), // Replace with session title if available
                              subtitle: Text('Time: ${booking.bookingDate.hour.toString().padLeft(2, '0')}:${booking.bookingDate.minute.toString().padLeft(2, '0')}'),
                              trailing: Text(booking.status),
                            ),
                          );
                        }).toList(),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
} 