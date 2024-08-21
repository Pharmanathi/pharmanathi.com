import 'package:client_pharmanathi/services/api_provider.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class GoogleSignInRepository {
  final ApiProvider apiProvider;

  GoogleSignInRepository(this.apiProvider);

  Future<String> signInWithGoogle(BuildContext context, String idToken) async {
    final http.Response response = await apiProvider.signInWithGoogle(context, idToken);
    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Failed to get backend token');
    }
  }
}
