import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/api_helpers.dart' as http_helpers;

class ApiProvider {
  Future<http.Response> fetchAppointmentData(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> initializePayment(
      BuildContext context, int amount) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/payments/initialize/';
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'POST', jsonEncode({'amount': amount}));
  }

  Future<http.Response> verifyPayment(
      BuildContext context, String reference) async {
    final apiEndpoint =
        '${http_helpers.apiBaseURL}/payments/verify/$reference/';
    return await http_helpers.ApiHelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }
}
