// ignore_for_file: prefer_const_literals_to_create_immutables

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pharma_nathi/blocs/doctor_bloc.dart';
import 'package:pharma_nathi/blocs/speciality_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/views/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import '../../models/user.dart';
import '../../screens/components/UserProvider.dart';

class OnboardDetailsScreen extends StatefulWidget {
  @override
  _OnboardDetailsScreenState createState() => _OnboardDetailsScreenState();
}

class _OnboardDetailsScreenState extends State<OnboardDetailsScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hpcsaNoController = TextEditingController();
  final TextEditingController _mpNoController = TextEditingController();
  List<Speciality> _selectedSpecialities = [];
  final List<Map<String, String>> _selectedPracticeLocations = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final specialityBloc = Provider.of<SpecialityBloc>(context, listen: false);
    specialityBloc.fetchSpecialities(context);
  }

  @override
  void dispose() {
    _hpcsaNoController.dispose();
    _mpNoController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final doctorBloc = Provider.of<DoctorBloc>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userInfo = userProvider.user;

      List<int> specialitiesData =
          _selectedSpecialities.map((s) => s.id).toList();

      final List<Map<String, dynamic>> practiceLocationsData =
          _selectedPracticeLocations.map((location) {
        return {
          'address': {
            'postal_code': location['postal_code'],
            'line_1': location['line_1'],
            'suburb': location['suburb'],
            'country': location['country'],
            'city': location['city'],
            'province': location['province'],
          },
          'name': location['name'],
        };
      }).toList();

      final Map<String, dynamic> partialUpdates = {
        'hpcsa_no': _hpcsaNoController.text,
        'mp_no': _mpNoController.text,
        'specialities': specialitiesData,
        'practice_locations': practiceLocationsData,
      };

      final Completer<void> completer = Completer<void>();

      doctorBloc.postStatusNotifier.addListener(() {
        if (!completer.isCompleted) {
          completer.complete();
        }

        if (doctorBloc.postStatusNotifier.value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('User details submitted successfully'),
              backgroundColor: Pallet.SUCCESS,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(vertical: 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
          Navigator.pushReplacementNamed(context, '/home_page');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Failed to submit user details'),
              backgroundColor: Pallet.DANGER_500,
              duration: const Duration(seconds: 3),
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.symmetric(vertical: 150),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          );
        }

        doctorBloc.postStatusNotifier.removeListener(() {});
      });

      await doctorBloc.updateDoctorDetails(
          context, userInfo?.doctorProfile.id ?? 0, partialUpdates);

      setState(() {
        _isLoading = false;
      });

      await completer.future;
    }
  }

  void _showAddLocationModal(BuildContext context) {
    final TextEditingController postalCodeController = TextEditingController();
    final TextEditingController line1Controller = TextEditingController();
    final TextEditingController suburbController = TextEditingController();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController cityController = TextEditingController();
    String selectedProvince = "EC";

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Add Practice Location'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: postalCodeController,
                  decoration: const InputDecoration(labelText: 'Postal Code'),
                ),
                TextFormField(
                  controller: line1Controller,
                  decoration: const InputDecoration(labelText: 'Street'),
                ),
                TextFormField(
                  controller: suburbController,
                  decoration: const InputDecoration(labelText: 'Suburb'),
                ),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Practice Name'),
                ),
                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(labelText: 'Province'),
                  value: selectedProvince,
                  items: [
                    const DropdownMenuItem(
                      value: "EC",
                      child: Text("Eastern Cape"),
                    ),
                    const DropdownMenuItem(
                      value: "FS",
                      child: Text("Free State"),
                    ),
                    const DropdownMenuItem(
                      value: "GP",
                      child: Text("Gauteng"),
                    ),
                    const DropdownMenuItem(
                      value: "KZN",
                      child: Text("KwaZulu-Natal"),
                    ),
                    const DropdownMenuItem(
                      value: "LP",
                      child: Text("Limpopo"),
                    ),
                    const DropdownMenuItem(
                      value: "NC",
                      child: Text("Northern Cape"),
                    ),
                    const DropdownMenuItem(
                      value: "NW",
                      child: Text("North-West"),
                    ),
                    const DropdownMenuItem(
                      value: "WC",
                      child: Text("Western Cape"),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedProvince = value!;
                    });
                  },
                ),
                TextFormField(
                  controller: cityController,
                  decoration: const InputDecoration(labelText: 'City'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _selectedPracticeLocations.add({
                    'postal_code': postalCodeController.text,
                    'line_1': line1Controller.text,
                    'suburb': suburbController.text,
                    'name': nameController.text,
                    'country': countryController.text,
                    'province': selectedProvince,
                    'city': cityController.text,
                  });
                });
                Navigator.of(context).pop();
              },
              child: const Text('Add Location'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formKey,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 130,
              color: Pallet.PRIMARY_COLOR,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70, right: 75),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: GestureDetector(
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onTap: () {
                              Navigator.of(context).pop();
                            },
                          ),
                        ),
                        const Text(
                          'Professional Details',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  padding: const EdgeInsets.all(8.0),
                  children: [
                    const SizedBox(height: 16.0),
                    const Text(
                      'HPCSA Number',
                      style: TextStyle(
                        color: Pallet.NEUTRAL_300,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _hpcsaNoController,
                        decoration: InputDecoration(
                          hintText: 'HPCSA Number',
                          hintStyle: const TextStyle(
                            color: Pallet.NEUTRAL_100,
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                          ),
                          filled: true,
                          fillColor: Pallet.BACKGROUND_50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your HPCSA Number';
                          }
                          return null;
                        },
                      ),
                    ),
                    const Text(
                      'SAPC Number',
                      style: TextStyle(
                        color: Pallet.NEUTRAL_300,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextFormField(
                        controller: _mpNoController,
                        decoration: InputDecoration(
                          hintText: 'SAPC Number',
                          hintStyle: const TextStyle(
                            color: Pallet.NEUTRAL_100,
                            fontWeight: FontWeight.normal,
                            fontSize: 10,
                          ),
                          filled: true,
                          fillColor: Pallet.BACKGROUND_50,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (value) {
                          if (_selectedSpecialities.any((speciality) =>
                              speciality.name == 'Pharmacist')) {
                            if (value == null || value.isEmpty) {
                              return 'Please enter your SAPC Number';
                            }
                          }
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    const Text(
                      'Specialities',
                      style: TextStyle(
                        color: Pallet.NEUTRAL_300,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Consumer<SpecialityBloc>(
                        builder: (context, specialityBloc, child) {
                          if (specialityBloc.isLoading) {
                            return const Center(
                                child: CircularProgressIndicator());
                          } else if (specialityBloc.error != null) {
                            return Center(
                                child: Text('Error: ${specialityBloc.error}'));
                          } else if (specialityBloc.specialities.isEmpty) {
                            return const Text('No specialities available');
                          } else {
                            return MultiSelectDialogField<Speciality>(
                              items: specialityBloc.specialities
                                  .map((speciality) =>
                                      MultiSelectItem<Speciality>(
                                          speciality, speciality.name))
                                  .toList(),
                              title: const Text('Select Specialities'),
                              selectedItemsTextStyle:
                                  const TextStyle(color: Pallet.NEUTRAL_100),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                color: Pallet.BACKGROUND_50,
                              ),
                              buttonIcon: const Icon(
                                Icons.arrow_drop_down,
                                color: Colors.black,
                              ),
                              buttonText: const Text(
                                'Select Specialities',
                                style: TextStyle(
                                    color: Pallet.NEUTRAL_100, fontSize: 10),
                              ),
                              onConfirm: (selected) {
                                setState(() {
                                  _selectedSpecialities = selected;
                                });
                                _formKey.currentState?.validate();
                              },
                            );
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Align(
                      alignment: Alignment.center,
                      child: SizedBox(
                        width: 200,
                        height: 30,
                        child: ElevatedButton(
                          onPressed: () => _showAddLocationModal(context),
                          style: ElevatedButton.styleFrom(
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.zero,
                            ),
                          ),
                          child: const Text(
                            'Add Practice Location',
                            style: TextStyle(color: Pallet.NEUTRAL_400),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16.0),
                    Wrap(
                      spacing: 8.0,
                      children: _selectedPracticeLocations
                          .map((location) => Chip(
                                label: Text('${location['name']}'),
                                onDeleted: () {
                                  setState(() {
                                    _selectedPracticeLocations.remove(location);
                                  });
                                },
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 24.0),
                    _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : MyButtonWidgets(
                            buttonTextPrimary: 'Submit',
                            onPressedPrimary: _submitForm,
                          ).buildButtons(primaryFirst: false),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
