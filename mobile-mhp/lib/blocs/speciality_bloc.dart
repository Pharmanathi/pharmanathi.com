import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart'; 
import '../models/user.dart';
import '../repositories/speciality_repository.dart';

class SpecialityBloc with ChangeNotifier {
  final SpecialityRepository specialityRepository;
  List<Speciality> _specialities = [];
  bool _isLoading = false;
  String? _error;

  SpecialityBloc(this.specialityRepository);

  List<Speciality> get specialities => _specialities;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSpecialities(BuildContext context) async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _specialities = await specialityRepository.fetchSpecialities(context);
      _error = null;
    } catch (e, stackTrace) {
      _error = e.toString();
      await Sentry.captureException(e, stackTrace: stackTrace); 
    } finally {
      _isLoading = false;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        notifyListeners();
      });
    }
  }
}
