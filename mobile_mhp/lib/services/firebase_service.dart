import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:pharma_nathi/helpers/database_helper.dart';
import 'package:pharma_nathi/models/notification_model.dart';


class FirebaseService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DatabaseHelper dbHelper = DatabaseHelper.instance;

  Future<void> initFirebase() async {
    NotificationSettings settings = await _messaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      FirebaseMessaging.onMessage.listen(_handleMessage);
    }
  }

  Future<void> _handleMessage(RemoteMessage message) async {
    final notification = NotificationModel(
      id: message.messageId ?? DateTime.now().toString(),
      title: message.notification?.title ?? "No Title",
      message: message.notification?.body ?? "No Message",
      timestamp: DateTime.now(),
      category: message.data['category'] ?? "General",
      isRead: false,
      screen: message.data['screen'] ?? "/home",
    );

    await dbHelper.insertNotification(notification);
  }
}
