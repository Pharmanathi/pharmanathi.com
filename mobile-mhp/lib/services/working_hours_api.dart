import 'dart:convert';
import 'dart:ui';
import 'package:http/http.dart' as http;
import '../logging.dart';
import '../helpers/http_helpers.dart' as http_helpers;

final String timeSlotAPIEndPoint = "${http_helpers.apiBaseURL}/timeslots/";

class WorkingHourApiService {
  static Future<void> sendSchedule(Map<String, List> schedule, context,
      {VoidCallback? onSuccess}) async {
    final log = logger(WorkingHourApiService);

    try {
      List<Map<String, String>> transformedSchedule = [];

      schedule.forEach((key, value) {
        int day = int.parse(key);
        value.forEach((timeSlot) {
          Map<String, String> timeSlotData = {
            'day': day.toString(),
            'start_time': timeSlot[0],
            'end_time': timeSlot[1],
          };
          transformedSchedule.add(timeSlotData);
        });
      });

      String scheduleJson = jsonEncode(transformedSchedule);

      log.d('Schedule being sent to API: $scheduleJson');

      http.Response response =
          await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          timeSlotAPIEndPoint,
          'POST',
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

        responseData.forEach((key, value) {
          if (value is List) {
            schedule[key] = value.map<String>((timeSlot) {
              if (timeSlot is Map<String, dynamic> &&
                  timeSlot.containsKey('start_time') &&
                  timeSlot.containsKey('end_time')) {
                return '${timeSlot['start_time']},${timeSlot['end_time']}';
              }
              return '';
            }).toList();
          }
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
