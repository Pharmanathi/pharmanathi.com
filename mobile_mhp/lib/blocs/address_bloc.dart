import 'package:flutter/material.dart';
import 'package:pharma_nathi/models/user.dart';
import 'package:pharma_nathi/repositories/address_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


class AddressBloc with ChangeNotifier {
  final AddressRepository addressRepository;
  List<Address> _addresses = [];
  bool _isLoading = false;
  String? _error;

  AddressBloc(this.addressRepository);

  List<Address> get addresses => _addresses;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAddresses(BuildContext context, List<int> practiceLocationIds) async {
    _isLoading = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      notifyListeners();
    });

    try {
      _addresses = await addressRepository.fetchAddresses(context, practiceLocationIds);
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
