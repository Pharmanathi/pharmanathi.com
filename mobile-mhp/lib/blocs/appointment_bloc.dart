import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

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
      // Handle error
      _appointmentsNotifier.value = null;
       Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _appointmentsNotifier.dispose();
  }
}
