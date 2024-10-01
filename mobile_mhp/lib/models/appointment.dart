import 'package:intl/intl.dart';

class Appointment {
  final String patientdetails;
  final String appointmentTime;
  final String imageURL;
  final String status;
  final String clinic_name;
  final String consult_details;
  final String clinic_address;
  final String appointmentDate;
  final String patientName;
  final bool isOnlineAppointment;

  Appointment({
    required this.patientName,
    required this.isOnlineAppointment,
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
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'en_US');
    final String formattedDate = dateFormatter.format(dateTimeLocal);
    final DateFormat timeFormatter = DateFormat('HH:mm a', 'en_US');
    final String formattedTime = timeFormatter.format(dateTimeLocal);

    String determineStatus(Map<String, dynamic> json) {
      String status = '';
      try {
        final DateTime startDateTime = DateTime.parse(json['start_time']);
        final DateTime endDateTime = DateTime.parse(json['end_time']);
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
        print('Error parsing date time: $error');
      }
      return status;
    }

    return Appointment(
      isOnlineAppointment: json['appointment_type']['is_online'],
      patientName:
          '${json['patient']['first_name']} ${json['patient']['last_name']}',
      clinic_name: json['clinic_name'] ?? 'Default clinic_name',
      clinic_address: json['practicelocations'] ?? 'Default clinic_address',
      consult_details: json['reason'] ?? 'Default consult_details',
      patientdetails: json['details'] ?? 'patient details',
      appointmentTime: formattedTime,
      appointmentDate: formattedDate,
      imageURL: json['patient']['image_url'], 
      status: determineStatus(json),
    );
  }
}
