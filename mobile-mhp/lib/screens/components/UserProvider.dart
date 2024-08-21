import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../models/user.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? email;
  String? name;
  String? picture;
  int? contact;
  String? backendToken;
  String _selectedAppointmentType = 'In Person Visit';

  User? _user;
  User? get user => _user;

  String get selectedAppointmentType => _selectedAppointmentType;

  //* Constructor to initialize user information
  UserProvider({this.email, this.name, this.picture, this.backendToken});

  //* Method to set user information and store backend token securely
  Future<void> setUserInformation(
      String email, String name, String picture, String backendToken) async {
    this.email = email;
    this.name = name;
    this.picture = picture;
    this.backendToken = backendToken;

    try {
      //* Store the backend token securely
      await _secureStorage.write(key: 'backend_token', value: backendToken);
    } catch (e) {
      //* Handle any errors that occur during secure storage write operation
      debugPrint('Error writing backend token: $e');
    }

    notifyListeners();
  }

  //* Method to set user data
  void setUserData(User user) {
    _user = user;
    notifyListeners();
    debugPrint('Inside provider : User data: $user');
  }

  //* Method to retrieve stored backend token
  Future<String?> getStoredBackendToken() async {
    try {
      return await _secureStorage.read(key: 'backend_token');
    } catch (e) {
      //* Handle any errors that occur during secure storage read operation
      debugPrint('Error reading backend token: $e');
      return null;
    }
  }

  //* Method to update the selected appointment type
  void updateAppointmentType(String newType) {
    _selectedAppointmentType = newType;
    notifyListeners();
  }

  Future<bool> hasIncompleteDoctorProfile() async {
    //* Check if the doctor's profile exists
    final doctorProfile = user?.doctorProfile;
    if (doctorProfile == null) {
      return true; 
    }

    //* Check if specialities, practiceLocations, or hpcsaNo are empty
    final hasIncompleteSpecialities = doctorProfile.specialities.isEmpty;
    final hasIncompletePracticeLocations =
        doctorProfile.practiceLocations.isEmpty;
    final hasIncompleteHpcsaNo = doctorProfile.hpcsaNo.isEmpty;

    //* Return true if any of these fields are incomplete
    return hasIncompleteSpecialities ||
        hasIncompletePracticeLocations ||
        hasIncompleteHpcsaNo;
  }

  //* Method to set schedule data
  void setScheduleData(Map<String, List> scheduleData) {
    //* Update schedule data
    debugPrint('Schedule data updated: $scheduleData');
  }
}

User? getUserInfo(BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  return userProvider.user; // Return single user, which is of type User?
}

void setUserDataProxy(User userData, BuildContext context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  userProvider.setUserData(userData); // Pass User instance to setUserData
}
