import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:pharma_nathi/models/notification_model.dart';
import 'package:pharma_nathi/repositories/notification_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


final Logger _logger = Logger();

class NotificationsBloc {
  final NotificationRepository _notificationRepository;
  final ValueNotifier<List<NotificationModel>?> _notificationsNotifier =
      ValueNotifier<List<NotificationModel>?>(null);

  ValueNotifier<List<NotificationModel>?> get notificationsNotifier =>
      _notificationsNotifier;

  NotificationsBloc(this._notificationRepository);

  //* Fetch notifications (without BuildContext)
  Future<void> fetchNotifications() async {
    try {
      final notifications = await _notificationRepository.getNotifications();
      _notificationsNotifier.value = notifications;
    } catch (e, stackTrace) {
      _notificationsNotifier.value = null;
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void _updateNotificationState(
      String id, NotificationModel Function(NotificationModel) updateFn) {
    final updatedNotifications = _notificationsNotifier.value!.map((n) {
      return n.id == id ? updateFn(n) : n;
    }).toList();

    _notificationsNotifier.value = updatedNotifications;
  }

  //* Mark a notification as read
  Future<void> markNotificationAsRead(String id) async {
    try {
      if (_notificationsNotifier.value == null ||
          _notificationsNotifier.value!.isEmpty) {
        _logger.w('No notifications available to mark as read.');
        return;
      }

      final notification = _notificationsNotifier.value!.firstWhere(
        (n) => n.id == id,
        orElse: () => throw Exception('Notification with id $id not found'),
      );

      if (!notification.isRead) {
        await _notificationRepository.markNotificationAsRead(id);
        _updateNotificationState(id, (n) => n.copyWith(isRead: true));
        _logger.i('Marked notification $id as read');
      }
    } catch (e, stackTrace) {
      _logger.e('Error marking notification as read: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void dispose() {
    _notificationsNotifier.dispose();
  }
}
