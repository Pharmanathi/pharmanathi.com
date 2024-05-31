// ignore_for_file: non_constant_identifier_names

import 'package:intl/intl.dart';

class Appointment {
  final String time;
  final String name;
  final String patientdetails;
  final String appointmentTime;
  final String imageURL;
  final String status;
  final String clinic_name;
  final String consult_details;
  final String clinic_address;
  final String appointmentDate;

  Appointment({
    required this.time,
    required this.name,
    required this.patientdetails,
    required this.clinic_name,
    required this.clinic_address,
    required this.consult_details,
    required this.appointmentTime,
    required this.imageURL,
    required this.status,
    required this.appointmentDate,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final DateTime dateTimeUtc = DateTime.parse(json['start_time']);

    // Convert the UTC DateTime object to local time
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();

    // Format the date to "dd MMM yyyy" (e.g., "27 May 2023")
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'en_US');
    final String formattedDate = dateFormatter.format(dateTimeLocal);

    // Format the time to "HH:mm" (e.g., "13:30 MP")
    final DateFormat timeFormatter = DateFormat('HH:mm a', 'en_US');
    final String formattedTime = timeFormatter.format(dateTimeLocal);

// Determines the status based on the current date and start time
    String determineStatus(Map<String, dynamic> json) {
      String status = '';

      try {
        final String startDateTimeString = json['start_time'];
        final String endDateTimeString = json['end_time'];

        // Parse the start time and end time
        final DateTime startDateTime = DateTime.parse(startDateTimeString);
        final DateTime endDateTime = DateTime.parse(endDateTimeString);
        final DateTime currentDateTime = DateTime.now();

        if (currentDateTime.isAfter(startDateTime) &&
            currentDateTime.isBefore(endDateTime)) {
          status = 'In Progress';
        } else if (currentDateTime.isBefore(startDateTime)) {
          status = 'Upcoming';
        } else if (currentDateTime.isAfter(endDateTime)) {
          status = 'Completed';
        }
      } catch (error) {
        // Handle parsing error
        print('Error parsing date time: $error');
      }

      return status;
    }

    return Appointment(
      clinic_name: json['clinic_name'] ?? 'Default clinic_name',
      clinic_address: json['practicelocations'] ?? 'Default clinic_address',
      consult_details: json['reason'] ?? 'Default consult_details',
      time: formattedTime,
      patientdetails: json['details'] ?? 'patient details',
      name: '${json['patient']['first_name']} ${json['patient']['last_name']}',
      appointmentTime: formattedTime,
      appointmentDate: formattedDate,
      imageURL: '',
      status: determineStatus(json),
    );
  }
}
