import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:skillswap/models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Create a new booking
  Future<void> createBooking(BookingModel booking) async {
    try {
      await _firestore.collection('bookings').doc(booking.id).set(booking.toMap());
    } catch (e) {
      throw Exception('Failed to create booking: $e');
    }
  }

  // Update the status of a booking
  Future<void> updateBookingStatus(String bookingId, String status) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({'status': status});
    } catch (e) {
      throw Exception('Failed to update booking status: $e');
    }
  }

  // Update the payment status of a booking
  Future<void> updatePaymentStatus(String bookingId, bool paymentStatus) async {
    try {
      await _firestore.collection('bookings').doc(bookingId).update({'paymentStatus': paymentStatus});
    } catch (e) {
      throw Exception('Failed to update payment status: $e');
    }
  }

  // Retrieve a single booking by ID
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final snapshot = await _firestore.collection('bookings').doc(bookingId).get();
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
      final querySnapshot = await _firestore.collection('bookings').where('userId', isEqualTo: userId).get();
      return querySnapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve bookings for user: $e');
    }
  }

  // Retrieve all bookings for an instructor
  Future<List<BookingModel>> getBookingsByInstructorId(String instructorId) async {
    try {
      final querySnapshot = await _firestore.collection('bookings').where('instructorId', isEqualTo: instructorId).get();
      return querySnapshot.docs.map((doc) => BookingModel.fromMap(doc.data(), doc.id)).toList();
    } catch (e) {
      throw Exception('Failed to retrieve bookings for instructor: $e');
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