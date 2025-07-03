import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/booking_model.dart';
import '../../models/session_model.dart';

class EarningsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Session>> getInstructorSessions(String instructorId) async {
    final snapshot = await _firestore
        .collection('sessions')
        .where('instructorId', isEqualTo: instructorId)
        .get();

    return snapshot.docs
        .map((doc) => Session.fromMap(doc.data(), doc.id))
        .toList();
  }

  Future<List<BookingModel>> getBookingsForSessions(List<String> sessionIds) async {
    if (sessionIds.isEmpty) return [];

    final snapshot = await _firestore
        .collection('bookings')
        .where('sessionId', whereIn: sessionIds)
        .orderBy('bookingDate', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => BookingModel.fromMap(doc.data(), doc.id))
        .toList();
  }
}


