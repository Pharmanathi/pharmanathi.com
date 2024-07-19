import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/user.dart';
import '../repositories/doctor_repository.dart';

class DoctorBloc {
  final DoctorRepository _doctorRepository;
  final ValueNotifier<bool> _postStatusNotifier = ValueNotifier<bool>(false);

  ValueNotifier<bool> get postStatusNotifier => _postStatusNotifier;

  DoctorBloc(this._doctorRepository);

  Future<void> updateUserDetails(BuildContext context, int userId,
      Map<String, dynamic> userDetails) async {
    try {
      final success = await _doctorRepository.updateUserDetails(
          context, userId, userDetails);
      _postStatusNotifier.value = success;
    } catch (e, stackTrace) {
      _postStatusNotifier.value = false;
      await Sentry.captureException(e, stackTrace: stackTrace);
    }
  }

  void dispose() {
    _postStatusNotifier.dispose();
  }
}
