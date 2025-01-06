// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_build_context_synchronously, use_rethrow_when_possible

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/models/appointment.dart';
import 'package:pharma_nathi/repositories/appointment_repository.dart';
import 'package:pharma_nathi/views/widgets/navigationbar.dart';
import 'package:pharma_nathi/views/widgets/patiant_profile_tile.dart';
import 'package:provider/provider.dart';

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
              padding: const EdgeInsets.fromLTRB(12, 35, 35, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patient List',
                    style: GoogleFonts.openSans(
                      fontSize: 25.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    children: [
                      Icon(
                        Icons.search,
                        color: Pallet.NEUTRAL_300,
                      ),
                      SizedBox(
                        width: 8.w,
                      ),
                      Icon(
                        Icons.filter_list,
                        color: Pallet.NEUTRAL_300,
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
                              style: GoogleFonts.openSans(fontSize: 12.sp)),
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
