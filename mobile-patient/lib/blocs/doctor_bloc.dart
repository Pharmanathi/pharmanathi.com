import 'package:client_pharmanathi/Repository/doctor_repository.dart';
import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class DoctorBloc {
  final DoctorRepository _doctorRepository;
  final ValueNotifier<List<Doctor>?> _doctorsNotifier =
      ValueNotifier<List<Doctor>?>(null);

  ValueNotifier<List<Doctor>?> get doctorsNotifier => _doctorsNotifier;

  DoctorBloc(this._doctorRepository);

  Future<void> fetchDoctors(BuildContext context) async {
    try {
      final doctors = await _doctorRepository.fetchDoctors(context);
      _doctorsNotifier.value = doctors;
    } catch (e, stackTrace) {
      _doctorsNotifier.value = null;
      Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void dispose() {
    _doctorsNotifier.dispose();
  }
}
