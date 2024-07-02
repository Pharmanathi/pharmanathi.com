import 'dart:async';
import 'package:flutter/material.dart';

import '../models/appointment.dart';
import '../repositories/appointment_repository.dart';

class AppointmentBloc {
  final AppointmentRepository _appointmentRepository;
  final StreamController<List<Appointment>> _appointmentController =
      StreamController<List<Appointment>>();

  Stream<List<Appointment>> get appointments => _appointmentController.stream;

  AppointmentBloc(this._appointmentRepository);

  fetchAppointments(BuildContext context) async {
    final appointments = await _appointmentRepository.fetchAppointments(context);
    _appointmentController.sink.add(appointments);
  }

  dispose() {
    _appointmentController.close();
  }
}
