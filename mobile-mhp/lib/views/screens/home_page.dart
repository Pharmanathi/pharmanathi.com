// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, empty_constructor_bodies, duplicate_ignore, use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/models/user.dart';
import 'package:provider/provider.dart';
import '../../logging.dart';
import '../../models/appointment.dart';
import '../../repositories/appointment_repository.dart';
import '../../repositories/user_repository.dart';
import '../widgets/upcoming_appointment_tile.dart';
import '../../screens/components/UserProvider.dart';
import '../../screens/components/bargraph/bargraph.dart';
import '../widgets/navigationbar.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late AppointmentRepository _appointmentRepository;
  final log = logger(HomePage);
  int _selectedIndex = 0;
  bool isLoading = true;
  String doctorName = 'Dr. Thabo Dube';
  int onlineAppointmentsCount = 0;
  int inPersonVisitAppointmentsCount = 0;


  List<Map<String, dynamic>> monthlyStats = [];
  List<Appointment> appointmentData = [];


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
    _appointmentRepository = context.read<AppointmentRepository>();
    _loadData();
  }

  void _loadData() async {
    await _loadAppointmentData();
    await loadMonthlyStatsData();
  }

  Future<void> _loadAppointmentData() async {
    try {
      List<Appointment> fetchedAppointments =
          await _appointmentRepository.fetchAppointments(context);
      setState(() {
        appointmentData = fetchedAppointments;
        onlineAppointmentsCount = appointmentData
            .where((appointment) => appointment.isOnlineAppointment == true)
            .length;
        inPersonVisitAppointmentsCount = appointmentData
            .where((appointment) => appointment.isOnlineAppointment == false)
            .length;
        isLoading = false;
      });
    } catch (e) {
      log.e('Error loading appointment data: $e');
    }
  }

  Future<void> loadDataFromJsonCompute(dynamic _) async {
    await _loadAppointmentData();
  }

  Future<void> loadDataFromJsonInBackground() async {
    await compute(loadDataFromJsonCompute, null);
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final userInfo = userProvider.user;

    return Scaffold(
      backgroundColor: Pallet.BACKGROUND_COLOR,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 0),
            Container(
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: NetworkImage(userProvider.picture ?? ''),
                      radius: 30,
                    ),
                    SizedBox(width: 10),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: TextStyle(fontSize: 14),
                        ),
                        Text(
                          'Dr.${userInfo?.firstName ?? '..'} ${userInfo?.lastName ?? 'loading..'}',
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
            SizedBox(height: 10),
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
            Container(
              padding: EdgeInsets.only(left: 20),
              height: 180,
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : appointmentData
                          .where(
                              (appointment) => appointment.status == "Upcoming")
                          .isEmpty
                      ? Center(
                          child: Text(
                            'No upcoming appointments available',
                            style: TextStyle(fontSize: 12),
                          ),
                        )
                      : ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: appointmentData
                              .where((appointment) =>
                                  appointment.status == "Upcoming")
                              .length,
                          itemBuilder: (context, index) {
                            final filteredAppointments = appointmentData
                                .where((appointment) =>
                                    appointment.status == "Upcoming")
                                .toList();
                            final appointment = filteredAppointments[index];

                            return UpcomingAppointmentTile(
                              appointment: appointment,
                            );
                          },
                        ),
            ),
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
                          'Last 12 Months',
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
            Expanded(
              child: Container(
                width: 430,
                height: 250,
                child: isLoading
                    ? Center(child: CircularProgressIndicator())
                    : MyBarGraph(
                        monthlystats: monthlyStats
                            .map((data) =>
                                (data["onlineConsultation"] as num).toDouble())
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
                padding: const EdgeInsets.only(left: 25, right: 25, bottom: 10),
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
