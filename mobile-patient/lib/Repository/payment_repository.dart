import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_provider.dart';

class PaymentRepository {
  final ApiProvider apiProvider;

  PaymentRepository(this.apiProvider);

  Future<String> initializePayment(BuildContext context, int amount) async {
    final response = await apiProvider.initializePayment(context, amount);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['authorization_url'] as String;
    } else {
      throw Exception('Failed to initialize payment: ${response.body}');
    }
  }

  Future<bool> verifyPayment(BuildContext context, String reference) async {
    final response = await apiProvider.verifyPayment(context, reference);
    if (response.statusCode == 200) {
      final responseData = jsonDecode(response.body) as Map<String, dynamic>;
      return responseData['status'] == 'success';
    } else {
      throw Exception('Failed to verify payment: ${response.body}');
    }
  }
}
