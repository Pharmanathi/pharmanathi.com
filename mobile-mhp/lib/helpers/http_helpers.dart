import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'package:pharma_nathi/logging.dart';
import 'package:provider/provider.dart';

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

  static String? retrieveLocaAPIToken(BuildContext context){
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    return userProvider.backendToken; 
  }

  static Future<http.Response> httpRequestWithAuthorization(
    BuildContext context,
    String url,
    String method, // 'GET' or 'POST'
    String requestBody,
  ) async {
    String authorizationToken = '';
    
    final tokenString = Apihelper.retrieveLocaAPIToken(context);

    if (tokenString != null) {
      final Map<String, dynamic> tokenMap = json.decode(tokenString);
      final tokenValue = tokenMap['key'];
      authorizationToken = 'Token $tokenValue';
    } else {
      print('Error: Authorization token is null');
    }

    Map<String, String> headers = {
      'Authorization': authorizationToken,
      'Auth-App': await getAuthApp(),
      'Device-IP': await _getDeviceIP(),
    };

    if (method == 'POST') {
      headers['Content-Type'] = 'application/json';
    }

    final response = method == 'GET'
        ? await http.get(Uri.parse(url), headers: headers)
        : await http.post(Uri.parse(url), headers: headers, body: requestBody);

    print('API code: ${response.statusCode}');
    print('API body: ${response.body}');

    if (response.statusCode == 200) {
      return response;
    } else {
      handleError(context, response);
      return http.Response('Error occurred', response.statusCode);
    }
  }

  static void handleException(BuildContext context, dynamic e) {
    //* Handle exceptions
    log.e('Exception occurred: $e');
    // TODO: Implement Sentry or another error reporting framework
  }

  static void handleError(BuildContext context, http.Response response) {
    String errorMessage;
    final statusCode = response.statusCode;

    if (statusCode >= 400 && statusCode < 500) {
      log.w('Client error occurred: $statusCode');
      // Extract error message from response body if available
      final responseBody = json.decode(response.body);
      final detail = responseBody['detail'] ??
          'Unknown Error'; // Default to 'Unknown Error' if detail is not present
      errorMessage = '$detail';
    } else if (statusCode >= 500 && statusCode < 600) {
      log.e('Server error occurred: $statusCode');
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
      print('Failed to get device IP: $e');
    }
    return 'Unknown';
  }
}

Map<String, dynamic>? getUserInfo(context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  return userProvider.userData;
}

void setUserDataProxy(Map<String, dynamic> userData, context) {
  final userProvider = Provider.of<UserProvider>(context, listen: false);
  userProvider.setUserData(userData);
}

