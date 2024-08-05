import 'package:client_pharmanathi/Repository/appointment_repository.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

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
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _appointmentsNotifier.dispose();
  }
}
