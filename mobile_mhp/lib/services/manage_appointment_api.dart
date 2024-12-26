//TODO:[Thabang] migrate all this to bloc

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:provider/provider.dart';
import '../helpers/http_helpers.dart' as http_helpers;
import '../screens/components/UserProvider.dart';

class APIService {
  static final log = logger(APIService);
  static Map<String, dynamic> _requestBody = {};

  static void updateRequestBody({
    double? consultationFee,
    double? noShowFee,
    bool? appointmentType,
    int? appointmentDuration,
    int? doctorId,
    bool? selectedRadioButton,
    String? selectedDateRange,
  }) {
    _requestBody['cost'] = consultationFee?.toStringAsFixed(2);
    _requestBody['no_show_cost'] = noShowFee?.toStringAsFixed(2);
    _requestBody['is_online'] = appointmentType;
    _requestBody['duration'] = appointmentDuration;
    _requestBody['is_run_forever'] = selectedRadioButton;
    if (selectedDateRange != null && !_requestBody["is_run_forever"]) {
      final dates = parseDateRange(selectedDateRange);
      _requestBody['start_date'] = dates[0];
      _requestBody['end_date'] = dates[1];
    }
  }

  static List<String> parseDateRange(String selectedDateRange) {
    final parts = selectedDateRange.split(' - ');
    final months = {
      'Jan': '01',
      'Feb': '02',
      'Mar': '03',
      'Apr': '04',
      'May': '05',
      'Jun': '06',
      'Jul': '07',
      'Aug': '08',
      'Sep': '09',
      'Oct': '10',
      'Nov': '11',
      'Dec': '12'
    };
    final startDateParts = parts[0].split(' ');
    final endDateParts = parts[1].split(' ');
    final startDate =
        '${endDateParts[2]}-${months[startDateParts[1]]}-${startDateParts[0].padLeft(2, '0')}';
    final endDate =
        '${endDateParts[2]}-${months[endDateParts[1]]}-${endDateParts[0].padLeft(2, '0')}';
    return [startDate, endDate];
  }

  static Future<void> sendDataToBackendFromJSONFile(BuildContext context,
      {VoidCallback? onSuccess}) async {
    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userInfo = userProvider.user;

// Ensure userInfo is not null and has the expected structure before accessing the nested fields
      if (userInfo != null && userInfo.doctorProfile != null) {
        _requestBody['doctor'] = userInfo.doctorProfile!.id;
      } else {
        // Handle the case where userInfo or doctorProfile is null or not present
        debugPrint('Error: doctorProfile is missing in userInfo.');
      }

      String requestBodyJsonString = jsonEncode(_requestBody);
      log.i('Sending JSON data to backend:\n$requestBodyJsonString');

      var response =
          await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          '${http_helpers.apiBaseURL}/appointment-types/',
          'POST',
          requestBodyJsonString,
        );
      });

      if (response.statusCode == 200) {
        log.i('Data sent successfully');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const SizedBox(
              width: 200,
              child: Center(
                child: Text(
                  'Your Appointment Type has been Update successfully',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.symmetric(vertical: 150),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      } else {
        http_helpers.Apihelper.handleError(context, response);
      }

      _requestBody.clear();
    } catch (error) {
      http_helpers.Apihelper.handleException(context, error);
    }
  }

  static Future<List<Map<String, dynamic>>?> fetchDataFromBackend(
      BuildContext context) async {
    try {
      var response =
          await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          '${http_helpers.apiBaseURL}/appointment-types/',
          'GET',
          '',
        );
      });

      if (response.statusCode == 200) {
        log.i('Data fetched successfully');
        var data = jsonDecode(response.body) as List;
        return data.cast<Map<String, dynamic>>();
      } else {
        http_helpers.Apihelper.handleError(context, response);
      }
    } catch (error) {
      http_helpers.Apihelper.handleException(context, error);
    }
    return null;
  }
}
