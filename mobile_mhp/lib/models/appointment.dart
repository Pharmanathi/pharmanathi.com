import 'package:intl/intl.dart';

class Appointment {
  final String patientdetails;
  final String appointmentTime;
  final String imageURL;
  final String consultationFee;
  final String status;
  final String clinic_name;
  final String consult_details;
  final String clinic_address;
  final String appointmentDate;
  final String patientName;
  final bool isOnlineAppointment;
  final String appointmentDuration;

  Appointment({
    required this.patientName,
    required this.isOnlineAppointment,
    required this.patientdetails,
    required this.consultationFee,
    required this.clinic_name,
    required this.clinic_address,
    required this.consult_details,
    required this.appointmentTime,
    required this.imageURL,
    required this.status,
    required this.appointmentDate,
    required this.appointmentDuration,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    final DateTime dateTimeUtc = DateTime.parse(json['start_time']);
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'en_US');
    final String formattedDate = dateFormatter.format(dateTimeLocal);
    final DateFormat timeFormatter = DateFormat('HH:mm', 'en_US');
    final String formattedTime = timeFormatter.format(dateTimeLocal);

    //* Method to determine the appointment duration
    String determineAppointmentDuration(Map<String, dynamic> json) {
      String duration = '';
      try {
        final DateTime startDateTime = DateTime.parse(json['start_time']);
        final DateTime endDateTime = DateTime.parse(json['end_time']);

        Duration difference = endDateTime.difference(startDateTime);
        int hours = difference.inHours;
        int minutes = difference.inMinutes.remainder(60);

        if (hours > 0) {
          duration =
              '$hours hour${hours > 1 ? "s" : ""} ${minutes > 0 ? "$minutes minutes" : ""}';
        } else {
          duration = '$minutes min';
        }
      } catch (error) {
        print('Error calculating appointment duration: $error');
        duration = 'Unknown';
      }
      return duration;
    }

    //* Method to determine the appointment status
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
        print('Error determining status: $error');
      }
      return status;
    }

    //* Access cost from the appointment_types array
    String consultationFee = (json['doctor']['appointment_types'] != null &&
            json['doctor']['appointment_types'].isNotEmpty)
        ? json['doctor']['appointment_types'][0]['cost'] ?? ''
        : 'Unknown';

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
      consultationFee: consultationFee,
      imageURL: json['patient']['image_url'],
      status: determineStatus(json),
      appointmentDuration: determineAppointmentDuration(json),
    );
  }
}
