import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final String bookingId;
  final String studentId;
  final String instructorId;
  final DateTime createdAt;

  ChatRoom({
    required this.id,
    required this.bookingId,
    required this.studentId,
    required this.instructorId,
    required this.createdAt,
  });

  factory ChatRoom.fromMap(Map<String, dynamic> map, String id) {
    return ChatRoom(
      id: id,
      bookingId: map['bookingId'] ?? '',
      studentId: map['studentId'] ?? '',
      instructorId: map['instructorId'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'studentId': studentId,
      'instructorId': instructorId,
      'createdAt': createdAt,
    };
  }
}
