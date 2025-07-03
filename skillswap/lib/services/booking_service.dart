import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:skillswap/models/booking_model.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final NotificationService _notificationService = NotificationService();

  // Create a new booking AND send notification to instructor
  Future<void> createBooking(BookingModel booking) async {
    try {
      // Create the booking first
      await _firestore
          .collection('bookings')
          .doc(booking.id)
          .set(booking.toMap());

      // Get the session details to find the instructor
      final sessionDoc =
          await _firestore.collection('sessions').doc(booking.sessionId).get();
      if (sessionDoc.exists) {
        final sessionData = sessionDoc.data()!;
        final instructorId = sessionData['instructorId'] as String;

        // Get current user info
        final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser != null) {
          // Create notification for instructor
          final notification = NotificationModel(
            id: '', // Firestore will generate this
            bookingId: booking.id,
            userId: currentUser.uid,
            userName: currentUser.displayName ?? 'Unknown Student',
            instructorId: instructorId,
            createdAt: DateTime.now(),
            isRead: false,
          );

          // Send notification to instructor
          await _notificationService.sendNotification(notification);
          print(
            'Booking created and notification sent to instructor: $instructorId',
          );
        }
      }
    } catch (e) {
      print('Error in createBooking: $e');
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update the status of a booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'status': status,
      });
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update the payment status of a booking
  Future<void> updatePaymentStatus(String bookingId, bool paymentStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({
        'paymentStatus': paymentStatus,
      });
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Retrieve a single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final snapshot =
          await _firestore.collection('bookings').doc(bookingId).get();
      if (snapshot.exists) {
        return BookingModel.fromMap(snapshot.data()!, snapshot.id);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception('Failed to retrieve booking: $e');
    }
  }

  // Retrieve all bookings for a user
  Future<List<BookingModel>> getBookingsByUserId(String userId) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('bookings')
              .where('userId', isEqualTo: userId)
              .get();
      return querySnapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve bookings for user: $e');
    }
  }

  // Retrieve all bookings for an instructor
  Future<List<BookingModel>> getBookingsByInstructorId(
    String instructorId,
  ) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('bookings')
              .where('instructorId', isEqualTo: instructorId)
              .get();
      return querySnapshot.docs
          .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to retrieve bookings for instructor: $e');
    }
  }

  // Get bookings by instructor through sessions
  Future<List<BookingModel>> getBookingsForInstructorSessions(
    String instructorId,
  ) async {
    try {
      // First get all sessions for this instructor
      final sessionsSnapshot =
          await _firestore
              .collection('sessions')
              .where('instructorId', isEqualTo: instructorId)
              .get();

      if (sessionsSnapshot.docs.isEmpty) {
        return [];
      }

      // Get all session IDs
      final sessionIds = sessionsSnapshot.docs.map((doc) => doc.id).toList();

      // Get bookings for these sessions
      List<BookingModel> allBookings = [];
      for (String sessionId in sessionIds) {
        final bookingsSnapshot =
            await _firestore
                .collection('bookings')
                .where('sessionId', isEqualTo: sessionId)
                .get();

        final bookings =
            bookingsSnapshot.docs
                .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
                .toList();

        allBookings.addAll(bookings);
      }

      // Sort by booking date (newest first)
      allBookings.sort((a, b) => b.bookingDate.compareTo(a.bookingDate));

      return allBookings;
    } catch (e) {
      throw Exception(
        'Failed to retrieve bookings for instructor sessions: $e',
      );
    }
  }

  // Delete a booking by ID
  Future<void> deleteBooking(String bookingId) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).delete();
    } catch (e) {
      throw Exception('Failed to delete booking: $e');
    }
  }

  // Update arbitrary fields of a booking
  Future<void> updateBookingFields(String bookingId, Map<String, dynamic> fields) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update(fields);
    } catch (e) {
      throw Exception('Failed to update booking fields: $e');
    }
  }

  // Update payment status by userId and sessionId
  Future<void> updatePaymentStatusByUserAndSession(String userId, String sessionId, bool paymentStatus) async {
    try {
      final query = await _firestore
        .collection('bookings')
        .where('userId', isEqualTo: userId)
        .where('sessionId', isEqualTo: sessionId)
        .limit(1)
        .get();
      if (query.docs.isNotEmpty) {
        await _firestore.collection('bookings').doc(query.docs.first.id).update({'paymentStatus': paymentStatus});
      }
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }
}
