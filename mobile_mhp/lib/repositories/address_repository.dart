import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/models/user.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

class AddressRepository {
  final ApiProvider apiProvider;

  AddressRepository(this.apiProvider);

  Future<List<Address>> fetchAddresses(BuildContext context, List<int> practiceLocationIds) async {
    List<Address> addresses = [];

    try {
      for (int id in practiceLocationIds) {
        final response = await apiProvider.fetchAddressById(context, id);

        if (response.statusCode == 200) {
          final Map<String, dynamic> data = jsonDecode(response.body);
          addresses.add(Address.fromJson(data));
        } else {
          // Log and throw error for non-200 responses
          final errorMessage = 'Failed to load address for ID $id: '
              '${response.statusCode} ${response.reasonPhrase}';
          await Sentry.captureMessage(errorMessage, level: SentryLevel.error);
          throw Exception(errorMessage);
        }
      }

      return addresses;
    } catch (e, stackTrace) {
      // Capture unexpected exceptions
      await Sentry.captureException(e, stackTrace: stackTrace);
      throw Exception('Failed to load addresses: $e');
    }
  }
}
