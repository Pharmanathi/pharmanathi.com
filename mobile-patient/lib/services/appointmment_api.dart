import 'dart:convert';
import 'package:flutter/material.dart';
import '../helpers/api_helpers.dart';

Future<List<Map<String, dynamic>>> fetchAppointmentData(
    BuildContext context) async {
  final String apiUrl = ApiHelper.getApiBaseUrl();
  final apiEndpoint = '$apiUrl/appointments/';

  try {
    final response = await ApiHelper.fetchData(
        context,
        (ctx) => ApiHelper.httpRequestWithAuthorization(
            ctx, apiEndpoint, 'GET', ''));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.cast<Map<String, dynamic>>();
    } else {
      // Utilize the ApiHelper's error handling method
      ApiHelper.handleError(context, response);
      return []; // Or throw an error if you want to handle it differently
    }
  } catch (e) {
    // Utilize the ApiHelper's error handling method
    ApiHelper.handleException(context, e);
    return []; // Or throw an error if you want to handle it differently
  }
}
