// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables

import 'package:client_pharmanathi/Repository/appointment_repository.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:client_pharmanathi/screens/components/navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../views/widgets/recent_appointments_tile.dart';

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
              height: 200,
              color: Color(0xFF6F7ED7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70, left: 25),
                    child: Text(
                      'Pharmanathi',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.0),
                  Padding(
                    padding: const EdgeInsets.only(
                        top: 0, bottom: 25, left: 25, right: 25),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search by category',
                        suffixIcon: Icon(Icons.search),
                        filled: true,
                        fillColor: Color.fromARGB(255, 179, 186, 229),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: EdgeInsets.symmetric(
                            vertical: 10.0, horizontal: 10.0),
                      ),
                      onChanged: (value) {
                        // Handle search functionality here
                      },
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            //tile for emergency
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.white,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(
                                top: 12, right: 12, left: 12, bottom: 5),
                            child: Container(
                              color: Color.fromARGB(255, 255, 235, 231),
                              child: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Icon(
                                  Icons.person_4,
                                  size: 30.0,
                                  color: Colors.red.shade200,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: 10,
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Specialists',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(
                                height: 5,
                              ),
                              // Text(
                              //   'Short Description',
                              //   style: TextStyle(
                              //     color: Colors.grey,
                              //     fontWeight: FontWeight.normal,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 10.0,
                        color: Colors.grey,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // first row of tiles on the home page
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.only(right: 10, left: 10, top: 5),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    //tile for Doctors
                    Container(
                        child: buildSectionTile('Doctors', Icons.person_4)),
                    SizedBox(
                      width: 10,
                    ),
                    //tile for clinics
                    Container(
                        child: buildSectionTile('Clinics', Icons.apartment)),
                  ],
                ),
              ),
            ),
            //recently visited
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Recently Visited',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  // Text(
                  //   'See All',
                  //   style: TextStyle(
                  //     color: Color(0xFF6F7ED7),
                  //   ),
                  // ),
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

  Widget buildSectionTile(String title, IconData icon) {
    return Container(
      width: 180,
      color: Colors.white,
      child: Padding(
        padding:
            const EdgeInsets.only(top: 12, bottom: 12, left: 12, right: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Container(
                    color: Color.fromARGB(255, 255, 235, 231),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        icon,
                        size: 30.0,
                        color: Colors.blue.shade200,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 15.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: 5,
                ),
                // Text(
                //   'Short Description',
                //   style: TextStyle(
                //     color: Colors.grey,
                //     fontWeight: FontWeight.normal,
                //   ),
                // ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 10.0,
              color: Colors.grey,
            ),
          ],
        ),
      ),
    );
  }
}
