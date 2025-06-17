import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:skillswap/views/auth/login_screen.dart';
import 'package:skillswap/firebase_options.dart';
import '../../viewmodels/session_view_model.dart';
import '../../models/session_model.dart';

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
