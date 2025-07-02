import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String bookingId;
  final String userId;
  final String userName;
  final String instructorId;
  final DateTime createdAt;
  final bool isRead;

  NotificationModel({
    required this.id,
    required this.bookingId,
    required this.userId,
    required this.userName,
    required this.instructorId,
    required this.createdAt,
    this.isRead = false,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      bookingId: map['bookingId'],
      userId: map['userId'],
      userName: map['userName'],
      instructorId: map['instructorId'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'bookingId': bookingId,
      'userId': userId,
      'userName': userName,
      'instructorId': instructorId,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
    };
  }
}