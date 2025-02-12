import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/notification_model.dart';
import '../repositories/notification_repository.dart';

class NotificationsBloc {
  final NotificationRepository _notificationRepository;
  final ValueNotifier<List<NotificationModel>?> _notificationsNotifier =
      ValueNotifier<List<NotificationModel>?>(null);

  ValueNotifier<List<NotificationModel>?> get notificationsNotifier =>
      _notificationsNotifier;

  NotificationsBloc(this._notificationRepository);

  // 🔹 Fetch notifications (without BuildContext)
  Future<void> fetchNotifications() async {
    try {
      final notifications = await _notificationRepository.getNotifications();
      _notificationsNotifier.value = notifications;
    } catch (e, stackTrace) {
      _notificationsNotifier.value = null;
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // 🔹 Mark a notification as read
  Future<void> markNotificationAsRead(String id) async {
    try {
      await _notificationRepository.markNotificationAsRead(id);
      await fetchNotifications(); // Fetch updated list after marking as read
    } catch (e, stackTrace) {
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  // 🔹 Dispose method for releasing resources
  void dispose() {
    _notificationsNotifier.dispose();
  }
}
