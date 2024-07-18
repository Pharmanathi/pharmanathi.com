import 'package:flutter/material.dart';
import 'package:pharma_nathi/repositories/user_repository.dart';
import 'package:pharma_nathi/services/api_provider.dart';
import '../../models/user.dart';
import '../../blocs/user_bloc.dart';

class OnboardDetailsScreen extends StatefulWidget {
  @override
  _OnboardDetailsScreenState createState() => _OnboardDetailsScreenState();
}

class _OnboardDetailsScreenState extends State<OnboardDetailsScreen> {
  late final UserBloc userBloc;
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _hpcsaNoController = TextEditingController();
  final TextEditingController _mpNoController = TextEditingController();
  List<Speciality> _selectedSpecialities = [];
  List<int> _selectedPracticeLocations = [];

  @override
  void initState() {
    super.initState();
    userBloc = UserBloc(UserRepository(ApiProvider()));
  }

  @override
  void dispose() {
    _hpcsaNoController.dispose();
    _mpNoController.dispose();
    userBloc.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      DoctorProfile doctorProfile = DoctorProfile(
        id: 0,
        specialities: _selectedSpecialities,
        hpcsaNo: _hpcsaNoController.text,
        mpNo: _mpNoController.text,
        practiceLocations: _selectedPracticeLocations,
      );

      User user = User(
        id: 0,
        isDoctor: true,
        doctorProfile: doctorProfile,
        isSuperuser: false,
        isStaff: false,
        isActive: true,
        firstName: '', // Add appropriate data
        lastName: '', // Add appropriate data
        email: '', // Add appropriate data
        userPermissions: [], // Add appropriate data
      );

      userBloc.postUserDetails(context, user);

      userBloc.postStatusNotifier.addListener(() {
        if (userBloc.postStatusNotifier.value) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User details submitted successfully')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to submit user details')),
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Replace with your actual availableSpecialities and availablePracticeLocations
    List<Speciality> availableSpecialities = [
      Speciality(id: 1, name: 'Cardiology'),
      Speciality(id: 2, name: 'Dermatology'),
      // Add more specialities here
    ];

    List<int> availablePracticeLocations = [1, 2, 3, 4, 5];

    return Scaffold(
      appBar: AppBar(
        title: Text('Onboarding Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _hpcsaNoController,
                decoration: InputDecoration(labelText: 'HPCSA Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your HPCSA Number';
                  }
                  return null;
                },
              ),
              TextFormField(
                controller: _mpNoController,
                decoration: InputDecoration(labelText: 'MP Number'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your MP Number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16.0),
              Text('Specialities'),
              Wrap(
                spacing: 8.0,
                children: availableSpecialities.map((speciality) {
                  return ChoiceChip(
                    label: Text(speciality.name),
                    selected: _selectedSpecialities.contains(speciality),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _selectedSpecialities.add(speciality);
                        } else {
                          _selectedSpecialities.remove(speciality);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              SizedBox(height: 16.0),
              Text('Practice Locations'),
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
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: _submitForm,
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
