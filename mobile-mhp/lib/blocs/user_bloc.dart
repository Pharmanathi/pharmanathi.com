import 'dart:async';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';


class UserBloc {
  final UserRepository _userRepository;
  final ValueNotifier<User?> _userNotifier = ValueNotifier<User?>(null);

  ValueNotifier<User?> get userNotifier => _userNotifier;

  UserBloc(this._userRepository);

  Future<void> fetchUserData(BuildContext context) async {
    try {
      final user = await _userRepository.fetchUserData(context);
      _userNotifier.value = user;
    } catch (e, stackTrace) {
      // Handle error
      _userNotifier.value = null;
      await Sentry.captureException(
        e,
        stackTrace: stackTrace,
      );
    }
  }

  void dispose() {
    _userNotifier.dispose();
  }
}
