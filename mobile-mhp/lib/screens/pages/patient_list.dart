// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, use_rethrow_when_possible

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../services/appointment_api.dart';
import '../components/navigationbar.dart';
import '../components/patients/patiant_profile_tile.dart';
import '../components/patients/patient_data.dart';

class PatientList extends StatefulWidget {
  const PatientList({Key? key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  int _selectedIndex = 2;
  bool isLoading = true;

  List<PatientData> patientData = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  //@TODO: need to use the correct endpiont when available
  Future<List<PatientData>> _loadPatientData() async {
    try {
      List<Map<String, dynamic>> fetchedAppointmentData =
          await fetchAppointmentData(context);
      List<PatientData> patientList = fetchedAppointmentData
          .map((map) => PatientData.fromJson(map))
          .toList();

      setState(() {
        patientData = patientList;
        isLoading = false;
      });

      return patientList;
    } catch (e) {
      //* Display a user-friendly error message
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Error'),
            content:
                Text('Failed to load patient data. Please try again later.'),
            actions: <Widget>[
              TextButton(
                child: Text('OK'),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
      throw e;
    }
  }

  // Function to filter and return unique patients
  //This is a temp solution
  List<PatientData> _removeDuplicatePatients(List<PatientData> patients) {
    final uniqueNames = <String>{};
    final uniquePatients = <PatientData>[];
    for (final patient in patients) {
      if (!uniqueNames.contains(patient.name)) {
        uniqueNames.add(patient.name);
        uniquePatients.add(patient);
      }
    }
    return uniquePatients;
  }

  @override
  void initState() {
    super.initState();
    _loadPatientData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(35),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patient List',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Color(0xFF6F7ED7),
                      ),
                      SizedBox(
                        width: 15,
                      ),
                      Icon(
                        Icons.filter_list,
                        color: Color(0xFF6F7ED7),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : patientData.isEmpty
                      ? Center(
                          child: Text('No Patient available',
                              style: TextStyle(fontSize: 12)))
                      : ListView.builder(
                          itemCount: _removeDuplicatePatients(patientData).length,
                          itemBuilder: (BuildContext context, int index) {
                            final uniquePatient =
                                _removeDuplicatePatients(patientData)[index];
                            return CustomCard(patient: uniquePatient);
                          },
                        ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
