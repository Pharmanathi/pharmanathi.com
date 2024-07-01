// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, empty_constructor_bodies, duplicate_ignore, use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/screens/components/bargraph/bargraph.dart';
import 'package:pharma_nathi/services/user_api.dart';
import 'package:provider/provider.dart';
import '../../services/appointment_api.dart';
import '../components/appointments/upcoming_appointment_tile.dart';
import '../components/navigationbar.dart';

class HomePage extends StatefulWidget {
  HomePage({super.key}) {}

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final log = logger(HomePage);
  int _selectedIndex = 0;
  bool isLoading = true;
  String doctorName = 'Dr. Thabo Dube';
  int onlineAppointmentsCount = 0;
  int inPersonVisitAppointmentsCount = 0;

  List<Map<String, dynamic>> monthlyStats = [];
  List<AppiontmentTile> appointmentData = [];

  Future<void> loadMonthlyStatsData() async {
    try {
      setState(() {
        isLoading = true;
      });

      if (monthlyStats.isEmpty) {
        final jsonString = await rootBundle.loadString('assets/sample.json');
        final jsonMap = json.decode(jsonString);
        final monthlyStatsData = jsonMap['monthlyStats'];

        if (monthlyStatsData is List) {
          monthlyStats = List<Map<String, dynamic>>.from(monthlyStatsData);
        } else {
          log.d('monthlyStatsData is not a List');
        }
      }
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      log.e('Error loading or parsing JSON: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    await loadAppointmentData();
    await loadMonthlyStatsData();
    fetchUserData(context);
  }

  Future<void> loadAppointmentData() async {
    try {
      //* Call fetchAppointmentData to fetch appointment data
      List<Map<String, dynamic>> fetchedAppointmentData =
          await fetchAppointmentData(context);

      //* Convert fetched data to Appointment objects
      List<AppiontmentTile> appointmentList = fetchedAppointmentData
          .map((map) => AppiontmentTile.fromJson(map))
          .toList();

      //* Iterate over the fetched appointment data
      for (final appointment in fetchedAppointmentData) {
        final bool isOnlineAppointment =
            appointment['appointment_type']['is_online'];

        //* Check the type of appointment and increment the corresponding count
        if (isOnlineAppointment == false) {
          inPersonVisitAppointmentsCount++;
        } else {
          onlineAppointmentsCount++;
        }
      }

      log.i('Appointment data fetched successfully.');
      log.i('Number of appointments: ${appointmentList.length}');

      setState(() {
        appointmentData = appointmentList;
        isLoading = false;
      });
    } catch (e) {
      log.i('Error loading appointment data: $e');
      //! Handle error as needed, e.g., display error message to the user
      setState(() {
        isLoading = false;
      });
    }
  }

  //* function to match the ComputeCallback signature
  Future<void> loadDataFromJsonCompute(dynamic _) async {
    await loadAppointmentData();
  }

//* This function runs in a background isolate to prevent UI blocking
  Future<void> loadDataFromJsonInBackground() async {
    await compute(loadDataFromJsonCompute, null);
  }

  // void _onItemTapped(int index, BuildContext context) {
  //   if (index == 0) {
  //     Navigator.of(context).push(
  //       MaterialPageRoute(
  //         builder: (context) => HomePage(),
  //       ),
  //     );
  //   } else {
  //     // Handle taps for other icons if needed
  //   }
  //   _selectedIndex = index;
  // }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: Expanded(
          child: Column(
            // ignore: prefer_const_literals_to_create_immutables
            children: [
              SizedBox(
                height: 0,
              ),
              //*profile section
              Container(
                color: Color(0xFFFFFFFF),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        backgroundImage:
                            NetworkImage(userProvider.picture ?? ''),
                        radius: 30,
                      ),
                      SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome Back!',
                            style: TextStyle(
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            'Dr. ${userProvider.name}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              //*upcoming appointment(headings)
              SizedBox(
                height: 10,
              ),

              Container(
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Upcoming Appointments',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'See All',
                        style: TextStyle(
                          color: Color(0xFF6F7ED7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //*appointment tiles

              Container(
                padding: EdgeInsets.only(left: 20),
                height: 180,
                child: isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : appointmentData
                            .where((appointment) =>
                                appointment.status == "Upcoming")
                            .isEmpty
                        ? Center(
                            child: Text(
                              'No upcoming appointments available',
                              style: TextStyle(fontSize: 12),
                            ),
                          )
                        : ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: appointmentData.length,
                            itemBuilder: (context, index) {
                              final appointment = appointmentData[index];

                              //* Check if the appointment status is "Upcoming"
                              if (appointment.status == "Upcoming") {
                                return AppiontmentTile(
                                  appointmentType: appointment.appointmentType,
                                  name: appointment.name,
                                  status: appointment.status,
                                  patientdetails: appointment.patientdetails,
                                  clinic_name: appointment.clinic_name,
                                  clinic_address: appointment.clinic_address,
                                  appiontment_date:
                                      appointment.appiontment_date,
                                  time: appointment.time,
                                  consult_details: appointment.consult_details,
                                );
                              } else {
                                //* Return an empty container if the appointment status is not "Upcoming"
                                return Container();
                              }
                            },
                          ),
              ),

              //* appointment  statistics
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 10, left: 25, right: 25, bottom: 25),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Appointments Statistics',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Row(
                        children: [
                          Text(
                            'Last 12 MMonths',
                            style: TextStyle(
                              color: Color(0xFF6F7ED7),
                            ),
                          ),
                          Icon(
                            Icons.expand_more,
                            color: Color(0xFF6F7ED7),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              //* appointment  statistics
              Container(
                child: Padding(
                  padding: const EdgeInsets.only(
                      top: 2, left: 25, right: 25, bottom: 25),
                  child: Container(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              appointmentData.isEmpty
                                  ? '0'
                                  : appointmentData.length.toString(),
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'Online',
                              style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$onlineAppointmentsCount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Text(
                              'In Person',
                              style: TextStyle(
                                  fontSize: 15,
                                  color: Colors.grey,
                                  fontWeight: FontWeight.w800),
                            ),
                            SizedBox(height: 8),
                            Text(
                              '$inPersonVisitAppointmentsCount',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              // charts/////////////////////////////
              Expanded(
                child: Container(
                  width: 430,
                  height: 250,
                  child: isLoading
                      ? Center(
                          child: CircularProgressIndicator(),
                        )
                      : MyBarGraph(
                          monthlystats: monthlyStats
                              .map((data) => (data["onlineConsultation"] as num)
                                  .toDouble())
                              .toList(),
                          monthlystats2: monthlyStats
                              .map((data) =>
                                  (data["inPersonVisit"] as num).toDouble())
                              .toList(),
                        ),
                ),
              ),

              Container(
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 25, right: 25, bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      Row(
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: Icon(
                              Icons.circle,
                              color: Colors.blue.shade500,
                              size: 12,
                            ),
                          ),
                          Text(
                            'Online Consultation',
                            style: TextStyle(
                              color: Color(0xFF6F7ED7),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(left: 20, right: 8),
                            child: Icon(
                              Icons.circle,
                              color: Colors.grey,
                              size: 12,
                            ),
                          ),
                          Text(
                            'In person Visit',
                            style: TextStyle(
                              color: Colors.blue.shade500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
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
