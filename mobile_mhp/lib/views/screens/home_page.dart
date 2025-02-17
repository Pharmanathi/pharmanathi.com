// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, avoid_unnecessary_containers, sized_box_for_whitespace, empty_constructor_bodies, duplicate_ignore, use_build_context_synchronously
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/helpers/http_helpers.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/models/appointment.dart';
import 'package:pharma_nathi/repositories/appointment_repository.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/views/widgets/bargraph/bargraph.dart';
import 'package:pharma_nathi/views/widgets/navigationbar.dart';
import 'package:pharma_nathi/views/widgets/upcoming_appointment_tile.dart';
import 'package:provider/provider.dart';


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

  void _calculateMonthlyStats() {
    Map<String, List<Appointment>> groupedByMonth = {};

    for (var appointment in appointmentData) {
      String month = '';
      try {
        //* Parse appointmentDate and extract the month
        DateTime parsedDate = DateFormat('dd MMM yyyy', 'en_US')
            .parse(appointment.appointmentDate);
        month = parsedDate.month.toString(); //* Extract the month
      } catch (error) {
        print('Error parsing appointmentDate: $error');
        month = 'Unknown'; //* Fallback in case of an error
      }

      // Group appointments by month
      if (!groupedByMonth.containsKey(month)) {
        groupedByMonth[month] = [];
      }
      groupedByMonth[month]!.add(appointment);
    }

    setState(() {
      monthlyStats = groupedByMonth.entries.map((entry) {
        double onlineCount = entry.value
            .where((appointment) => appointment.isOnlineAppointment == true)
            .length
            .toDouble();
        double inPersonCount = entry.value
            .where((appointment) => appointment.isOnlineAppointment == false)
            .length
            .toDouble();
        return {
          "month": entry.key, // Include the month in the stats
          "onlineConsultation": onlineCount,
          "inPersonVisit": inPersonCount,
        };
      }).toList();
    });
  }

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<AppointmentRepository>();
    _loadData();
  }

  void _loadData() async {
    await _loadAppointmentData();
    _calculateMonthlyStats();
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
    String alteredname = Apihelper.toTitleCase(
        'Dr. ${userInfo?.firstName ?? ''} ${userInfo?.lastName ?? 'loading..'}');

    return Scaffold(
      backgroundColor: Pallet.BACKGROUND_COLOR,
      body: SafeArea(
        child: Column(
          children: [
            SizedBox(height: 8.h),
            Container(
              height: 85.h,
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: const EdgeInsets.all(0.0),
                child: Row(
                  children: [
                    SizedBox(width: 20.w),
                    CircleAvatar(
                      backgroundImage: NetworkImage(userProvider.picture ?? ''),
                      radius: 30.sp,
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome Back!',
                          style: GoogleFonts.openSans(
                              fontSize: 12.sp, color: Pallet.NEUTRAL_300),
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.7,
                          child: Text(
                            alteredname,
                            style: GoogleFonts.openSans(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp,
                            ),
                            softWrap: true,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                    top: 25.0, left: 25.0, right: 25.0, bottom: 14.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Upcoming Appointments',
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold, fontSize: 12.sp),
                    ),
                    // Text(
                    //   'See All',
                    //   style: GoogleFontsCustom.openSans(
                    //       color: Color(0xFF6F7ED7),
                    //       fontWeight: FontWeight.bold,
                    //       fontSize: 12.sp),
                    // ),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(left: 10),
              height: 155.h,
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
                            style: GoogleFonts.openSans(fontSize: 12.sp),
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
                    top: 25, left: 25, right: 25, bottom: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Appointments Statistics',
                      style: GoogleFonts.openSans(
                          fontWeight: FontWeight.bold, fontSize: 12.sp),
                    ),
                    // Row(
                    //   children: [
                    //     Text(
                    //       'Last 12 Months',
                    //       style: GoogleFontsCustom.openSans(
                    //           color: Color(0xFF6F7ED7),
                    //           fontWeight: FontWeight.bold,
                    //           fontSize: 12.sp),
                    //     ),
                    //     Icon(
                    //       Icons.expand_more,
                    //       color: Color(0xFF6F7ED7),
                    //     ),
                    //   ],
                    // ),
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
                            style: GoogleFonts.openSans(
                              fontSize: 12.sp,
                              color: Colors.grey,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            appointmentData.isEmpty
                                ? '0'
                                : appointmentData.length.toString(),
                            style: GoogleFonts.openSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Online',
                            style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$onlineAppointmentsCount',
                            style: GoogleFonts.openSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'In Person',
                            style: GoogleFonts.openSans(
                                fontSize: 12.sp,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            '$inPersonVisitAppointmentsCount',
                            style: GoogleFonts.openSans(
                              fontSize: 24.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8.h),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            Flexible(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  double screenHeight = MediaQuery.of(context).size.height;
                  double containerHeight =
                      (screenHeight * 0.7).clamp(0, 211.sp);

                  return Container(
                    width: 353.25.sp,
                    height: containerHeight,
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : MyBarGraph(
                            monthlystats: monthlyStats
                                .map((data) => data["onlineConsultation"]!)
                                .toList(),
                            monthlystats2: monthlyStats
                                .map((data) => data["inPersonVisit"]!)
                                .toList(),
                          ),
                  );
                },
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(
                  left: 25,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: Icon(
                            Icons.circle,
                            color: Pallet.PRIMARY_COLOR,
                            size: 12.sp,
                          ),
                        ),
                        Text(
                          'Online Consultation',
                          style: GoogleFonts.openSans(
                            fontSize: 8.sp,
                            fontStyle: FontStyle.normal,
                            color: Color(0xFF6F7ED7),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 20, right: 8),
                          child: Icon(
                            Icons.circle,
                            color: Colors.grey,
                            size: 12.sp,
                          ),
                        ),
                        Text(
                          'In person Visit',
                          style: GoogleFonts.openSans(
                            fontSize: 8.sp,
                            fontStyle: FontStyle.normal,
                            color: Color(0xFF6F7ED7),
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
