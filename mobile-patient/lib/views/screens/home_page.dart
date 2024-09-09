// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:client_pharmanathi/Repository/appointment_repository.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:client_pharmanathi/screens/components/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../widgets/recent_appointments_tile.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  bool isLoading = true;
  int onlineAppointmentsCount = 0;
  int inPersonVisitAppointmentsCount = 0;
  late AppointmentRepository _appointmentRepository;
  List<Appointment> appointmentData = [];

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<AppointmentRepository>();
    _loadAppointmentData();
  }

  void _loadAppointmentData() async {
    try {
      List<Appointment> fetchedAppointments =
          await _appointmentRepository.fetchAppointments(context);
      setState(() {
        appointmentData = fetchedAppointments;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading appointment data: $e');
      // Handle error as needed
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 70,
              color: Color(0xFF6F7ED7),
            ),
           
            //recently visited
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Visited',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 12
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 20),
              height: 180,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Builder(
                      builder: (context) {
                        final completedAppointments = appointmentData
                            .where((appointment) =>
                                appointment.status == "Completed")
                            .toList();

                        return ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: completedAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = completedAppointments[index];
                            return RecentAppointmentsTile(
                              appointment: appointment,
                            );
                          },
                        );
                      },
                    ),
            )
          ],
        ),
      ),

      // CustomBottomNavigationBar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

}
