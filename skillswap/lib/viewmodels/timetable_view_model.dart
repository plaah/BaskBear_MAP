import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/session_model.dart';

class TimetableViewModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  
  List<Session> _instructorSessions = [];
  bool _isLoading = false;
  String? _error;
  DateTime _selectedDate = DateTime.now();

  List<Session> get instructorSessions => _instructorSessions;
  bool get isLoading => _isLoading;
  String? get error => _error;
  DateTime get selectedDate => _selectedDate;

  // Set selected date
  void setSelectedDate(DateTime date) {
    _selectedDate = date;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Get sessions with booking status for instructor
  Future<void> loadInstructorTimetable(String instructorId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final snapshot = await _firestore
          .collection('sessions')
          .where('instructorId', isEqualTo: instructorId)
          .orderBy('startDate', descending: false)
          .get();

      _instructorSessions = snapshot.docs.map((doc) {
        return Session.fromMap(doc.data(), doc.id);
      }).toList();

    } catch (e) {
      _error = 'Failed to load timetable: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load timetable for current user
  Future<void> loadCurrentUserTimetable() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      _error = 'User not authenticated';
      notifyListeners();
      return;
    }
    
    await loadInstructorTimetable(currentUser.uid);
  }

  // Get sessions grouped by status
  Map<String, List<Session>> get sessionsByStatus {
    Map<String, List<Session>> grouped = {
      'available': [],
      'booked': [],
      'completed': [],
      'cancelled': [],
    };

    for (Session session in _instructorSessions) {
      if (session.isBooked && session.enrolledStudentId != null) {
        grouped['booked']!.add(session);
      } else if (session.status == 'completed') {
        grouped['completed']!.add(session);
      } else if (session.status == 'cancelled') {
        grouped['cancelled']!.add(session);
      } else {
        grouped['available']!.add(session);
      }
    }

    return grouped;
  }

  // Get upcoming booked sessions
  List<Session> get upcomingBookedSessions {
    final now = DateTime.now();
    return _instructorSessions
        .where((session) => 
            session.isBooked && 
            session.startDate.isAfter(now) &&
            session.status == 'scheduled')
        .toList()
        ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  // Get sessions for a specific date
  List<Session> getSessionsForDate(DateTime date) {
    return _instructorSessions.where((session) {
      return session.startDate.year == date.year &&
             session.startDate.month == date.month &&
             session.startDate.day == date.day;
    }).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  // Get sessions for selected date
  List<Session> get sessionsForSelectedDate {
    return getSessionsForDate(_selectedDate);
  }

  // Get today's sessions
  List<Session> get todaySessions {
    final today = DateTime.now();
    return getSessionsForDate(today);
  }

  // Get this week's sessions
  List<Session> get thisWeekSessions {
    final now = DateTime.now();
    final startOfWeek = now.subtract(Duration(days: now.weekday - 1));
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    
    return _instructorSessions.where((session) {
      return session.startDate.isAfter(startOfWeek) &&
             session.startDate.isBefore(endOfWeek.add(const Duration(days: 1)));
    }).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  // Get this month's sessions
  List<Session> get thisMonthSessions {
    final now = DateTime.now();
    return _instructorSessions.where((session) {
      return session.startDate.year == now.year &&
             session.startDate.month == now.month;
    }).toList()
    ..sort((a, b) => a.startDate.compareTo(b.startDate));
  }

  // Get available sessions count
  int get availableSessionsCount {
    return _instructorSessions
        .where((session) => !session.isBooked && session.status == 'scheduled')
        .length;
  }

  // Get booked sessions count
  int get bookedSessionsCount {
    return _instructorSessions
        .where((session) => session.isBooked && session.enrolledStudentId != null)
        .length;
  }

  // Get completed sessions count
  int get completedSessionsCount {
    return _instructorSessions
        .where((session) => session.status == 'completed')
        .length;
  }

  // Get total earnings from completed sessions
  double get totalEarnings {
    return _instructorSessions
        .where((session) => session.status == 'completed')
        .fold(0.0, (sum, session) => sum + session.price);
  }

  // Get pending earnings (booked but not completed)
  double get pendingEarnings {
    return _instructorSessions
        .where((session) => session.isBooked && session.status == 'scheduled')
        .fold(0.0, (sum, session) => sum + session.price);
  }

  // Mark session as completed
  Future<void> markSessionCompleted(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'completed',
        'updatedAt': Timestamp.now(),
      });
      
      // Update local list
      final sessionIndex = _instructorSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        _instructorSessions[sessionIndex] = _instructorSessions[sessionIndex].copyWith(
          status: 'completed',
          updatedAt: DateTime.now(),
        );
      }
      
    } catch (e) {
      _error = 'Failed to mark session as completed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cancel session
  Future<void> cancelSession(String sessionId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _firestore.collection('sessions').doc(sessionId).update({
        'status': 'cancelled',
        'enrolledStudentId': null,
        'enrolledStudentName': null,
        'enrolledAt': null,
        'isBooked': false,
        'updatedAt': Timestamp.now(),
      });
      
      // Update local list
      final sessionIndex = _instructorSessions.indexWhere((s) => s.id == sessionId);
      if (sessionIndex != -1) {
        _instructorSessions[sessionIndex] = _instructorSessions[sessionIndex].copyWith(
          status: 'cancelled',
          enrolledStudentId: null,
          enrolledStudentName: null,
          enrolledAt: null,
          isBooked: false,
          updatedAt: DateTime.now(),
        );
      }
      
    } catch (e) {
      _error = 'Failed to cancel session: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get session status color
  Color getSessionStatusColor(Session session) {
    if (session.isBooked && session.enrolledStudentId != null) {
      return Colors.green;
    } else if (session.status == 'completed') {
      return Colors.blue;
    } else if (session.status == 'cancelled') {
      return Colors.red;
    } else {
      return Colors.orange;
    }
  }

  // Get session status text
  String getSessionStatusText(Session session) {
    if (session.isBooked && session.enrolledStudentId != null) {
      return 'Booked';
    } else if (session.status == 'completed') {
      return 'Completed';
    } else if (session.status == 'cancelled') {
      return 'Cancelled';
    } else {
      return 'Available';
    }
  }

  // Get session status icon
  IconData getSessionStatusIcon(Session session) {
    if (session.isBooked && session.enrolledStudentId != null) {
      return Icons.person;
    } else if (session.status == 'completed') {
      return Icons.check_circle;
    } else if (session.status == 'cancelled') {
      return Icons.cancel;
    } else {
      return Icons.event_available;
    }
  }

  // Check if session is in the past
  bool isSessionInPast(Session session) {
    final now = DateTime.now();
    final sessionEnd = session.startDate.add(Duration(hours: session.durationHours));
    return sessionEnd.isBefore(now);
  }

  // Check if session is happening now
  bool isSessionHappeningNow(Session session) {
    final now = DateTime.now();
    final sessionEnd = session.startDate.add(Duration(hours: session.durationHours));
    return session.startDate.isBefore(now) && sessionEnd.isAfter(now);
  }

  // Refresh timetable
  Future<void> refreshTimetable() async {
    await loadCurrentUserTimetable();
  }
}