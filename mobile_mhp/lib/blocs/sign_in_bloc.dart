import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:pharma_nathi/repositories/sign_in_repository.dart';
import 'package:sentry_flutter/sentry_flutter.dart';


class GoogleSignInBloc {
  final GoogleSignInRepository _googleSignInRepository;
  final ValueNotifier<bool> _isLoading = ValueNotifier<bool>(false);
  final ValueNotifier<String?> _backendToken = ValueNotifier<String?>(null);
  final ValueNotifier<String?> _error = ValueNotifier<String?>(null);

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email', 'openid']);

  GoogleSignInBloc(this._googleSignInRepository);

  ValueNotifier<bool> get isLoading => _isLoading;
  ValueNotifier<String?> get backendToken => _backendToken;
  ValueNotifier<String?> get error => _error;

  Future<void> signInWithGoogle(BuildContext context, String idToken) async {
    _isLoading.value = true;
    try {
      final token = await _googleSignInRepository.signInWithGoogle(context, idToken);
      _backendToken.value = token;
      _error.value = null;
    } catch (e, stackTrace) {
      _error.value = e.toString();
      Sentry.captureException(e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  Future<void> signOut() async {
    _isLoading.value = true;
    try {
      await _googleSignIn.signOut();
      _backendToken.value = null;
    } catch (e, stackTrace) {
      _error.value = e.toString();
      Sentry.captureException(e, stackTrace: stackTrace);
    } finally {
      _isLoading.value = false;
    }
  }

  void dispose() {
    _isLoading.dispose();
    _backendToken.dispose();
    _error.dispose();
  }
}
