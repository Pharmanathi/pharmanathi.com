import 'dart:convert';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:flutter/material.dart';
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
        dynamic decodedData = json.decode(response.body);
        if (decodedData is List &&
            decodedData.isNotEmpty &&
            decodedData.first is Map) {
          return decodedData
              .map<Appointment>((json) => Appointment.fromJson(json))
              .toList();
        } else {
          http_helpers.ApiHelper.handleError(context, response);
          return [];
        }
      } else {
        http_helpers.ApiHelper.handleError(context, response);
        return [];
      }
    } catch (e, stackTrace) {
      http_helpers.ApiHelper.handleException(context, e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return [];
    }
  }
}
