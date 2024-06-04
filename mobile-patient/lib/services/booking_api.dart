import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import '../helpers/api_helpers.dart';

class BookingAPIService {
  static final String apiUrl = ApiHelper.getApiBaseUrl();
  static final Map<String, dynamic> _requestBody = {};

  static void updateRequestBody({
    String? reasonForVisit,
    DateTime? appointmentDay,
    String? doctorName,
    int? doctorId,
    int? appointmentType,
    String? timeOfAppointment,
    String? typeOfPayment,
    File? uploadedEHRFiles,
  }) {
    _requestBody
      ..clear()
      ..['reason'] = reasonForVisit
      ..['doctorId'] = doctorId
      ..['appointmentType'] = appointmentType
      ..['appointmentDay'] = appointmentDay
      ..['doctor'] = doctorName
      ..['start_time'] = timeOfAppointment
      ..['payment_process'] = typeOfPayment;

    if (uploadedEHRFiles != null) {
      _requestBody['uploadedEHRFiles'] = uploadedEHRFiles;
    }
  }

  static Future<void> sendBookingDataToBackend(BuildContext context,
      {VoidCallback? onSuccess}) async {
    try {
      if (_requestBody['start_time'] == null) {
        throw Exception('Start time is null');
      }

      final requestBody = _prepareRequestBody();
      final requestBodyJsonString = jsonEncode(requestBody);
      _logRequestBody(requestBodyJsonString);

      final response = await ApiHelper.httpRequestWithAuthorization(
        context,
        '$apiUrl/appointments/',
        'POST',
        requestBodyJsonString,
      );

      _logResponse(response);

      if (response.statusCode == 201) {
        onSuccess?.call();
      }
      _requestBody.clear();
    } catch (error) {
      ApiHelper.handleException(context, error,);
    }
  }

  static Map<String, dynamic> _prepareRequestBody() {
    final hourMinute = _requestBody['start_time'].substring(0, 5).split(":");
    final DateTime appointmentStartTime = DateTime(
      _requestBody['appointmentDay'].year,
      _requestBody['appointmentDay'].month,
      _requestBody['appointmentDay'].day,
      int.parse(hourMinute[0]),
      int.parse(hourMinute[1]),
    );

    return {
      "doctor": _requestBody['doctorId'],
      "start_time": appointmentStartTime.toIso8601String(),
      "reason": _requestBody['reason'],
      "appointment_type": _requestBody['appointmentType'],
      "payment_process": _requestBody['payment_process'],
       // TODO: handle file upload
    };
  }

  static void _logRequestBody(String requestBodyJsonString) {
    print('Sending JSON data to backend:\n$requestBodyJsonString');
  }

  static void _logResponse( response) {
    print('Received response with status code: ${response.statusCode}');
  }
}
