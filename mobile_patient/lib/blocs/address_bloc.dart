import 'package:flutter/material.dart';
import 'package:patient/Repository/address_repository.dart';
import 'package:patient/model/doctor_data.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AddressBloc with ChangeNotifier {
  final AddressRepository addressRepository;
  Address? _address;  
  bool _isLoading = false;
  String? _error;

  AddressBloc(this.addressRepository);

  Address? get address => _address;  
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAddress(BuildContext context, int practiceLocationId) async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _address = await addressRepository.fetchAddressById(context, practiceLocationId);  // Updated to fetch a single address
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
