import 'dart:convert';
import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../helpers/api_helpers.dart' as http_helpers;
import '../services/api_provider.dart';

class DoctorRepository {
  final ApiProvider _apiProvider = ApiProvider();

  Future<List<Doctor>> fetchDoctors(BuildContext context) async {
    try {
      final response = await _apiProvider.fetchDoctors(context);
      if (response.statusCode == 200) {
        final List<dynamic> decodedData = json.decode(response.body);
        return decodedData
            .map<Doctor>((json) => Doctor.fromJson(json))
            .toList();
      } else {
        //* Handle non-200 status code
        http_helpers.ApiHelper.handleError(context, response);
        return [];
      }
    } catch (e, stackTrace) {
      //* Handle network exceptions and other unexpected errors
      http_helpers.ApiHelper.handleException(context, e);
      await Sentry.captureException(e, stackTrace: stackTrace);
      return [];
    }
  }
}
