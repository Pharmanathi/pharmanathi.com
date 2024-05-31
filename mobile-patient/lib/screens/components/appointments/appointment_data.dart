import 'package:intl/intl.dart';

class AppointmentData {
  final String time;
  final String name;
  final String date;
  final String appointmentTime;
  final String imageURL;
  final String status;
  final String title;
  final String appiontment_date;
  final consult_details;
  final clinic_name;
  final String appiontmenType;
  final clinic_address;

  AppointmentData({
    required this.time,
    required this.name,
    required this.date,
    required this.consult_details,
    required this.appiontmenType,
    required this.clinic_name,
    required this.clinic_address,
    required this.appointmentTime,
    required this.imageURL,
    required this.status,
    required this.title,
    required this.appiontment_date,
  });

  factory AppointmentData.fromJson(Map<String, dynamic> json) {
    final doctorFirstName = json['doctor']['user']['first_name'] ?? '';
    final doctorLastName = json['doctor']['user']['last_name'] ?? '';
    final doctorName = '$doctorFirstName $doctorLastName';
// Parse the date string to a DateTime object in UTC
  final DateTime dateTimeUtc = DateTime.parse(json['start_time']);

  // Convert the UTC DateTime object to local time
  final DateTime dateTimeLocal = dateTimeUtc.toLocal();

  // Format the date to "dd MMM yyyy" (e.g., "27 May 2023")
  final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'en_US');
  final String formattedDate = dateFormatter.format(dateTimeLocal);

  // Format the time to "HH:mm" (e.g., "13:30")
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
        status = 'Completed';
      }
    } catch (error) {
      //! Handle parsing error
      print('Error parsing start_time: $error');
    }

    String appointmentType = "";
    try {
      final int appointmentTypeValue = json['appiontment_type'] ?? 0;


      if (appointmentTypeValue == 1) {
        appointmentType = "In Person Visit";
      } else {
        appointmentType = "Online Consultation";
      }
      print('Appointment Type: $appointmentType');
    } catch (error) {
      print(
        'Error parsing appointment type:',
      );
    }

    return AppointmentData(
      time: json['time'] ?? '',
      name: doctorName,
      date: formattedDate,
      consult_details: json['reason'] ?? '',
      clinic_name: json['practicelocations'] ?? 'No location Specified',
      clinic_address: json['practicelocations'] ?? 'No address Specified',
      appointmentTime: formattedTime,
      appiontment_date: json['appointmentTime'] ?? '',
      imageURL: json['imageURL'] ?? '',
      status: status,
      title: json['title'] ?? '',
      appiontmenType: appointmentType,
    );
  }
}
