import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharma_nathi/logging.dart';
import 'package:provider/provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import '../screens/components/UserProvider.dart';

final String apiBaseURL =
    dotenv.get("API_BASE_URL", fallback: "backend_api_env_var_unset");
final String appLabel =
    dotenv.get("APP_LABEL", fallback: "app_label_env_var_unset");

class Apihelper {
  static final log = logger(Apihelper);

  static Future<http.Response> fetchData(
    BuildContext context,
    Future<http.Response> Function(BuildContext) apiCall,
  ) async {
    try {
      return await apiCall(context);
    } catch (e) {
      handleException(context, e);
      return http.Response('Error occurred', 500); // Return a dummy response
    }
  }

  static String? retrieveLocaAPIToken(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.backendToken;
  }

  static Future<http.Response> httpRequestWithAuthorization(
    BuildContext context,
    String url,
    String method, // 'GET', 'POST', or 'PATCH'
    String requestBody,
  ) async {
    String authorizationToken = '';

    final tokenString = Apihelper.retrieveLocaAPIToken(context);

    if (tokenString != null) {
      final Map<String, dynamic> tokenMap = json.decode(tokenString);
      final tokenValue = tokenMap['key'];
      authorizationToken = 'Token $tokenValue';
    } else {
      log.e('Error: Authorization token is null');
    }

    Map<String, String> headers = {
      'Authorization': authorizationToken,
      'Auth-App': await getAuthApp(),
      'Device-IP': await _getDeviceIP(),
    };

    if (method == 'POST' || method == 'PATCH') {
      headers['Content-Type'] = 'application/json';
    }

    final response = method == 'GET'
        ? await http.get(Uri.parse(url), headers: headers)
        : method == 'POST'
            ? await http.post(Uri.parse(url),
                headers: headers, body: requestBody)
            : await http.patch(Uri.parse(url),
                headers: headers, body: requestBody);

    log.i('API code: ${response.statusCode}');
    log.i('API body: ${response.body} $url');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      handleError(context, response);
      return http.Response('Error occurred', response.statusCode);
    }
  }

  static void handleException(BuildContext context, dynamic e,
      [StackTrace? stackTrace]) {
    // Handle exceptions
    log.e('Exception occurred: $e');
    // Report the exception to Sentry
    Sentry.captureException(e, stackTrace: stackTrace);
  }

  static void handleError(BuildContext context, http.Response response) {
    String errorMessage;
    final statusCode = response.statusCode;
    log.w('Client error occurred: $statusCode');

    Map responseBody;
    try {
      responseBody = json.decode(response.body);
    } catch (e) {
      log.e('Failed to decode response body: $e');
      responseBody = {};
    }

    final detail = responseBody['detail'] ?? 'Unknown Error';
    errorMessage = '$detail';

    /*
     We primarily use ModelViewSets on the backend, which provide consistent wrappers
     for handling validation errors. These errors are typically returned in a map with
     the format: {"problematic_field": [reasons]}.

     Given this consistency, we've implemented a custom parser that converts these
     errors into user-friendly messages. This implementation assumes the backend adheres 
     to this format. However, if the backend changes how it returns 400 errors, this 
     parser may need to be updated accordingly.

     If the parsing logic here starts failing, the first place to investigate should be 
     the backend's response format, as it may have changed. This parser relies on the 
     backend respecting the agreed-upon structure.

     Note: This comment reflects the backend as of [date:29/08/2-24 ,version:0.1].
    */

    if (statusCode >= 400 && statusCode < 500) {
      errorMessage = parseClientError(responseBody);
    } else if (statusCode >= 500 && statusCode < 600) {
      errorMessage = parseServerError(statusCode);
    } else {
      errorMessage = 'An error occurred. Please try again.';
    }

    if (errorMessage.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          duration: Duration(seconds: 5),
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  static String parseClientError(Map responseBody) {
    String errorMessage = '';
    responseBody.forEach((k, v) {
      if (v is List) {
        errorMessage += v
            .map((validationErr) => "${capitalizeFieldName(k)}: $validationErr")
            .join("\n");
      } else {
        errorMessage += v;
      }
    });
    return errorMessage;
  }

  static String parseServerError(int statusCode) {
    switch (statusCode) {
      case 500:
        return 'Internal server error. Please try again later.';
      case 502:
        return 'Bad gateway. Please try again later.';
      case 503:
        return 'Service unavailable. Please try again later.';
      case 504:
        return 'Gateway timeout. Please try again later.';
      default:
        return 'Server error occurred. Please try again.';
    }
  }

  static String capitalizeFieldName(String fieldName) {
    return fieldName
        .replaceAll("_", " ")
        .replaceAll("-", " ")
        .split(" ")
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(" ");
  }

  static String getAuthApp() {
    if (Platform.isAndroid) {
      return 'google_${appLabel}_android';
    } else if (Platform.isIOS) {
      return 'google_${appLabel}_ios';
    } else {
      return '';
    }
  }

  // Function to asynchronously retrieve the device's IP address
  static Future<String> _getDeviceIP() async {
    try {
      // Retrieve the device's IP address
      for (var interface in await NetworkInterface.list()) {
        for (var addr in interface.addresses) {
          // Check if it's an IP address and not a loopback address
          if (addr.address != '127.0.0.1' &&
              addr.type == InternetAddressType.IPv4) {
            return addr.address;
          }
        }
      }
    } catch (e) {
      // @TODO: Use logger
      log.i('Failed to get device IP: $e');
    }
    return 'Unknown';
  }
}
