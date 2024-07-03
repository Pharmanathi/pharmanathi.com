import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class ApiProvider {
  Future<http.Response> fetchAppointmentData(BuildContext context, Function request) async {
    return await request(context);
  }
}
