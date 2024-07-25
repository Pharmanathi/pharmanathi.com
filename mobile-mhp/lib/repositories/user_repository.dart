import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/api_provider.dart';
import '../helpers/http_helpers.dart' as http_helpers;
import '../models/user.dart';

class UserRepository {
  final ApiProvider apiProvider;

  UserRepository(this.apiProvider);

  Future<User?> fetchUserData(BuildContext context) async {
    try {
      final response = await apiProvider.fetchUserData(context);
      if (response.statusCode == 200) {
        dynamic decodedData = json.decode(response.body);
        if (decodedData is Map) {
          Map<String, dynamic> userMap = Map<String, dynamic>.from(decodedData);
          return User.fromJson(userMap);
        } else {
          http_helpers.Apihelper.handleError(context, response);
          return null;
        }
      } else {
        http_helpers.Apihelper.handleError(context, response);
        return null;
      }
    } catch (e, stackTrace) {
      http_helpers.Apihelper.handleException(context, e);
       Sentry.captureException(e, stackTrace: stackTrace);
      return null;
    }
  }


}
