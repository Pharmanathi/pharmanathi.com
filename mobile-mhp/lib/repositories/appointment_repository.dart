import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../services/api_provider.dart';
import '../helpers/http_helpers.dart' as http_helpers;

class AppointmentRepository {
  final ApiProvider apiProvider;

  AppointmentRepository(this.apiProvider);

  Future<List<Appointment>> fetchAppointments(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
    try {
      final response = await apiProvider.fetchAppointmentData(
          context,
          (ctx) => http_helpers.Apihelper.httpRequestWithAuthorization(
              ctx, apiEndpoint, 'GET', ''));
      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        if (decodedData is List &&
            decodedData.isNotEmpty &&
            decodedData.first is Map) {
          return decodedData
              .map<Appointment>((json) => Appointment.fromJson(json))
              .toList();
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
}
