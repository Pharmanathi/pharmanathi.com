// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, unused_local_variable
import 'package:client_pharmanathi/screens/components/navigtion_bar.dart';
import 'package:client_pharmanathi/screens/components/appointments/appointment_data.dart';
import 'package:client_pharmanathi/screens/components/appointments/appointment_tile.dart';
import 'package:client_pharmanathi/services/appointmment_api.dart';
import 'package:flutter/material.dart';

class Appointments extends StatefulWidget {
  const Appointments({super.key});

  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  String selectedButton = 'Completed';
  Color primaryColor = Color(0xFFF7F9FC);
  int _selectedIndex = 2;
  int selectedDay = -1;
  bool isLoading = true;

  List<AppointmentData> appointmentData = [];

  @override
  void initState() {
    super.initState();
    _loadAppointmentData();
  }

  void _loadAppointmentData() async {
    try {
      //* Call fetchAppointmentData to fetch appointment data
      List<Map<String, dynamic>> fetchedAppointmentData =
          await fetchAppointmentData(context);

      //* Convert fetched data to Appointment objects
      List<AppointmentData> appointmentList = fetchedAppointmentData
          .map((map) => AppointmentData.fromJson(map))
          .toList();

      //* Sort the appointment data by date in descending order
      appointmentList.sort((a, b) => b.date.compareTo(a.date));

      setState(() {
        appointmentData = appointmentList;
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
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // heading container...............................
            Padding(
              padding: const EdgeInsets.all(22.0),
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
                child: appointmentData.isEmpty
                    ? (appointmentData.isEmpty
                        ? Center(
                            child: CircularProgressIndicator(),
                          )
                        : Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/nodata.png',
                                  width: 120,
                                  height: 120,
                                ),
                                SizedBox(height: 20),
                                Text(
                                  'No appointments available',
                                  style: TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                          ))
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: appointmentData.length,
                        itemBuilder: (context, index) {
                          final data = appointmentData[index];

                          return ProfileCard(
                            time: data.time,
                            name: data.name,
                            date: data.date,
                            appointmentTime: data.appointmentTime,
                            imageURL: data.imageURL,
                            consult_details: data.consult_details,
                            clinic_name: data.clinic_name,
                            clinic_address: data.clinic_address,
                            status: data.status,
                            title: data.title,
                            appiontmenType: data.appiontmenType,
                            otherData: appointmentData[index],
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
