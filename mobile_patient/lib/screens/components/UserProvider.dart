// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProvider with ChangeNotifier {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  int? doctorId;

  int? _selectedDoctorId;
  int? get selectedDoctorId => _selectedDoctorId;

  set selectedDoctorId(int? id) {
    _selectedDoctorId = id;

    print('doctorId in provider: $id');
    // notifyListeners();
  }

  String? email;
  String? name;
  String? picture;
  String? backendToken;
  String?
      isFirstTime; // isFirstTime is a String? that will hold either null or "no"

  // Constructor to initialize isFirstTime asynchronously
  UserProvider() {
    _initializeFirstTime();
  }

  // Method to initialize isFirstTime asynchronously
  Future<void> _initializeFirstTime() async {
    isFirstTime = await checkFirstTime();
    notifyListeners(); // Notify listeners when isFirstTime is set
  }

  // Check if it's the first time using the app
  Future<String?> checkFirstTime() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstTimeStored = prefs.getBool('isFirstTime');

    if (isFirstTimeStored == null) {
      // First time using the app
      await prefs.setBool(
          'isFirstTime', false); // Set to false for future checks
      return null; // Return null for first-time users
    }

    // If false, return "no" (indicating it's not the first time)
    // If true, return null (indicating it is the first time)
    return isFirstTimeStored ? null : "no";
  }

  // Method to set user information and store backend token securely
  Future<void> setUserInformation(
      String email, String name, String picture, String backendToken) async {
    // First time login actions
    if (this.email == null &&
        this.name == null &&
        this.picture == null &&
        this.backendToken == null) {
      print('First time login!');
      // You can add further first-time login actions here (e.g., onboarding)
      isFirstTime = null; // Set to null for first-time users
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isFirstTime', false); // Update SharedPreferences
    }

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
    } catch (e, stackTrace) {
      // Capture the exception with Sentry
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );

      // Add a breadcrumb for the error
      Sentry.addBreadcrumb(
        Breadcrumb(
          message: 'Error while retrieving backend token',
          category: 'storage',
          level: SentryLevel.error,
        ),
      );
      return null;
    }
  }

  //* Method to set doctor's ID
  void setDoctorId(int id) {
    doctorId = id;
  }

  //* Method to retrieve doctor's ID
  int? getDoctorId() {
    return doctorId;
  }

  //* Method to check if it's the first time sign-in
  Future<bool> isFirstTimeSignIn() async {
    return checkFirstTime() == null ||
        email == null ||
        name == null ||
        picture == null ||
        backendToken == null;
  }
}
