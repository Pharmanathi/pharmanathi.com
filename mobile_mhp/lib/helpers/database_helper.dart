import 'package:pharma_nathi/models/notification_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('notifications.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE notifications (
        id TEXT PRIMARY KEY,
        title TEXT NOT NULL,
        message TEXT NOT NULL,
        timestamp TEXT NOT NULL,
        category TEXT NOT NULL,
        isRead INTEGER NOT NULL DEFAULT 0,
        screen TEXT NOT NULL,
        isExpanded INTEGER NOT NULL DEFAULT 0  -- Add isExpanded field
      )
    ''');
  }

  Future<void> insertNotification(NotificationModel notification) async {
    final db = await instance.database;
    await db.insert('notifications', notification.toJson(),
        conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<NotificationModel>> getNotifications() async {
    final db = await instance.database;
    final result = await db.query('notifications');
    return result.map((json) => NotificationModel.fromJson(json)).toList();
  }

  Future<void> markAsRead(String id) async {
    final db = await instance.database;
    await db.update('notifications', {'isRead': 1},
        where: 'id = ?', whereArgs: [id]);
  }

  Future<void> updateExpandedState(String id, bool isExpanded) async {
    final db = await instance.database;
    await db.update('notifications', {'isExpanded': isExpanded ? 1 : 0},
        where: 'id = ?', whereArgs: [id]);
  }
}
