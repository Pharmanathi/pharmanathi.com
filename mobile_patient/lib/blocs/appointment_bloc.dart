import 'package:patient/routes/app_routes.dart';
import 'package:patient/views/widgets/payment_webview.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:patient/Repository/appointment_repository.dart';
import 'package:patient/model/appointment_data.dart';

import '../views/widgets/SuccessMessageWidget.dart';

class AppointmentBloc {
  final AppointmentRepository _appointmentRepository;
  final ValueNotifier<List<Appointment>?> _appointmentsNotifier =
      ValueNotifier<List<Appointment>?>(null);

  ValueNotifier<List<Appointment>?> get appointmentsNotifier =>
      _appointmentsNotifier;

  AppointmentBloc(this._appointmentRepository);

  Future<void> fetchAppointments(BuildContext context) async {
    try {
      final appointments =
          await _appointmentRepository.fetchAppointments(context);
      _appointmentsNotifier.value = appointments;
    } catch (e, stackTrace) {
      _appointmentsNotifier.value = null;
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  Future<void> bookAppointment(
      BuildContext context, Map<String, dynamic> appointmentData) async {
    try {
      final responseData = await _appointmentRepository.bookAppointment(
          context, appointmentData);

      if (responseData.containsKey('action_data') &&
          responseData['action_data'] != null) {
        final paymentUrl = responseData['action_data']['payment_url'];
        // Navigate to PaymentWebView
        Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => PaymentWebView(
            authorizationUrl: paymentUrl,
            onPaymentCompleted: () {
              _showSuccessMessage(context);
              _navigateToAppointmentScreen(context);
            },
          ),
        ));
      } else {
        _showSuccessMessage(context);
        _navigateToAppointmentScreen(context);
      }
    } catch (e, stackTrace) {
      // Handle error
      Sentry.captureException(e, stackTrace: stackTrace);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error booking appointment')),
      );
    }
  }

  void _showSuccessMessage(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Your appointment has been booked successfully!'),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _navigateToAppointmentScreen(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.appointments);
  }

  void dispose() {
    _appointmentsNotifier.dispose();
  }
}
