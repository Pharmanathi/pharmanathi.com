import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:logger/logger.dart';
import '../screens/components/UserProvider.dart';

abstract class ApiHelper {
  static final Logger _logger = getLogger(ApiHelper);

  static Future<http.Response> fetchData(
    BuildContext context,
    Future<http.Response> Function(BuildContext) apiCall,
  ) async {
    try {
      return await apiCall(context);
    } catch (e) {
      handleException(context, e);
      return http.Response('Error occurred', 500); //* Return a dummy response
    }
  }

  static String? retrieveLocaAPIToken(BuildContext context){
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.backendToken;
  }

  static Future<http.Response> httpRequestWithAuthorization(
    BuildContext context,
    String url,
    String method, //* 'GET' or 'POST'
    String requestBody,
  ) async {
    String authorizationToken = '';

    final tokenString = ApiHelper.retrieveLocaAPIToken(context);

    if (tokenString != null) {
      final Map<String, dynamic> tokenMap = json.decode(tokenString);
      final tokenValue = tokenMap['key'];
      authorizationToken = 'Token $tokenValue';
    } else {
      _logger.e('Error: Authorization token is null');
    }

    Map<String, String> headers = {
      'Authorization': authorizationToken,
      'Auth-App': await getAuthApp(),
      'Device-IP': await _getDeviceIP(),
      'Content-Type': 'application/json',
    };

    if (method == 'POST') {
      headers['Content-Type'] = 'application/json';
    }

    final response = method == 'GET'
        ? await http.get(Uri.parse(url), headers: headers)
        : await http.post(Uri.parse(url), headers: headers, body: requestBody);

    _logger.i('API code: ${response.statusCode}');
    _logger.i('API body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return response;
    } else {
      handleError(context, response);
      return http.Response('Error occurred', response.statusCode);
    }
  }

  static void handleException(BuildContext context, dynamic e) {
    //* Handle exceptions
    _logger.e('Exception occurred: $e');
    // TODO: Implement Sentry or another error reporting framework
  }

  static void handleError(BuildContext context, http.Response response) {
    String errorMessage;
    final statusCode = response.statusCode;
    print('Handling error for status code: $statusCode'); // Debugging

    if (statusCode >= 400 && statusCode < 500) {
      _logger.w('Client error occurred: $statusCode');
      // Extract error message from response body if available
      final responseBody = json.decode(response.body);
      final detail = responseBody['detail'] ?? 'Unknown Error';
      errorMessage = '$detail';
    } else if (statusCode >= 500 && statusCode < 600) {
      _logger.e('Server error occurred: $statusCode');
      switch (statusCode) {
        case 500:
          errorMessage = 'Internal server error. Please try again later.';
          break;
        case 502:
          errorMessage = 'Bad gateway. Please try again later.';
          break;
        case 503:
          errorMessage = 'Service unavailable. Please try again later.';
          break;
        case 504:
          errorMessage = 'Gateway timeout. Please try again later.';
          break;
        default:
          errorMessage = 'Server error occurred. Please try again.';
          break;
      }
    } else {
      errorMessage = 'An unexpected error occurred. Please try again.';
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

  static String getApiBaseUrl() {
    return dotenv.env['API_BASE_URL'] ?? "make sure you have the right url";
  }
//
  static String toTitleCase(String input) {
  // Split the input string by spaces
  List<String> words = input.split(' ');

  // Capitalize the first character of each word and make the rest lowercase
  for (int i = 0; i < words.length; i++) {
    words[i] = words[i][0].toUpperCase() + words[i].substring(1).toLowerCase();
  }

  // Join the words back together with spaces
  return words.join(' ');
}

  // Function to asynchronously retrieve the type of device (Android or iOS)
  static Future<String> getAuthApp() async {
    if (Platform.isAndroid) {
      return 'google_patient_android';
    } else if (Platform.isIOS) {
      return 'google_patient_ios';
    } else {
      return '';
    }
  }

  // Function to asynchronously retrieve the device's location
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
      _logger.w('Failed to get device IP: $e');
    }
    return 'Unknown';
  }
}

// Custom log printer
class CustomPrinter extends LogPrinter {
  final String className;

  CustomPrinter(this.className);

  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.defaultLevelColors[event.level];
    var emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    var message = event.message;

    return [color!('$emoji  $className : $message')];
  }
}

// Logger factory function
Logger getLogger(Type type) => Logger(printer: CustomPrinter(type.toString()));
