import 'package:logger/logger.dart';
import 'package:pharma_nathi/models/notification_model.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  final Logger _logger = Logger();

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    try {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, fileName);

      return await openDatabase(
        path,
        version: 1,
        onCreate: _createDB,
        onUpgrade: _onUpgrade, // Add upgrade logic if needed
      );
    } catch (e, stackTrace) {
      _logger.e('Database initialization error: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      rethrow;
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp INTEGER NOT NULL,  -- Store timestamp as integer
        category TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        screen TEXT NOT NULL,
        isExpanded INTEGER NOT NULL DEFAULT 0
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      //* Implement schema migrations if needed which currently am not sure if we do
    }
  }

  Future<void> insertNotification(NotificationModel notification) async {
    try {
      final db = await instance.database;
      await db.insert(
        'notifications',
        notification.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    } catch (e, stackTrace) {
      _logger.e('Error inserting notification: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> insertNotificationsBulk(
      List<NotificationModel> notifications) async {
    try {
      final db = await instance.database;
      final batch = db.batch();
      for (var notification in notifications) {
        batch.insert(
          'notifications',
          notification.toJson(),
          conflictAlgorithm: ConflictAlgorithm.replace,
        );
      }
      await batch.commit(noResult: true);
    } catch (e, stackTrace) {
      _logger.e('Error inserting bulk notifications: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<List<NotificationModel>> getNotifications() async {
    try {
      final db = await instance.database;
      final result = await db.query('notifications', orderBy: 'timestamp DESC');

      //* since the 'id' field is a UUID stored as a String
      return result.map((json) {
        json['id'] =
            json['id'].toString(); //* to ensure it's a String if necessary
        return NotificationModel.fromJson(json);
      }).toList();
    } catch (e, stackTrace) {
      _logger.e('Error getting notifications: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
      return [];
    }
  }

  Future<void> markNotificationAsRead(String id) async {
    try {
      final db = await instance.database;
      await db.update(
        'notifications',
        {'isRead': 1},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      _logger.e('Error marking notification as read: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> updateExpandedState(String id, bool isExpanded) async {
    try {
      final db = await instance.database;
      await db.update(
        'notifications',
        {'isExpanded': isExpanded ? 1 : 0},
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      _logger.e('Error updating expanded state: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      final db = await instance.database;
      await db.delete(
        'notifications',
        where: 'id = ?',
        whereArgs: [id],
      );
    } catch (e, stackTrace) {
      _logger.e('Error deleting notification: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> clearAllNotifications() async {
    try {
      final db = await instance.database;
      await db.delete('notifications');
    } catch (e, stackTrace) {
      _logger.e('Error clearing notifications: $e');
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  Future<void> close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
