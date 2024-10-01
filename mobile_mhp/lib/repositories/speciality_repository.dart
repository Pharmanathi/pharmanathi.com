import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import '../models/user.dart';

class SpecialityRepository {
  final ApiProvider apiProvider;

  SpecialityRepository(this.apiProvider);

  Future<List<Speciality>> fetchSpecialities(BuildContext context) async {
    try {
      final response = await apiProvider.fetchSpecialities(context);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Speciality.fromJson(json)).toList();
      } else {
        // Capture non-successful responses
        await Sentry.captureMessage(
          'Failed to load specialities: ${response.statusCode} ${response.body}',
          level: SentryLevel.error,
        );
        throw Exception('Failed to load specialities');
      }
    } catch (e, stackTrace) {
      // Capture exceptions
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw Exception('Failed to load specialities');
    }
  }
}
