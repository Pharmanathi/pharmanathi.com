import 'dart:convert';
import 'package:flutter/material.dart';
import '../helpers/http_helpers.dart' as http_helpers;

Future<List<Map<String, dynamic>>> fetchAppointmentData(
    BuildContext context) async {
  final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
  try {
    final response = await http_helpers.Apihelper.fetchData(
        context,
        (ctx) => http_helpers.Apihelper.httpRequestWithAuthorization(
            ctx, apiEndpoint, 'GET', ''));
    if (response.statusCode == 200) {
      dynamic decodedData = json.decode(response.body);
      if (decodedData is List &&
          decodedData.isNotEmpty &&
          decodedData.first is Map) {
        // print('Decoded data: $decodedData');
        return decodedData.cast<Map<String, dynamic>>();
      } else {
        http_helpers.Apihelper.handleError(context, response);
        return [];
      }
    } else {
      http_helpers.Apihelper.handleError(context, response);
      return [];
    }
  } catch (e) {
    http_helpers.Apihelper.handleException(context, e);
    return [];
  }
}
