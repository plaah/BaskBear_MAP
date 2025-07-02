import 'package:flutter/foundation.dart';
import '../models/notification_model.dart';
import '../services/notification_service.dart';

class NotificationViewModel with ChangeNotifier {
  final NotificationService _notificationService = NotificationService();

  List<NotificationModel> _notifications = [];
  bool _loading = false;
  String? _error;

  List<NotificationModel> get notifications => _notifications;
  bool get loading => _loading;
  String? get error => _error;

  // Fetch notifications for instructor with better error handling
  Future<void> fetchNotifications(String instructorId) async {
    if (instructorId.isEmpty) {
      _error = 'Invalid instructor ID';
      notifyListeners();
      return;
    }

    _loading = true;
    _error = null;
    notifyListeners();

    try {
      // Use the fixed method
      _notifications = await _notificationService
          .getRecentNotificationsForInstructor(
            instructorId,
            limit: 50, // Limit to recent notifications
          );
      _error = null;
    } catch (e) {
      _error = 'Failed to load notifications: ${e.toString()}';
      _notifications = [];
      debugPrint('Error fetching notifications: $e');
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  // Use stream for real-time updates (optional)
  void startListeningToNotifications(String instructorId) {
    _notificationService
        .streamNotificationsForInstructor(instructorId)
        .listen(
          (notifications) {
            _notifications = notifications;
            _loading = false;
            _error = null;
            notifyListeners();
          },
          onError: (error) {
            _error = 'Stream error: ${error.toString()}';
            _loading = false;
            notifyListeners();
          },
        );
  }

  // Mark notification as read
  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationService.markAsRead(notificationId);

      // Update local state
      final index = _notifications.indexWhere((n) => n.id == notificationId);
      if (index != -1) {
        _notifications[index] = NotificationModel(
          id: _notifications[index].id,
          bookingId: _notifications[index].bookingId,
          userId: _notifications[index].userId,
          userName: _notifications[index].userName,
          instructorId: _notifications[index].instructorId,
          createdAt: _notifications[index].createdAt,
          isRead: true,
        );
        notifyListeners();
      }
    } catch (e) {
      _error = 'Failed to mark as read: ${e.toString()}';
      debugPrint('Error marking notification as read: $e');
      notifyListeners();
    }
  }

  // Delete notification
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationService.deleteNotification(notificationId);

      // Remove from local state
      _notifications.removeWhere((n) => n.id == notificationId);
      notifyListeners();
    } catch (e) {
      _error = 'Failed to delete notification: ${e.toString()}';
      debugPrint('Error deleting notification: $e');
      notifyListeners();
    }
  }

  // Send notification
  Future<void> sendNotification(NotificationModel notification) async {
    try {
      await _notificationService.sendNotification(notification);
    } catch (e) {
      _error = 'Failed to send notification: ${e.toString()}';
      debugPrint('Error sending notification: $e');
      notifyListeners();
    }
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}