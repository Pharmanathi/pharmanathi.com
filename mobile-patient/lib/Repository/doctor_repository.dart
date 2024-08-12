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
      print("API Response Status: ${response.statusCode}");
      print("API Response Body: ${response.body}");
      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        if (decodedData is List &&
            decodedData.isNotEmpty &&
            decodedData.first is Map) {
          return decodedData
              .map<Doctor>((json) => Doctor.fromJson(json))
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

  // Future<List<Doctor>> fetchDoctors(BuildContext context) async {
  //   try {
  //     final response = await _apiProvider.fetchDoctors(context);
  //     print("API Response Status: ${response.statusCode}");
  //     print("API Response Body: ${response.body}");

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       final List<Doctor> doctors =
  //           data.map((json) => Doctor.fromJson(json)).toList();
  //       print("Fetched Doctors: ${doctors.length}");
  //       return doctors;
  //     } else {
  //       print('Unexpected status code: ${response.statusCode}');
  //       return [];
  //     }
  //   } catch (error, stackTrace) {
  //     print('Error fetching doctors: $error');
  //     Sentry.captureException(error, stackTrace: stackTrace);
  //     return [];
  //   }
  // }
}
