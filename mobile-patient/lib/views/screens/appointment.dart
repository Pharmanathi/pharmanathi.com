import 'package:client_pharmanathi/Repository/appointment_repository.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:client_pharmanathi/screens/components/navigtion_bar.dart';
import 'package:client_pharmanathi/views/widgets/appointment_tile.dart';
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
  int _selectedIndex = 2;
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
    DateTime now = DateTime.now();
    int currentYear = now.year;

    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // heading container...............................
            const Padding(
              padding: EdgeInsets.all(22.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Appointments',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Scrollable ProfileCard part
            Expanded(
              child: SingleChildScrollView(
                child: isLoading
                    ? const Center(
                        child: CircularProgressIndicator(),
                      )
                    : appointmentData.isEmpty
                        ? Center(
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
                          )
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: appointmentData.length,
                            itemBuilder: (context, index) {
                              final data = appointmentData[index];

                              return ProfileCard(
                                appointment: data,
                              );
                            },
                          ),
              ),
            ),
          ],
        ),
      ),
      //navigation bar
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
