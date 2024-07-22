import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import '../models/user.dart';


class SpecialityRepository {
  final ApiProvider apiProvider;

  SpecialityRepository(this.apiProvider);

  Future<List<Speciality>> fetchSpecialities(BuildContext context) async {
    final response = await apiProvider.fetchSpecialities(context);
    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Speciality.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load specialities');
    }
  }
}
