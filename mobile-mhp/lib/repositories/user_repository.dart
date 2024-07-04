import 'dart:convert';
import 'package:flutter/material.dart';
import '../helpers/http_helpers.dart' as http_helpers;

class UserRepository {
  static Future<Map<String, dynamic>> fetchUserData(BuildContext context) async {
    try {
      final response = await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          '${http_helpers.apiBaseURL}/users/me/',
          'GET',
          '',
        );
      });

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

  static Future<Map<String, dynamic>> updateUserData(BuildContext context, Map<String, dynamic> userData) async {
    try {
      final response = await http_helpers.Apihelper.fetchData(context, (context) async {
        final String requestBody = json.encode(userData);
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          '${http_helpers.apiBaseURL}/users/me/',
          'POST', //@TODO: yet to figure out if its update/create
          requestBody,
        );
      });

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
