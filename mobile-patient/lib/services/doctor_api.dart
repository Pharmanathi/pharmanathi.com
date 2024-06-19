import 'dart:convert';
import 'package:flutter/material.dart';
import '../helpers/api_helpers.dart';
import '../screens/components/doctors/doctor_data.dart';

Future<List<DoctorDetail>> fetchDoctors(BuildContext context) async {
  try {
    final String apiUrl = ApiHelper.getApiBaseUrl();
    final response = await ApiHelper.httpRequestWithAuthorization(
      context,
      '$apiUrl/doctors/',
      'GET',
      '',
    );
    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      List<DoctorDetail> doctors = [];

      for (var doctorData in data) {
        int appointmentTypeId =
            int.tryParse(doctorData['appointment_types'][0]['id'].toString()) ??
                0;

        doctors.add(
          DoctorDetail(
            has_consulted_before: doctorData['has_consulted_before'],
            doctorId: doctorData['id'],
            appointmentType: appointmentTypeId,
            name:
                '${doctorData['user']['first_name']} ${doctorData['user']['last_name']}',
            distance: '5 miles', // Dummy data for distance
            title: doctorData['user']['title'] ??
                '婦科醫生', // Default title if not provided
            rating: '4.5', // Dummy data for rating
            imageUrl: 'https://picsum.photos/200', // Random image URL
            status: 'InPerson Visit', // Dummy data for status
            location:
                '123 Medical Lane, Health City', // Dummy data for location
            experience: '10 years', // Dummy data for experience
          ),
        );
      }

      return doctors;
    } else {
      // Utilize the ApiHelper's error handling method
      ApiHelper.handleError(context, response);
      return []; // Or throw an error if you want to handle it differently
    }
  } catch (error) {
    // Utilize the ApiHelper's error handling method
    ApiHelper.handleException(context, error);
    return []; // Or throw an error if you want to handle it differently
  }
}
