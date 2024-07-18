import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/http_helpers.dart' as http_helpers;

class ApiProvider {
  Future<http.Response> fetchAppointmentData(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> fetchUserData(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/users/me/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> postUserDetails(BuildContext context, Map<String, dynamic> userDetails) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/users/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'POST', json.encode(userDetails));
  }
}
