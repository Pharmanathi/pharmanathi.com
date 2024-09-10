import 'package:client_pharmanathi/model/appointment_type.dart';
import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:client_pharmanathi/model/patient_data.dart';
import 'package:client_pharmanathi/model/payment_data.dart';
import 'package:intl/intl.dart';

class Appointment {
  final int id;
  final String endTime;
  final Doctor doctor;
  final Patient patient;
  final String appointmentTypeRepr;
  final String appointmentTime;
  final String appointmentDate;
  final String status;
  final String reason;
  final String paymentProcess;
  final Payment payment;
  final AppointmentType appointmentType;

  Appointment({
    required this.id,
    required this.endTime,
    required this.appointmentTypeRepr,
    required this.appointmentTime,
    required this.appointmentDate,
    required this.status,
    required this.doctor,
    required this.payment,
    required this.patient,
    required this.reason,
    required this.paymentProcess,
    required this.appointmentType,
  });

  factory Appointment.fromJson(Map<String, dynamic> json) {
    // Parse the date string to a DateTime object in UTC
    final DateTime dateTimeUtc = DateTime.parse(json['start_time']);
    final DateTime endTimeUtce = DateTime.parse(json['end_time']);

    // Convert the UTC DateTime object to local time
    final DateTime dateTimeLocal = dateTimeUtc.toLocal();
    final DateTime endTimeLocal = endTimeUtce.toLocal();

    // Format the date to "dd MMM yyyy" (e.g., "27 May 2023")
    final DateFormat dateFormatter = DateFormat('dd MMM yyyy', 'en_US');
    final String formattedDate = dateFormatter.format(dateTimeLocal);

    // Format the time to "HH:mm" (e.g., "13:30")
    final DateFormat timeFormatter = DateFormat('HH:mm a', 'en_US');
    final String formattedTime = timeFormatter.format(dateTimeLocal);

    final DateFormat endtimeFormatter = DateFormat('HH:mm a', 'en_US');
    final String formattedEndtime = endtimeFormatter.format(endTimeLocal);

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

      if (json["payment"]["status"] != "PAID") {
        status = "Unpaid";
      } else if (DateTime.parse(formattedTimeInLocal)
          .isAfter(currentDateTime)) {
        status = 'Upcoming';
      } else {
        status = 'Completed';
      }
    } catch (error) {
      //! Handle parsing error @TODO: Sentry
      print('Error parsing start_time: $error');
    }

    //* Removed the unnecessary '== true' because we trust Dart to know what true means. ;)
    String appointmentType = json['appointment_type']["is_online"]
        ? "Online Consultation"
        : "In Person Visit";

    return Appointment(
      id: json['id'],
      endTime: formattedEndtime,
      appointmentTime: formattedTime,
      appointmentDate: formattedDate,
      appointmentTypeRepr: appointmentType,
      status: status,
      doctor: Doctor.fromJson(json['doctor']),
      payment: Payment.fromJson(json['payment']),
      patient: Patient.fromJson(json['patient']),
      reason: json['reason'],
      paymentProcess: json['payment_process'],
      appointmentType: AppointmentType.fromJson(json['appointment_type']),
    );
  }
}
