// TODO(nehemie): rename this module to "appointments"(plural)
import 'package:patient/Repository/appointment_repository.dart';
import 'package:patient/model/appointment_data.dart';
import 'package:patient/views/widgets/navigation_bar.dart';
import 'package:patient/views/widgets/HeaderWidget.dart';
import 'package:patient/views/widgets/appointment_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  String selectedButton = 'Completed';
  Color primaryColor = const Color(0xFFF7F9FC);
  int _selectedIndex = 0;
  int selectedDay = -1;
  bool isLoading = true;
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
      backgroundColor: const Color(0xFFF7F9FC),
      appBar: const PreferredSize(
          preferredSize: Size.fromHeight(120),
          child: HeaderWidget(
            text: 'Appointments',
            showBackButton: false, //* Hide the back button if not needed
          )),
      body: CustomScrollView(
        slivers: [
          isLoading
              ? const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : appointmentData.isEmpty
                  ? SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              'assets/images/nodata.png',
                              width: 120,
                              height: 120,
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'No appointments available',
                              style: TextStyle(fontSize: 12),
                            ),
                          ],
                        ),
                      ),
                    )
                  : SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final data = appointmentData[index];
                          return AppointmentListItem(appointment: data);
                        },
                        childCount: appointmentData.length,
                      ),
                    ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
