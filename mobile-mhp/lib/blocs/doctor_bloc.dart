import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../repositories/doctor_repository.dart';

class DoctorBloc extends ChangeNotifier {
  final DoctorRepository _doctorRepository;
  final ValueNotifier<bool> _postStatusNotifier = ValueNotifier<bool>(false);

  ValueNotifier<bool> get postStatusNotifier => _postStatusNotifier;

  DoctorBloc(this._doctorRepository);

  Future<void> updateDoctorDetails(BuildContext context, int doctorid,
      Map<String, dynamic> userDetails) async {
    try {
      final success = await _doctorRepository.updateDoctorDetails(
          context, doctorid, userDetails);
      _postStatusNotifier.value = success;
      notifyListeners();
    } catch (e, stackTrace) {
      _postStatusNotifier.value = false;
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  @override
  void dispose() {
    _postStatusNotifier.dispose();
    super.dispose();
  }
}
