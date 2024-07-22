import 'package:flutter/material.dart';
import 'package:pharma_nathi/blocs/doctor_bloc.dart';
import 'package:pharma_nathi/blocs/speciality_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final doctorBloc = Provider.of<DoctorBloc>(context, listen: false);
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final userInfo = userProvider.user;

      List<Map<String, dynamic>> specialitiesData = _selectedSpecialities
          .map((s) => {
                'id': s.id,
              })
          .toList();

      final Map<String, dynamic> partialUpdates = {
        'hpcsa_no': _hpcsaNoController.text,
        'mp_no': _mpNoController.text,
        'specialities': specialitiesData,
        'practice_locations': _selectedPracticeLocations,
      };

      doctorBloc.updateUserDetails(context, userInfo?.id ?? 0, partialUpdates);

      doctorBloc.postStatusNotifier.addListener(() {
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
      });
    }
  }

  void _showAddLocationModal(BuildContext context) {
    final TextEditingController postalCodeController = TextEditingController();
    final TextEditingController streetController = TextEditingController();
    final TextEditingController countryController = TextEditingController();
    final TextEditingController provinceController = TextEditingController();
    final TextEditingController cityController = TextEditingController();

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
                  controller: streetController,
                  decoration: const InputDecoration(labelText: 'Street'),
                ),
                TextFormField(
                  controller: countryController,
                  decoration: const InputDecoration(labelText: 'Country'),
                ),
                TextFormField(
                  controller: provinceController,
                  decoration: const InputDecoration(labelText: 'Province'),
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
                    'street': streetController.text,
                    'country': countryController.text,
                    'province': provinceController.text,
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
              Consumer<SpecialityBloc>(
                builder: (context, specialityBloc, child) {
                  if (specialityBloc.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (specialityBloc.error != null) {
                    return Center(
                        child: Text('Error: ${specialityBloc.error}'));
                  } else if (specialityBloc.specialities.isEmpty) {
                    return const Text('No specialities available');
                  } else {
                    return MultiSelectDialogField<Speciality>(
                      items: specialityBloc.specialities
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
              ElevatedButton(
                onPressed: () => _showAddLocationModal(context),
                child: const Text('Add Practice Location'),
              ),
              const SizedBox(height: 16.0),
              Wrap(
                spacing: 8.0,
                children: _selectedPracticeLocations
                    .map((location) => Chip(
                          label: Text(
                              '${location['street']}, ${location['city']}'),
                          onDeleted: () {
                            setState(() {
                              _selectedPracticeLocations.remove(location);
                            });
                          },
                        ))
                    .toList(),
              ),
              const SizedBox(height: 24.0),
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
