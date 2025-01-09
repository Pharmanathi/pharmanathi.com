import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../helpers/http_helpers.dart' as http_helpers;

class ApiProvider {
  Future<http.Response> fetchAppointmentData(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/appointments/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> fetchUserData(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/users/me/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> updateDoctorDetails(BuildContext context, int doctorid, Map<String, dynamic> userDetails) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/doctors/$doctorid/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
      context, apiEndpoint, 'PATCH', json.encode(userDetails)
    );
  }
  Future<http.Response> fetchSpecialities(BuildContext context) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/specialities/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

   Future<http.Response> signInWithGoogle(BuildContext context, String idToken) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/google-login-by-id-token?is_doctor=true&id_token=$idToken';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

  Future<http.Response> fetchAddressById(BuildContext context, int addressId) async {
    final apiEndpoint = '${http_helpers.apiBaseURL}/addresses/$addressId/';
    return await http_helpers.Apihelper.httpRequestWithAuthorization(
        context, apiEndpoint, 'GET', '');
  }

}
