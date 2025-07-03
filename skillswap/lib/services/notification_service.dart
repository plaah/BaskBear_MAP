import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'notifications';

  // Send notification (call this when a booking is requested)
  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _firestore.collection(_collection).add(notification.toMap());
    } catch (e) {
      print('Error sending notification: $e');
      rethrow;
    }
  }

  // Fetch notifications for instructor - FIXED VERSION
  Future<List<NotificationModel>> getNotificationsForInstructor(
    String instructorId,
  ) async {
    try {
      // Option A: Remove orderBy temporarily (quick fix)
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('instructorId', isEqualTo: instructorId)
              .get();

      var notifications =
          snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();

      // Sort in Dart instead of Firestore
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  // Alternative method with limit to avoid large queries
  Future<List<NotificationModel>> getRecentNotificationsForInstructor(
    String instructorId, {
    int limit = 20,
  }) async {
    try {
      final snapshot =
          await _firestore
              .collection(_collection)
              .where('instructorId', isEqualTo: instructorId)
              .limit(limit)
              .get();

      var notifications =
          snapshot.docs
              .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
              .toList();

      // Sort by date in Dart
      notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      return notifications;
    } catch (e) {
      print('Error fetching notifications: $e');
      rethrow;
    }
  }

  // Mark as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).update({
        'isRead': true,
      });
    } catch (e) {
      print('Error marking notification as read: $e');
      rethrow;
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore.collection(_collection).doc(notificationId).delete();
    } catch (e) {
      print('Error deleting notification: $e');
      rethrow;
    }
  }

  // Stream notifications for real-time updates (bonus)
  Stream<List<NotificationModel>> streamNotificationsForInstructor(
    String instructorId,
  ) {
    return _firestore
        .collection(_collection)
        .where('instructorId', isEqualTo: instructorId)
        .snapshots()
        .map((snapshot) {
          var notifications =
              snapshot.docs
                  .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
                  .toList();

          // Sort by date
          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return notifications;
        });
  }

