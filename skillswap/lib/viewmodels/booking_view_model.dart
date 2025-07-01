import 'package:flutter/material.dart';
import 'package:skillswap/models/booking_model.dart';
import 'package:skillswap/services/booking_service.dart';

class BookingViewModel with ChangeNotifier {
  final BookingService _bookingService = BookingService();
  List<BookingModel> _bookings = [];
  BookingModel? _selectedBooking;
  bool _isLoading = false;

  List<BookingModel> get bookings => _bookings;
  BookingModel? get selectedBooking => _selectedBooking;
  bool get isLoading => _isLoading;

  // Fetch all bookings for a user
  Future<void> fetchBookingsByUserId(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _bookings = await _bookingService.getBookingsByUserId(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      throw Exception('Failed to fetch bookings: $e');
    }
  }

  // Fetch all bookings for an instructor (updated to use sessions)
  Future<void> loadInstructorBookings(String instructorId) async {
    try {
      _isLoading = true;
      notifyListeners();

      // Use the new method that gets bookings through sessions
      _bookings = await _bookingService.getBookingsForInstructorSessions(
        instructorId,
      );

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      notifyListeners();
      print('Error loading instructor bookings: $e');
      throw Exception('Failed to fetch instructor bookings: $e');
    }
  }

  // Fetch a single booking by ID
  Future<void> fetchBookingById(String bookingId) async {
    try {
      _selectedBooking = await _bookingService.getBookingById(bookingId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to fetch booking: $e');
    }
  }

  // Create a new booking (this will now send notification automatically)
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _bookingService.createBooking(booking);
      _bookings.add(booking);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update the status of a booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _bookingService.updateBookingStatus(bookingId, status);
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(status: status);
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update the payment status of a booking
  Future<void> updatePaymentStatus(String bookingId, bool paymentStatus) async {
    try {
      await _bookingService.updatePaymentStatus(bookingId, paymentStatus);
      final index = _bookings.indexWhere((booking) => booking.id == bookingId);
      if (index != -1) {
        _bookings[index] = _bookings[index].copyWith(
          paymentStatus: paymentStatus,
        );
      }
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Delete a booking
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _bookingService.deleteBooking(bookingId);
      _bookings.removeWhere((booking) => booking.id == bookingId);
      notifyListeners();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }
}
