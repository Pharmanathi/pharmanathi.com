import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/api_helpers.dart' as http_helpers;

class ApiProvider {
  Future<http.Response> fetchAppointmentData(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> bookAppointment(
      BuildContext context, Map<String, dynamic> appointmentData) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
    final requestBody = jsonEncode(appointmentData);
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'POST', requestBody);
  }
  Future<http.Response> fetchDoctors(BuildContext context) async {
    final apiUrl = '${http_helpers.ApiHelper.getApiBaseUrl()}/doctors/';
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiUrl, 'GET', '');
  }

   Future<http.Response> signInWithGoogle(BuildContext context, String idToken) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/google-login-by-id-token?id_token=$idToken&device_token=set-me-up-thabang';
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }
}
