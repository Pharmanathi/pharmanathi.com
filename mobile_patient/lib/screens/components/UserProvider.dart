// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
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




  //* Method to set user information and store backend token securely
  Future<void> setUserInformation(String email, String name, String picture, String backendToken) async {
    //* Check if user information already exists
    if (this.email == null && this.name == null && this.picture == null && this.backendToken == null) {
      //* First time login actions
      print('First time login!');
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
    } catch (e) {
      // print('Failed to retrieve stored backend token: $e');
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
    //* Check if any of the required user information is empty
    return email == null ||
        name == null ||
        picture == null ||
        backendToken == null;
  }
}
