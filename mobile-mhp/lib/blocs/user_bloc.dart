import 'dart:async';
import 'package:flutter/material.dart';

import '../repositories/user_repository.dart';


class UserBloc {
  final _userDataController = StreamController<Map<String, dynamic>>();

  Stream<Map<String, dynamic>> get userDataStream => _userDataController.stream;

  void fetchUserData(BuildContext context) async {
    try {
      final userData = await UserRepository.fetchUserData(context);
      _userDataController.sink.add(userData);
    } catch (e) {
      debugPrint('Error fetching user data: $e');
    }
  }

  Future<void> updateUserData(BuildContext context, Map<String, dynamic> updatedUserData) async {
    try {
      final updatedData = await UserRepository.updateUserData(context, updatedUserData);
      fetchUserData(context); // Refresh user data after update
      // @TODO: use data from the form during onboarding to update userData
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  void dispose() {
    _userDataController.close();
  }
}

final userBloc = UserBloc();
