import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:patient/model/doctor_data.dart';
import 'package:patient/services/api_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AddressRepository {
  final ApiProvider apiProvider;

  AddressRepository(this.apiProvider);

  Future<Address> fetchAddressById(BuildContext context, int id) async {
    try {
      final response = await apiProvider.fetchAddressById(context, id);

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        return Address.fromJson(data);
      } else {
        // Log and throw error for non-200 responses
        final errorMessage = 'Failed to load address for ID $id: '
            '${response.statusCode} ${response.reasonPhrase}';
        await Sentry.captureMessage(errorMessage, level: SentryLevel.error);
        throw Exception(errorMessage);
      }
    } catch (e, stackTrace) {
      // Capture unexpected exceptions
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw Exception('Failed to load address: $e');
    }
  }
}
