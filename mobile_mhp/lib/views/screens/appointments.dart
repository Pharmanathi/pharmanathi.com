// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, unrelated_type_equality_checks
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:provider/provider.dart';
import 'package:pharma_nathi/models/appointment.dart';
import 'package:pharma_nathi/repositories/appointment_repository.dart';
import '../widgets/appointment_tile.dart';
import '../widgets/navigationbar.dart';
import '../widgets/weekdays.dart';

class Appointments extends StatefulWidget {
  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  late AppointmentRepository _appointmentRepository;
  String selectedButton = 'All';
  Color primaryColor = Color(0xFFF7F9FC);
  int _selectedIndex = 1;
  int selectedDay = DateTime.now().day;
  bool isLoading = true;
  String currentMonthYear = '';
  int currentYear = DateTime.now().year;
  List<String> months = [
    'January',
    'February',
    'March',
    'April',
    'May',
    'June',
    'July',
    'August',
    'September',
    'October',
    'November',
    'December'
  ];
  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  List<Appointment> appointmentData = [];
  List<Appointment> filteredAppointments = [];
  Map<int, int> appointmentsPerDay = {};

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<AppointmentRepository>();
    _loadAppointmentData();
    DateTime now = DateTime.now();
    selectedMonth = _getMonthName(now.month);
    _filterAppointments();
  }

  void _onButtonPressed(String buttonType) {
    setState(() {
      selectedButton = buttonType;
      _filterAppointments();
    });
  }

  void onDaySelected(int day) {
    setState(() {
      selectedDay = day;
      _filterAppointments();
    });
  }

  String _getMonthName(int month) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December'
    ];
    return monthNames[month - 1];
  }

  void _showPreviousMonth() {
    setState(() {
      //* Find the index of the selected month
      int monthIndex = months.indexOf(selectedMonth);
      //* Decrease the index to go to the previous month
      monthIndex = (monthIndex - 1) < 0 ? 11 : monthIndex - 1;
      selectedMonth = months[monthIndex];

      //* Update the year if necessary
      if (monthIndex == 11) {
        currentYear--;
      }

      selectedDay = -1; //* Reset selected day when month changes
      _filterAppointments();
    });
  }

  void _showNextMonth() {
    setState(() {
      //* Find the index of the selected month
      int monthIndex = months.indexOf(selectedMonth);
      //* Increase the index to go to the next month
      monthIndex = (monthIndex + 1) % 12;
      selectedMonth = months[monthIndex];

      //* Update the year if necessary
      if (monthIndex == 0) {
        currentYear++;
      }

      selectedDay = -1; //* Reset selected day when month changes
      _filterAppointments();
    });
  }

  void _loadAppointmentData() async {
    try {
      List<Appointment> fetchedAppointments =
          await _appointmentRepository.fetchAppointments(context);
      setState(() {
        appointmentData = fetchedAppointments;
        isLoading = false;
        _filterAppointments();
      });
    } catch (e) {
      print('Error loading appointment data: $e');
      // Handle error as needed
    }
  }

  void _filterAppointments() {
    final dateFormat = DateFormat('dd MMM yyyy');

    //* Keep calculating `appointmentsPerDay` for the entire month
    appointmentsPerDay = {};
    for (var appointment in appointmentData) {
      DateTime appointmentDate = dateFormat.parse(appointment.appointmentDate);
      int day = appointmentDate.day;
      String appointmentMonth = DateFormat('MMMM').format(appointmentDate);
      int appointmentYear = appointmentDate.year;

      if (appointmentMonth == selectedMonth && appointmentYear == currentYear) {
        appointmentsPerDay[day] = (appointmentsPerDay[day] ?? 0) + 1;
      }
    }

    //* Filter appointments based on selected day (if any)
    setState(() {
      filteredAppointments = appointmentData.where((appointment) {
        DateTime appointmentDate =
            dateFormat.parse(appointment.appointmentDate);
        int appointmentDay = appointmentDate.day;
        String appointmentMonth = DateFormat('MMMM').format(appointmentDate);
        int appointmentYear = appointmentDate.year;

        bool matchesDay = selectedDay == -1 || appointmentDay == selectedDay;
        bool matchesMonthYear =
            appointmentMonth == selectedMonth && appointmentYear == currentYear;

        //* Determine if the appointment matches the filter (online or in-person)
        bool matchesAppointmentType = true;
        if (selectedButton == 'Online') {
          matchesAppointmentType = appointment.isOnlineAppointment == true;
        } else if (selectedButton == 'InPerson') {
          matchesAppointmentType = appointment.isOnlineAppointment == false;
        } else if (selectedButton == 'All') {
          matchesAppointmentType = true; // Return all for 'allt'
        }

        return matchesDay && matchesMonthYear && matchesAppointmentType;
      }).toList();
    });
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
      backgroundColor: Pallet.PURE_WHITE,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.only(left: 10, right: 10),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 10, top: 20, bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Appointments',
                      style: GoogleFonts.openSans(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Months container
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center, // Center the entire Row
                  children: [
                    GestureDetector(
                      onTap: _showPreviousMonth,
                      child: Icon(
                        Icons.arrow_back_ios,
                        size: 12.0.sp,
                        weight: 700.sp,
                        color: Pallet.Black,
                      ),
                    ),
                    SizedBox(width: 25.w),
                    Text(
                      '$selectedMonth $currentYear',
                      style: GoogleFonts.openSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 25.w),
                    GestureDetector(
                      onTap: _showNextMonth,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12.0.sp,
                        weight: 700.sp,
                        color: Pallet.Black,
                      ),
                    ),
                  ],
                ),
              ),

              // Weekdays container
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12.0),
                child: ClickableDay(
                  selectedMonth: selectedMonth,
                  appointmentsPerDay: appointmentsPerDay,
                  onDaySelected: (day) {
                    setState(() {
                      selectedDay = day;
                      _filterAppointments();
                    });
                  },
                ),
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25, bottom: 10),
                    child: Text(
                      '${appointmentsPerDay.length} activities',
                      style: GoogleFonts.openSans(
                        fontSize: 12.sp,
                        decoration: TextDecoration.underline,
                        color: Pallet.PRIMARY_COLOR,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'upcoming on',
                      style: GoogleFonts.openSans(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5.w,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '$selectedDay $selectedMonth $currentYear',
                      style: GoogleFonts.openSans(
                        fontSize: 12.sp,
                        color: Pallet.PRIMARY_COLOR,
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              // Scrollable ProfileCard part
              Expanded(
                child: Container(
                  width: 354.w,
                  color: Pallet.PRAMARY_75,
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        Row(
                          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            SizedBox(
                              width: 45.w,
                              child: Column(
                                children: [
                                  Text(
                                    'mon', //TODO [Thabang] : set this to get  days auto
                                    style: GoogleFonts.openSans(
                                      fontSize: 10.sp,
                                      color: Pallet.Black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    '$selectedDay',
                                    style: GoogleFonts.openSans(
                                      fontSize: 20.sp,
                                      color: Pallet.Black,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 0.2.w,
                              height: 50.h,
                              color: Pallet.SECONDARY_500,
                              margin: const EdgeInsets.only(right: 12),
                            ),
                            Expanded(
                              flex: 5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      _onButtonPressed('All');
                                      setState(() {
                                        primaryColor = const Color(0xFFF7F9FC);
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          selectedButton == 'All' ||
                                                  selectedButton.isEmpty
                                              ? Colors.black
                                              : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                      minimumSize: const Size(50, 22),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      'All',
                                      style: GoogleFonts.openSans(
                                        fontSize: 12.sp,
                                        color: selectedButton == 'All' ||
                                                selectedButton.isEmpty
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  // 'Online' button
                                  TextButton(
                                    onPressed: () {
                                      _onButtonPressed('Online');
                                      setState(() {
                                        primaryColor = Colors.white;
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          selectedButton == 'Online'
                                              ? Colors.black
                                              : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                      minimumSize: const Size(50, 22),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      'Online',
                                      style: GoogleFonts.openSans(
                                        fontSize: 12.sp,
                                        color: selectedButton == 'Online'
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                  SizedBox(width: 5.w),
                                  // 'In Person Visit' button
                                  TextButton(
                                    onPressed: () {
                                      _onButtonPressed('InPerson');
                                      setState(() {
                                        primaryColor = const Color(0xFFF7F9FC);
                                      });
                                    },
                                    style: TextButton.styleFrom(
                                      backgroundColor:
                                          selectedButton == 'InPerson'
                                              ? Colors.black
                                              : Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12, vertical: 0),
                                      minimumSize: const Size(50, 22),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                    ),
                                    child: Text(
                                      'In Person',
                                      style: GoogleFonts.openSans(
                                        fontSize: 12.sp,
                                        color: selectedButton == 'InPerson'
                                            ? Colors.white
                                            : Colors.black,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            )
                          ],
                        ),
                        Container(
                          width: double.infinity,
                          height: 0.2.h,
                          color: Pallet.SECONDARY_500,
                        ),

                        //* Main Content (Loading or Appointments List)
                        isLoading
                            ? Center(child: CircularProgressIndicator())
                            : filteredAppointments.isEmpty
                                ? Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Image.asset(
                                          'assets/images/nodata.png',
                                          width: 120.w,
                                          height: MediaQuery.of(context).size.height,
                                        ),
                                        SizedBox(height: 20.h),
                                        Text(
                                          'No appointments available',
                                          style: GoogleFonts.openSans(
                                              fontSize: 12.sp),
                                        ),
                                      ],
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemCount: filteredAppointments.length,
                                    itemBuilder: (context, index) {
                                      final data = filteredAppointments[index];
                                      return AppointmentTile(
                                        appointment: data,
                                      );
                                    },
                                  ),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
