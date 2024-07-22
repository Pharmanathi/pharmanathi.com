import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/blocs/doctor_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/repositories/doctor_repository.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models/user.dart';
import '../../screens/components/UserProvider.dart';

class OnboardDetailsScreen extends StatefulWidget {
  @override
  _OnboardDetailsScreenState createState() => _OnboardDetailsScreenState();
}

class _OnboardDetailsScreenState extends State<OnboardDetailsScreen> {
  late final DoctorBloc doctorBloc;
  late Future<List<Speciality>> _specialitiesFuture;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hpcsaNoController = TextEditingController();
  final TextEditingController _mpNoController = TextEditingController();
  List<Speciality> _selectedSpecialities = [];
  List<int> _selectedPracticeLocations = [];

  @override
  void initState() {
    super.initState();
    doctorBloc = DoctorBloc(DoctorRepository(ApiProvider()));
    _specialitiesFuture = fetchSpecialities(context);
  }

  @override
  void dispose() {
    _hpcsaNoController.dispose();
    _mpNoController.dispose();
    doctorBloc.dispose();
    super.dispose();
  }

  Future<List<Speciality>> fetchSpecialities(BuildContext context) async {
    final response = await ApiProvider().fetchSpecialities(context);

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Speciality.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load specialities');
    }
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userInfo = userProvider.user;

      List<int> specialitiesData = _selectedSpecialities
          .map((s)  => s.id )
          .toList();

      final Map<String, dynamic> partialUpdates = {
        'hpcsa_no': _hpcsaNoController.text,
        'mp_no': _mpNoController.text,
        'specialities': specialitiesData,
        'practice_locations': _selectedPracticeLocations,
      };

      doctorBloc.updateUserDetails(context, userInfo?.doctorProfile?.id ?? 0, partialUpdates);

      doctorBloc.postStatusNotifier.addListener(() {
        if (doctorBloc.postStatusNotifier.value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User details submitted successfully'),
              backgroundColor: Colors.green,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(vertical: 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to submit user details'),
              backgroundColor: Pallet.DANGER_600,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(vertical: 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> availablePracticeLocations = [1, 2, 3, 4, 5];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Onboarding Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _hpcsaNoController,
                decoration: const InputDecoration(labelText: 'HPCSA Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your HPCSA Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mpNoController,
                decoration: const InputDecoration(labelText: 'MP Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your MP Number';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Specialities'),
              FutureBuilder<List<Speciality>>(
                future: _specialitiesFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('No specialities available');
                  } else {
                    final specialities = snapshot.data!;
                    return MultiSelectDialogField<Speciality>(
                      items: specialities
                          .map((speciality) => MultiSelectItem<Speciality>(
                              speciality, speciality.name))
                          .toList(),
                      title: const Text('Select Specialities'),
                      selectedItemsTextStyle:
                          const TextStyle(color: Colors.black),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: Colors.blue,
                          width: 2,
                        ),
                      ),
                      buttonText: const Text('Select Specialities'),
                      onConfirm: (selected) {
                        setState(() {
                          _selectedSpecialities = selected;
                        });
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Practice Locations'),
              Wrap(
                spacing: 8.0,
                children: availablePracticeLocations.map((locationId) {
                  return ChoiceChip(
                    label: Text('Location $locationId'),
                    selected: _selectedPracticeLocations.contains(locationId),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedPracticeLocations.add(locationId);
                        } else {
                          _selectedPracticeLocations.remove(locationId);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: const Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
