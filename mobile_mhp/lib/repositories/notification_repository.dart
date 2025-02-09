import 'package:pharma_nathi/helpers/database_helper.dart';
import 'package:pharma_nathi/models/notification_model.dart';


class NotificationRepository {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;

  Future<List<NotificationModel>> getNotifications() async {
    return await _dbHelper.getNotifications();
  }

  Future<void> markAsRead(String id) async {
    await _dbHelper.markAsRead(id);
  }
}
