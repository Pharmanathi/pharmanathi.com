//TODO:[Thabang] migrate all this to bloc

import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../logging.dart';
import '../helpers/http_helpers.dart' as http_helpers;

final String timeSlotAPIEndPoint = "${http_helpers.apiBaseURL}/timeslots/";

class WorkingHourApiService {
  static Future<void> sendSchedule(List<Map> schedule, context,
      {VoidCallback? onSuccess}) async {
    final log = logger(WorkingHourApiService);

    try {
      String scheduleJson = jsonEncode(schedule);

      log.d('Schedule being sent to API: $scheduleJson');

      http.Response response =
          await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          timeSlotAPIEndPoint,
          'POST', // fetch Data(named fetchData) but does POST? perhaps a rename?
          scheduleJson,
        );
      });

      if (response.statusCode == 201) {
        log.i('Schedule saved successfully!');
        onSuccess?.call();
      } else {
        http_helpers.Apihelper.handleError(context, response);
      }
    } catch (e) {
      http_helpers.Apihelper.handleException(context, e);
    }
  }

  static Future<Map<String, List<String>>> fetchScheduleFromApi(context) async {
    final log = logger(WorkingHourApiService);

    try {
      http.Response response =
          await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          timeSlotAPIEndPoint,
          'GET',
          '',
        );
      });

      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        Map<String, List<String>> schedule = {};
        responseData.forEach((dailySlot) {
          final String day = dailySlot['day'].toString();
          if (!schedule.containsKey(day)) schedule[day] = [];
          schedule[day]!
              .add('${dailySlot['start_time'].substring(0, 5)},${dailySlot['end_time'].substring(0, 5)}');
        });
        log.i('Schedule fetched successfully: $schedule');
        return schedule;
      } else {
        http_helpers.Apihelper.handleError(context, response);
        return {};
      }
    } catch (e) {
      http_helpers.Apihelper.handleException(context, e);
      return {};
    }
  }
}
