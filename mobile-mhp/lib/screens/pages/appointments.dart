// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_key_in_widget_constructors, library_private_types_in_public_api, unrelated_type_equality_checks
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:pharma_nathi/models/appointment.dart';
import 'package:pharma_nathi/repositories/appointment_repository.dart';
import '../../views/widjets/appointment_tile.dart';
import '../components/navigationbar.dart';
import '../components/weekdays.dart';

class Appointments extends StatefulWidget {
  @override
  _AppointmentsState createState() => _AppointmentsState();
}

class _AppointmentsState extends State<Appointments> {
  late AppointmentRepository _appointmentRepository;
  String selectedButton = 'InPerson';
  Color primaryColor = Color(0xFFF7F9FC);
  int _selectedIndex = 1;
  int selectedDay = -1;
  bool isLoading = true;
  String currentMonthYear = '';
  List<String> months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];

  String selectedMonth = DateFormat('MMMM').format(DateTime.now());
  List<Appointment> appointmentData = [];
  List<Appointment> filteredAppointments = [];

  @override
  void initState() {
    super.initState();
    _appointmentRepository = context.read<AppointmentRepository>();
    _loadAppointmentData();
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

  void _showMonthPickerDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: Text('Choose a Month'),
          children: months.map((month) {
            return SimpleDialogOption(
              onPressed: () {
                setState(() {
                  selectedMonth = month;
                  selectedDay = -1; // Reset selected day when month changes
                  _filterAppointments();
                });
                Navigator.of(context).pop();
              },
              child: Text(month),
            );
          }).toList(),
        );
      },
    );
  }

  void _loadAppointmentData() async {
    try {
      List<Appointment> fetchedAppointments = await _appointmentRepository.fetchAppointments(context);
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
    setState(() {
      filteredAppointments = appointmentData.where((appointment) {
        bool matchesButton =
            (selectedButton == 'InPerson') || (selectedButton == 'Online');
        bool matchesDay = selectedDay == -1 ||
            dateFormat.parse(appointment.appointmentDate).day == selectedDay;
        return matchesButton && matchesDay;
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
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: Column(
          children: [
            // Heading container
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
            // Buttons container
            Container(
              height: 50,
              width: 400,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                color: Colors.white,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      _onButtonPressed('InPerson');
                      setState(() {
                        primaryColor = Color(0xFFF7F9FC);
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      minimumSize: Size(175, 40),
                      elevation: 0,
                    ),
                    child: Text(
                      'In Person Visit',
                      style: TextStyle(
                        color: selectedButton == 'InPerson'
                            ? Color(0xFF6F7ED7)
                            : Colors.grey,
                      ),
                    ),
                  ),
                  SizedBox(width: 5),
                  ElevatedButton(
                    onPressed: () {
                      _onButtonPressed('Online');
                      setState(() {
                        primaryColor = Colors.white;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      minimumSize: Size(175, 40),
                      elevation: 0,
                    ),
                    child: Text(
                      'Online Consultation',
                      style: TextStyle(
                        color: selectedButton == 'Online'
                            ? Color(0xFF6F7ED7)
                            : Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 20),
            // Months container
            Padding(
              padding: const EdgeInsets.only(
                top: 10,
                left: 25,
                right: 25,
                bottom: 25,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$selectedMonth $currentYear',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  GestureDetector(
                    onTap: _showMonthPickerDialog,
                    child: Row(
                      children: [
                        Icon(
                          Icons.filter_3_outlined,
                          color: Color(0xFF6F7ED7),
                        ),
                        SizedBox(width: 15),
                        Text(
                          'Filter',
                          style: TextStyle(
                            color: Color(0xFF6F7ED7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Weekdays container
            ClickableDay(
              selectedMonth: selectedMonth,
              onDaySelected: onDaySelected,
            ),
            // Scrollable ProfileCard part
            Expanded(
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
                                appointment: data, // Pass appointment object here
                              );
                            },
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
