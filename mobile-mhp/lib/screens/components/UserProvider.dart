import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();

  String? email;
  String? name;
  String? picture;
  String? backendToken;
  String _selectedAppointmentType = 'In Person Visit';
  Map<String, dynamic>? _userData;

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

    //* Store the backend token securely
    await _secureStorage.write(key: 'backend_token', value: backendToken);

    notifyListeners();
  }

  //* Method to retrieve stored backend token
  Future<String?> getStoredBackendToken() async {
    try {
      return await _secureStorage.read(key: 'backend_token');
    } catch (e) {
      return null;
    }
  }

  //* Method to update the selected appointment type
  void updateAppointmentType(String newType) {
    _selectedAppointmentType = newType;
    notifyListeners();
  }

  //* Method to check if it's the first time sign-in
  Future<bool> isFirstTimeSignIn() async {
    //* Check if any of the required user information is empty
    return email == null ||
        name == null ||
        picture == null ||
        backendToken == null;
  }

  // Method to set the user data
  void setUserData(Map<String, dynamic> userData) {
    _userData = userData;
    print('User data: $_userData');
    notifyListeners();
  }

  // Getter method to access the user data
  Map<String, dynamic>? get userData => _userData;

  //* Method to set schedule data
  void setScheduleData(Map<String, List> scheduleData) {
    // Update schedule data
    print('Schedule data updated: $scheduleData');
  }
}
