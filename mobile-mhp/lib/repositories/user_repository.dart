import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart';
import '../helpers/http_helpers.dart' as http_helpers;

class UserRepository {
  Future<Map<String, dynamic>> fetchUserData(
    BuildContext context,
    Future<Response> Function(BuildContext context) fetchDataFunction,
  ) async {
    try {
      final response = await fetchDataFunction(context);
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        http_helpers.Apihelper.handleError(context, response);
        return {};
      }
    } catch (e) {
      http_helpers.Apihelper.handleException(context, e);
      return {};
    }
  }

  Future<Map<String, dynamic>> updateUserData(
    BuildContext context,
    Map<String, dynamic> userData,
    Future<Response> Function(
            BuildContext context, String url, String method, String body)
        httpRequestFunction,
  ) async {
    try {
      final String requestBody = json.encode(userData);
      final response = await httpRequestFunction(
        context,
        '${http_helpers.apiBaseURL}/users/me/',
        'POST',
        requestBody,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        http_helpers.Apihelper.handleError(context, response);
        return {};
      }
    } catch (e) {
      http_helpers.Apihelper.handleException(context, e);
      return {};
    }
  }
}
