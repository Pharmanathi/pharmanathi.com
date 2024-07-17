// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, use_rethrow_when_possible

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../logging.dart';
import '../../models/appointment.dart';
import '../../repositories/appointment_repository.dart';
import '../widjets/navigationbar.dart';
import '../widjets/patiant_profile_tile.dart';

class PatientList extends StatefulWidget {
  const PatientList({Key? key});

  @override
  State<PatientList> createState() => _PatientListState();
}

class _PatientListState extends State<PatientList> {
  late AppointmentRepository _appointmentRepository;
  final log = logger(PatientList);
  int _selectedIndex = 2;
  bool isLoading = true;

  List<Appointment> patientAppointments = [];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _loadPatientData() async {
    try {
      List<Appointment> fetchedAppointments =
          await _appointmentRepository.fetchAppointments(context);

      setState(() {
        patientAppointments = _removeDuplicatePatients(fetchedAppointments);
        isLoading = false;
      });
    } catch (e) {
      log.e('Error loading appointment data: $e');
    }
  }

  List<Appointment> _removeDuplicatePatients(List<Appointment> appointments) {
    final uniqueNames = <String>{};
    final uniqueAppointments = <Appointment>[];
    for (final appointment in appointments) {
      if (!uniqueNames.contains(appointment.patientName)) {
        uniqueNames.add(appointment.patientName);
        uniqueAppointments.add(appointment);
      }
    }
    return uniqueAppointments;
  }

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<AppointmentRepository>();
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
                  : patientAppointments.isEmpty
                      ? Center(
                          child: Text('No Patients available',
                              style: TextStyle(fontSize: 12)),
                        )
                      : ListView.builder(
                          itemCount: patientAppointments.length,
                          itemBuilder: (BuildContext context, int index) {
                            final appointment = patientAppointments[index];
                            return PatientProfileTile(appointment: appointment);
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
