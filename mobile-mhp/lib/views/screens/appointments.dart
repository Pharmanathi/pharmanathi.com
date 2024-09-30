// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, unrelated_type_equality_checks
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
  String selectedButton = 'InPerson';
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

        return matchesDay && matchesMonthYear;
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
                padding: const EdgeInsets.only(left: 10,top: 20,bottom: 15),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Appointments',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              // Buttons container
              // Container(
              //   height: 50,
              //   width: 400,
              //   decoration: BoxDecoration(
              //     borderRadius: BorderRadius.circular(12),
              //     color: Colors.white,
              //   ),
              //   child: Row(
              //     mainAxisAlignment: MainAxisAlignment.spaceAround,
              //     children: [
              //       ElevatedButton(
              //         onPressed: () {
              //           _onButtonPressed('InPerson');
              //           setState(() {
              //             primaryColor = Color(0xFFF7F9FC);
              //           });
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.transparent,
              //           minimumSize: Size(175, 40),
              //           elevation: 0,
              //         ),
              //         child: Text(
              //           'In Person Visit',
              //           style: TextStyle(
              //             color: selectedButton == 'InPerson'
              //                 ? Color(0xFF6F7ED7)
              //                 : Colors.grey,
              //           ),
              //         ),
              //       ),
              //       SizedBox(width: 5),
              //       ElevatedButton(
              //         onPressed: () {
              //           _onButtonPressed('Online');
              //           setState(() {
              //             primaryColor = Colors.white;
              //           });
              //         },
              //         style: ElevatedButton.styleFrom(
              //           backgroundColor: Colors.transparent,
              //           minimumSize: Size(175, 40),
              //           elevation: 0,
              //         ),
              //         child: Text(
              //           'Online Consultation',
              //           style: TextStyle(
              //             color: selectedButton == 'Online'
              //                 ? Color(0xFF6F7ED7)
              //                 : Colors.grey,
              //           ),
              //         ),
              //       ),
              //     ],
              //   ),
              // ),
              // SizedBox(height: 20),
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
                        size: 12.0,
                        weight: 700,
                        color: Pallet.Black,
                      ),
                    ),
                    SizedBox(width: 25),
                    Text(
                      '$selectedMonth $currentYear',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 25),
                    GestureDetector(
                      onTap: _showNextMonth,
                      child: Icon(
                        Icons.arrow_forward_ios,
                        size: 12.0,
                        weight: 700,
                        color: Pallet.Black,
                      ),
                    ),
                  ],
                ),
              ),

              // Weekdays container
              ClickableDay(
                selectedMonth: selectedMonth,
                appointmentsPerDay: appointmentsPerDay,
                onDaySelected: (day) {
                  setState(() {
                    selectedDay = day;
                    _filterAppointments();
                  });
                },
              ),

              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 25, bottom: 10),
                    child: Text(
                      '${appointmentsPerDay.length} activities',
                      style: TextStyle(
                        fontSize: 12,
                        decoration: TextDecoration.underline,
                        color: Pallet.PRIMARY_COLOR,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      'upcoming on',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Text(
                      '$selectedDay $selectedMonth $currentYear',
                      style: TextStyle(
                        fontSize: 12,
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
                  color: Pallet.PRAMARY_75,
                  child: SingleChildScrollView(
                    child: isLoading
                        ? Center(child: CircularProgressIndicator())
                        : filteredAppointments.isEmpty
                            ? Center(
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
                              )
                            : ListView.builder(
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                itemCount: filteredAppointments.length,
                                itemBuilder: (context, index) {
                                  final data = filteredAppointments[index];
                                  return AppointmentTile(
                                    appointment:
                                        data, // Pass appointment object here
                                  );
                                },
                              ),
                  ),
                ),
              ),
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
