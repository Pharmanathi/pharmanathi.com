import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/components/UserProvider.dart';
import '../helpers/api_helpers.dart';

class TimeSlotsApiService {
  static Future<List<List<String>>> fetchAvailabilitySlots(
      int selectedDoctorId, DateTime day, dynamic context) async {
    final String apiUrl = ApiHelper.getApiBaseUrl();
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final doctorId = userProvider.getDoctorId();

    String apiUrlWithUserId = apiUrl.replaceFirst(':id', doctorId.toString());

    String formattedDate =
        '${day.day.toString().padLeft(2, '0')}/${day.month.toString().padLeft(2, '0')}/${day.year}';

    final url =
        '$apiUrlWithUserId/doctors/$doctorId/availability?d=$formattedDate';

    try {
      final response = await ApiHelper.fetchData(
        context,
        (ctx) => ApiHelper.httpRequestWithAuthorization(ctx, url, 'GET', ''),
      );

      if (response.statusCode == 200) {
        List<dynamic> slotsJson = json.decode(response.body);
        List<List<String>> slots = [];

        slots = slotsJson.map((slot) => List<String>.from(slot)).toList();

        return slots;
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
}
