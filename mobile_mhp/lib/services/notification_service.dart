import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:pharma_nathi/routes/notification_routes.dart';
import 'package:rxdart/rxdart.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:logger/logger.dart';

import 'package:pharma_nathi/helpers/database_helper.dart';
import 'package:pharma_nathi/models/notification_model.dart';

//* Top-level background handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  await NotificationService.instance._handleNotification(message, true);
}

class NotificationService {
  //* Singleton setup
  NotificationService._internal();
  static final NotificationService instance = NotificationService._internal();
  factory NotificationService() => instance;

  //* Dependencies
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final Logger _logger = Logger();
  String? _deviceToken;

  //* Streams
  final BehaviorSubject<String?> selectNotificationSubject =
      BehaviorSubject<String?>();
  final BehaviorSubject<bool> notificationsEnabled =
      BehaviorSubject<bool>.seeded(false);

  //* Constants
  static const AndroidNotificationChannel _channel = AndroidNotificationChannel(
    'high_importance_channel',
    'High Importance Notifications',
    description: 'This channel is used for important notifications.',
    importance: Importance.high,
  );

  //* Initialization
  Future<void> initialize() async {
    await initializeFirebase();
    await _initializeLocalNotifications();
    await requestPermissions();
    await _isAndroidPermissionGranted();
  }

  //* Firebase Initialization
  Future<void> initializeFirebase() async {
    try {
      NotificationSettings settings = await _messaging.requestPermission();

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        FirebaseMessaging.onMessage.listen(_handleMessage);
        FirebaseMessaging.onBackgroundMessage(
            _firebaseMessagingBackgroundHandler);
        FirebaseMessaging.onMessageOpenedApp.listen(_handleMessageOpenedApp);

        //* Fetch and store the FCM token
        _deviceToken = await _messaging.getToken();
        _logger.i("FCM Token: $_deviceToken");

        //* Fetch and store the APNS token for iOS
        if (Platform.isIOS) {
          String? apnsToken = await _messaging.getAPNSToken();
          if (apnsToken != null) {
            _logger.i("APNS Token: $apnsToken");
            _deviceToken = apnsToken; //* Use APNS token if available
          } else {
            _logger.e("APNS token is null, notifications may not work on iOS.");
          }
        }
      } else if (settings.authorizationStatus == AuthorizationStatus.denied) {
        _logger.i('User denied notifications.');
      }
    } catch (e, stackTrace) {
      _logger.e('Error initializing Firebase: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  String? getDeviceToken() {
    return _deviceToken;
  }

  //* Local Notifications Initialization
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings();

    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    await _flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        selectNotificationSubject.add(response.payload);
      },
    );
  }

  //* Android Permissions Check
  Future<void> _isAndroidPermissionGranted() async {
    if (Platform.isAndroid) {
      final bool granted = await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;

      notificationsEnabled.add(granted);
    }
  }

  //* Permissions
  Future<void> requestPermissions() async {
    if (Platform.isIOS || Platform.isMacOS) {
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<
              MacOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
    } else if (Platform.isAndroid) {
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>();
      final bool? granted =
          await androidImplementation?.requestNotificationsPermission();
      notificationsEnabled.add(granted ?? false);
    }
  }

  //* Message Handling
  Future<void> _handleMessage(RemoteMessage message) async {
    await _handleNotification(message, false);
  }

  Future<void> _handleNotification(
      RemoteMessage message, bool isBackground) async {
    try {
      _logger.i('Received FCM data: ${message.data}');
      _logger.i('Notification payload: ${message.notification?.toMap()}');

      final category = message.data['category'] ?? 'general';
      final shouldNavigate =
          Notificationrouting.categoryToScreen.containsKey(category);

      final notification = NotificationModel(
        id: message.messageId ?? const Uuid().v4(),
        title: message.notification?.title ?? "No Title",
        message: message.notification?.body ?? "No Message",
        timestamp: DateTime.now(),
        category: category,
        shouldNavigate: shouldNavigate,
      );

      await _dbHelper.insertNotification(notification);

      if (!isBackground && message.notification != null) {
        await _showLocalNotification(message);
      }
    } catch (e, stackTrace) {
      _logger.e('Error handling notification: $e');
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<void> _handleMessageOpenedApp(RemoteMessage message) async {
    final category = message.data['category'] ?? 'general';
    final screen = Notificationrouting.getScreenForCategory(category);
    _logger.i("Navigating to: $screen");
    selectNotificationSubject.add(screen);
  }

  //* Local Notifications
  Future<void> _showLocalNotification(RemoteMessage message) async {
    await _flutterLocalNotificationsPlugin.show(
      message.messageId.hashCode,
      message.notification?.title,
      message.notification?.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          styleInformation: const DefaultStyleInformation(true, true),
        ),
        iOS: const DarwinNotificationDetails(),
      ),
    );
  }

  //* Database Operations
  Future<List<NotificationModel>> getNotificationsFromDb() async {
    try {
      return await _dbHelper.getNotifications();
    } catch (e) {
      _logger.e('Error getting notifications from database: $e');
      return [];
    }
  }

  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _dbHelper.markNotificationAsRead(notificationId);
    } catch (e) {
      _logger.e('Error marking notification as read: $e');
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _dbHelper.deleteNotification(notificationId);
    } catch (e) {
      _logger.e('Error deleting notification: $e');
    }
  }
}
