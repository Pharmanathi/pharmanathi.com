import 'dart:async';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../repositories/user_repository.dart';

class UserBloc {
  final UserRepository _userRepository;
  final StreamController<User?> _userController = StreamController<User?>();

  Stream<User?> get user => _userController.stream;

  UserBloc(this._userRepository);

  fetchUserData(BuildContext context) async {
    final user = await _userRepository.fetchUserData(context);
    _userController.sink.add(user);
  }

  void dispose() {
    _userController.close();
  }
}

