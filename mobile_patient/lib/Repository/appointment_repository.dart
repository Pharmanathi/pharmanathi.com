import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/api_provider.dart';
import '../helpers/api_helpers.dart' as http_helpers;

class AppointmentRepository {
  final ApiProvider apiProvider;

  AppointmentRepository(this.apiProvider);

  Future<List<Appointment>> fetchAppointments(BuildContext context) async {
    try {
      final response = await apiProvider.fetchAppointmentData(context);
      if (response.statusCode == 200) {
        final decodedData = json.decode(response.body);
        if (decodedData is List && decodedData.first is Map) {
          return decodedData
              .map<Appointment>((json) => Appointment.fromJson(json))
              .toList();
        }
      }
    } catch (e, stackTrace) {
      //* Handle network exceptions and other unexpected errors
      http_helpers.ApiHelper.handleException(context, e);
      Sentry.captureException(e, stackTrace: stackTrace);
    }
    return [];
  }

  Future<Map<String, dynamic>> bookAppointment(
      BuildContext context, Map<String, dynamic> appointmentData) async {
    try {
      final response =
          await apiProvider.bookAppointment(context, appointmentData);
      if (response.statusCode == 201) {
        dynamic responseData = json.decode(response.body);
        // Return the response data if payment URL is present
        return responseData;
      } else {
        http_helpers.ApiHelper.handleError(context, response);
        throw Exception('Error booking appointment');
      }
    } catch (e, stackTrace) {
      http_helpers.ApiHelper.handleException(context, e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw Exception('Error booking appointment');
    }
  }
}
