import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import '../services/api_provider.dart';

class DoctorRepository {
  final ApiProvider _apiProvider;

  DoctorRepository(this._apiProvider);

  Future<bool> updateDoctorDetails(BuildContext context, int doctorid,
      Map<String, dynamic> userDetails) async {
    try {
      final response =
          await _apiProvider.updateDoctorDetails(context, doctorid, userDetails);

      if (response.statusCode == 200) {
        return true;
      } else {
        // Capture non-successful responses
        await Sentry.captureMessage(
          'Failed to update doctor details: ${response.statusCode} ${response.body}',
          level: SentryLevel.error,
        );
        return false;
      }
    } catch (e, stackTrace) {
      // Capture exceptions
      await Sentry.captureException(e, stackTrace: stackTrace);
      return false;
    }
  }
}
