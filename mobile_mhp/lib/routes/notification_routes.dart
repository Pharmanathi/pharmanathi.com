import 'package:pharma_nathi/routes/app_routes.dart';

class Notificationrouting {
  static const Map<String, String> categoryToScreen = {
    'appointments': AppRoutes.appointments,
    'General': AppRoutes.notifications, 
    'Profession': AppRoutes.editprofile,
  };

  static String getScreenForCategory(String category) {
    return categoryToScreen[category] ?? AppRoutes.notifications; 
  }
}
