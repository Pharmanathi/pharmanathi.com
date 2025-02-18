import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:logger/logger.dart';
import 'package:pharma_nathi/services/notification_service.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../helpers/http_helpers.dart' as http_helpers;

final Logger _logger = Logger();

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

  Future<http.Response> updateDoctorDetails(BuildContext context, int doctorid, Map<String, dynamic> userDetails) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/doctors/$doctorid/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
      context, apiEndpoint, 'PATCH', json.encode(userDetails)
    );
  }
  Future<http.Response> fetchSpecialities(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/specialities/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> signInWithGoogle(BuildContext context, String idToken) async {
    try {
      String? deviceToken = NotificationService().getDeviceToken();

      if (deviceToken == null) {
        _logger.w("Device token is null, retrying...");
        deviceToken = await FirebaseMessaging.instance.getToken();
      }

      if (deviceToken == null) {
        _logger.e("Failed to retrieve device token.");
        throw Exception("Device token is null");
      }

      final apiEndpoint =
          '${http_helpers.apiBaseURL}/google-login-by-id-token?is_doctor=true&id_token=$idToken&device_token=$deviceToken';

      _logger.i("Sending API request with device token: $deviceToken");

      final response = await http_helpers.Apihelper.httpRequestWithAuthorization(
          context, apiEndpoint, 'GET', '');

      _logger.i("API Response: ${response.statusCode}");

      return response;
    } catch (e, stackTrace) {
      _logger.e("Error in signInWithGoogle: $e");
      Sentry.captureException(e, stackTrace: stackTrace);
      return Future.error(e);
    }
  }

  Future<http.Response> fetchAddressById(BuildContext context, int addressId) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/addresses/$addressId/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

}
