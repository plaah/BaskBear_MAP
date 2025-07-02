import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/models/earnings_model.dart';
import '../../models/booking_model.dart';
import '../../models/session_model.dart';
import '../services/earnings_service.dart';

enum TimePeriod { all, today, week, month }

class EarningsViewModel extends ChangeNotifier {
  final EarningsService _earningsService = EarningsService();
  
  // State
  EarningsData? _earningsData;
  List<BookingModel> _allBookings = [];
  List<Session> _instructorSessions = [];
  bool _isLoading = false;
  String? _errorMessage;
  TimePeriod _selectedPeriod = TimePeriod.all;

  // Getters
  EarningsData? get earningsData => _earningsData;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  TimePeriod get selectedPeriod => _selectedPeriod;
  List<Session> get instructorSessions => _instructorSessions;

  Future<void> loadEarningsData() async {
    final currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    _setLoading(true);
    _clearError();

    try {
      // Load sessions and bookings
      _instructorSessions = await _earningsService.getInstructorSessions(currentUser.uid);
      final sessionIds = _instructorSessions.map((s) => s.id).toList();
      _allBookings = await _earningsService.getBookingsForSessions(sessionIds);
      
      // Calculate earnings
      _calculateEarnings();
      
    } catch (e) {
      _setError('Failed to load earnings data: $e');
    } finally {
      _setLoading(false);
    }
  }

  void updateTimePeriod(TimePeriod period) {
    _selectedPeriod = period;
    _calculateEarnings();
    notifyListeners();
  }

  void _calculateEarnings() {
    final filteredBookings = _getFilteredBookings();
    
    double totalEarnings = 0.0;
    double pendingEarnings = 0.0;
    double confirmedEarnings = 0.0;
    double completedEarnings = 0.0;
    int paidBookings = 0;

    for (final booking in filteredBookings) {
      final session = _getSessionForBooking(booking.sessionId);
      if (session != null) {
        final sessionPrice = session.price;
        
        switch (booking.status) {
          case 'pending':
            pendingEarnings += sessionPrice;
            break;
          case 'confirmed':
            confirmedEarnings += sessionPrice;
            break;
          case 'completed':
            completedEarnings += sessionPrice;
            break;
        }

        if (booking.paymentStatus) {
          paidBookings++;
          totalEarnings += sessionPrice;
        }
      }
    }

    _earningsData = EarningsData(
      totalEarnings: totalEarnings,
      pendingEarnings: pendingEarnings,
      confirmedEarnings: confirmedEarnings,
      completedEarnings: completedEarnings,
      totalBookings: filteredBookings.length,
      paidBookings: paidBookings,
      recentBookings: filteredBookings.take(5).toList(),
    );
    
    notifyListeners();
  }

  List<BookingModel> _getFilteredBookings() {
    final now = DateTime.now();
    
    switch (_selectedPeriod) {
      case TimePeriod.today:
        return _allBookings.where((b) => 
          b.bookingDate.year == now.year &&
          b.bookingDate.month == now.month &&
          b.bookingDate.day == now.day
        ).toList();
      case TimePeriod.week:
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        final weekEnd = weekStart.add(const Duration(days: 6, hours: 23, minutes: 59));
        return _allBookings.where((b) => 
          b.bookingDate.isAfter(weekStart.subtract(const Duration(days: 1))) && 
          b.bookingDate.isBefore(weekEnd.add(const Duration(days: 1)))
        ).toList();
      case TimePeriod.month:
        return _allBookings.where((b) => 
          b.bookingDate.year == now.year && b.bookingDate.month == now.month
        ).toList();
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

  double getAverageSessionPrice() {
    if (_instructorSessions.isEmpty) return 0.0;
    final total = _instructorSessions.map((s) => s.price).reduce((a, b) => a + b);
    return total / _instructorSessions.length;
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}

