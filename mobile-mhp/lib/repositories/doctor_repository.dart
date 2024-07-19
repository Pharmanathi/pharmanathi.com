import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../services/api_provider.dart';

class DoctorRepository {
  final ApiProvider _apiProvider;

  DoctorRepository(this._apiProvider);

  Future<bool> updateUserDetails(BuildContext context, int userId,
      Map<String, dynamic> userDetails) async {
    final response =
        await _apiProvider.updateUserDetails(context, userId, userDetails);

    if (response.statusCode == 200) {
      return true;
    } else {
      // Handle error response
      return false;
    }
  }
}
