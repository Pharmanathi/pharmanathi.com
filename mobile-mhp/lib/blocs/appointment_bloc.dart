import 'package:flutter/material.dart';
import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

class AppointmentBloc {
  final AppointmentRepository _appointmentRepository;
  final ValueNotifier<List<Appointment>?> _appointmentsNotifier = ValueNotifier<List<Appointment>?>(null);

  ValueNotifier<List<Appointment>?> get appointmentsNotifier => _appointmentsNotifier;

  AppointmentBloc(this._appointmentRepository);

  Future<void> fetchAppointments(BuildContext context) async {
    try {
      final appointments = await _appointmentRepository.fetchAppointments(context);
      _appointmentsNotifier.value = appointments;
    } catch (e) {
      // Handle error
      _appointmentsNotifier.value = null;
    }
  }

  void dispose() {
    _appointmentsNotifier.dispose();
  }
}
