// ignore_for_file: must_be_immutable, prefer_const_constructors, non_constant_identifier_names, use_super_parameters

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pharma_nathi/screens/pages/appiontment_details.dart';

class AppiontmentTile extends StatelessWidget {
  final String name;
  final String status;
  final String patientdetails;
  final String clinic_name;
  final String clinic_address;
  final String appiontment_date;
  final String time;
  final int appointmentType;
  final String consult_details;

  const AppiontmentTile({
    Key? key,
    required this.name,
    required this.status,
    required this.appointmentType,
    required this.patientdetails,
    required this.clinic_name,
    required this.clinic_address,
    required this.appiontment_date,
    required this.time,
    required this.consult_details,
  }) : super(key: key);

  factory AppiontmentTile.fromJson(Map<String, dynamic> json) {
    final DateTime dateTimeUtc = DateTime.parse(json['start_time']);

    // Convert the UTC DateTime object to local time
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();

    // Format the date to "dd MMM yyyy" (e.g., "27 May 2023")
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'en_US');
    final String formattedDate = dateFormatter.format(dateTimeLocal);

    // Format the time to "HH:mm" (e.g., "13:30 MP")
    final DateFormat timeFormatter = DateFormat('HH:mm a', 'en_US');
    final String formattedTime = timeFormatter.format(dateTimeLocal);

    final DateFormat timeFormatterStatuscheck =
        DateFormat('yyyy-MM-ddTHH:mm:ss+zzzz');

    String status = '';
    try {
      //* Parsing with time zone format
      final DateTime formattedTimeDateTime =
          timeFormatterStatuscheck.parse(json['start_time']);

      final localFormatter = DateFormat('yyyy-MM-dd HH:mm:ss');
      final String formattedTimeInLocal =
          localFormatter.format(formattedTimeDateTime);
      final DateTime currentDateTime = DateTime.now();

      if (DateTime.parse(formattedTimeInLocal).isAfter(currentDateTime)) {
        status = 'Upcoming';
      } else {
        status = 'Passed';
      }
    } catch (error) {
      //! Handle parsing error
      print('Error parsing start_time: $error');
    }

    //* Extract is_online from appointment_types list
    int appointmentType = 0; // Default value
    if (json['doctor'] != null &&
        json['doctor']['appointment_types'] is List &&
        json['doctor']['appointment_types'].isNotEmpty) {
      appointmentType =
          json['doctor']['appointment_types'][0]['is_online'] ? 1 : 2;
    }

    return AppiontmentTile(
      name: '${json['patient']['first_name']} ${json['patient']['last_name']}',
      patientdetails: json['details'] ?? 'patient details',
      appointmentType: appointmentType,
      clinic_name: json['clinic_name'] ?? 'Default clinic_name',
      clinic_address: json['practicelocations'] ?? 'Default clinic_address',
      appiontment_date: formattedDate,
      time: formattedTime,
      status: status,
      consult_details: json['reason'] ?? 'Default consult_details',
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //* Navigate to OnlineConsultation page with corresponding data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineConsultation(
              //* Pass the corresponding data to OnlineConsultation
              patientName: name,
              appointmentTime: time,
              details: patientdetails,
              clinic_name: clinic_name,
              clinic_address: clinic_address,
              appiontment_date: appiontment_date,
              time: time,
              consult_details: consult_details,
            ),
          ),
        );
      },
      child: Container(
        height: 100,
        width: 180,
        margin: EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Align(
          alignment: Alignment.bottomLeft,
          child: Padding(
            padding: EdgeInsets.only(left: 20, top: 70),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  time,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  appiontment_date,
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
