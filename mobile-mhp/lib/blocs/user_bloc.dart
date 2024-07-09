import 'dart:async';
import 'package:flutter/material.dart';
import '../repositories/user_repository.dart';
import 'package:http/http.dart';
import '../helpers/http_helpers.dart' as http_helpers;

class UserBloc {
  final _userDataController = StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get userDataStream => _userDataController.stream;

  final UserRepository _userRepository;

  UserBloc(this._userRepository);

  Future<Map<String, dynamic>> fetchUserData(BuildContext context) async {
    try {
      final userData = await _userRepository.fetchUserData(
        context,
        (context) => http_helpers.Apihelper.fetchData(context, (context) async {
          return await http_helpers.Apihelper.httpRequestWithAuthorization(
            context,
            '${http_helpers.apiBaseURL}/users/me/',
            'GET',
            '',
          );
        }),
      );
      _userDataController.sink.add(userData);
      return userData;
    } catch (e) {
      debugPrint('Error fetching user data: $e');
      return {};
    }
  }

  Future<void> updateUserData(
      BuildContext context, Map<String, dynamic> updatedUserData) async {
    try {
      final response = await _userRepository.updateUserData(
        context,
        updatedUserData,
        (context, url, method, body) =>
            http_helpers.Apihelper.httpRequestWithAuthorization(
                context, url, method, body),
      );
      fetchUserData(context); 
    } catch (e) {
      debugPrint('Error updating user data: $e');
    }
  }

  void dispose() {
    _userDataController.close();
  }
}
