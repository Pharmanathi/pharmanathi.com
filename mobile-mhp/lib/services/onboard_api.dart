import 'dart:convert';
import 'package:pharma_nathi/logging.dart';
import '../helpers/http_helpers.dart' as http_helpers;

class APIService {
  static final log = logger(APIService);

  static Future<void> sendFormData(
      List<Map<String, dynamic>> formDataList, context) async {
    try {
      // Remove duplicate form data
      final uniqueFormDataList = formDataList.toSet().toList();

      log.d('Sending data to backend: ${jsonEncode(uniqueFormDataList)}');
      final body = jsonEncode(uniqueFormDataList);

      final response =
          await http_helpers.Apihelper.fetchData(context, (context) async {
        return await http_helpers.Apihelper.httpRequestWithAuthorization(
          context,
          '${http_helpers.apiBaseURL}/user/me',
          'POST',
          body,
        );
      });

      if (response.statusCode == 200) {
        // Data successfully sent to the backend
        log.d('Data sent successfully');
      } else {
        http_helpers.Apihelper.handleError(context, response);
      }
    } catch (e) {
      http_helpers.Apihelper.handleException(context, e);
    }
  }
}
