// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/screens/pages/working_hours.dart';
import 'package:pharma_nathi/services/manage_appointment_api.dart';
import 'package:pharma_nathi/views/widgets/buttons.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';


class ManageAppointment extends StatefulWidget {
  @override
  _ManageAppointmentState createState() => _ManageAppointmentState();
}

class _ManageAppointmentState extends State<ManageAppointment> {
  TextEditingController consultationFeeController = TextEditingController();
  TextEditingController noShowFeeController = TextEditingController();
  int appointmentDuration = 0;
  String selectedRadioButton = 'Continue indefinitely';
  String selectedDateRange = '';
  String selectedAppointmentType = '';

  @override
  void initState() {
    super.initState();
    _fetchAndSaveValues();
    consultationFeeController.addListener(_saveValues);
    noShowFeeController.addListener(_saveValues);
  }

  void _updateAppointmentDuration(int newDuration) {
    setState(() {
      appointmentDuration = newDuration;
    });
    _saveValues();
  }

  Future<void> _selectDateRange(BuildContext context) async {
    final DateTimeRange? picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      setState(() {
        selectedDateRange =
            '${picked.start.day} ${_getMonthName(picked.start.month)} - ${picked.end.day} ${_getMonthName(picked.end.month)} ${picked.end.year}';
      });
      _updateSelectedDateRange(selectedDateRange);
    }
  }

  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  Future<void> _fetchAndSaveValues() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      var fetchedData = await APIService.fetchDataFromBackend(context);

      if (fetchedData != null && fetchedData.isNotEmpty) {
        var data = fetchedData[0];
        print('Fetched data: $data');
        setState(() {
          consultationFeeController.text = data['cost'] ?? '';
          noShowFeeController.text = data['no_show_cost'] ?? '';
          appointmentDuration = data['duration'] ?? 0;
          selectedDateRange =
              '${_formatDate(data['start_date'])} - ${_formatDate(data['end_date'])}';
          selectedRadioButton = data['is_run_forever']
              ? 'Continue indefinitely'
              : 'Within a date range';
        });

        await prefs.clear();
        await prefs.setString(
            'consultationFee', consultationFeeController.text);
        await prefs.setString('noShowFee', noShowFeeController.text);
        await prefs.setInt('appointmentDuration', appointmentDuration);
        await prefs.setString('selectedDateRange', selectedDateRange);
        await prefs.setString('selectedRadioButton', selectedRadioButton);
      } else {
        print('No data fetched, using defaults');
        setState(() {
          consultationFeeController.text = '';
          noShowFeeController.text = '';
          appointmentDuration = 0;
          selectedDateRange = '';
          selectedRadioButton = '';
        });

        await prefs.clear();
        await prefs.setString('consultationFee', '');
        await prefs.setString('noShowFee', '');
        await prefs.setInt('appointmentDuration', 0);
        await prefs.setString('selectedDateRange', '');
        await prefs.setString('selectedRadioButton', '');
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        consultationFeeController.text = '';
        noShowFeeController.text = '';
        appointmentDuration = 0;
        selectedDateRange = '';
        selectedRadioButton = '';
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      await prefs.setString('consultationFee', '');
      await prefs.setString('noShowFee', '');
      await prefs.setInt('appointmentDuration', 0);
      await prefs.setString('selectedDateRange', '');
      await prefs.setString('selectedRadioButton', '');
    }
  }

  String _formatDate(String date) {
    DateTime parsedDate = DateTime.parse(date);
    String day = parsedDate.day.toString().padLeft(2, '0');
    String month = _getMonthName(parsedDate.month);
    String year = parsedDate.year.toString();
    return '$day $month ';
  }

  Future<void> _updateSelectedRadioButton(String newRadioButton) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString('selectedRadioButton', newRadioButton);
    setState(() {
      selectedRadioButton = newRadioButton;
    });
    _saveValues();
  }

  Future<void> _updateSelectedDateRange(String newDateRange) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      selectedDateRange = newDateRange;
    });
    _saveValues();
  }

  Future<void> _saveValues() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    await prefs.setString('consultationFee', consultationFeeController.text);
    await prefs.setString('noShowFee', noShowFeeController.text);
    await prefs.setInt('appointmentDuration', appointmentDuration);
    await prefs.setString('selectedDateRange', selectedDateRange);
    await prefs.setString('selectedRadioButton', selectedRadioButton);
  }

  @override
  void dispose() {
    consultationFeeController.dispose();
    noShowFeeController.dispose();
    super.dispose();
  }

  void _navigateTOWorkingHoursPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => WorkingHours()),
    );
  }

  @override
  Widget build(BuildContext context) {
    var userProvider =
        Provider.of<UserProvider>(context); //* Accessing the UserProvider
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              //* Top heading with back button section
              Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(top: 20, right: 20, left: 30),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Icon(
                          Icons.arrow_back,
                          color: Color(0xFF6F7ED7),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //* heading and information text section
              Column(
                children: [
                  Text(
                    'Manage Appointments',
                    style: GoogleFonts.openSans(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 10),
                    child: Center(
                      child: Text(
                        'Your information will be shared with our Medical Expert team who will verify your identity',
                        textAlign: TextAlign.center,
                        style: GoogleFonts.openSans(
                          fontSize: 12.sp,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              //* Appointment types section
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Text(
                      'Appointment Type',
                      style:
                          GoogleFonts.openSans(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              //* Appointment type buttons section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: Pallet.PURE_WHITE,
                    borderRadius: BorderRadius.circular(
                        12.sp), 
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          ElevatedButton(
                            onPressed: () {
                              userProvider
                                  .updateAppointmentType('In Person Visit');
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    userProvider.selectedAppointmentType ==
                                            'In Person Visit'
                                        ? Colors.blue
                                        : Colors.transparent,
                                minimumSize: Size(160.sp, 37.sp),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      7), // Adjust the radius as needed
                                )),
                            child: Text(
                              'In Person Visit',
                              style: GoogleFonts.openSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: userProvider.selectedAppointmentType ==
                                        'In Person Visit'
                                    ? Pallet.PURE_WHITE
                                    : Colors.grey,
                              ),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              if (userProvider.selectedAppointmentType !=
                                  'Online Consultation') {
                                userProvider.updateAppointmentType(
                                    'Online Consultation');
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Online Consultation is not available for now.',
                                      style: GoogleFonts.openSans(
                                          color: Colors.red, fontSize: 12.sp),
                                    ),
                                    duration: Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                    userProvider.selectedAppointmentType ==
                                            'Online Consultation'
                                        ? Colors.blue.shade800
                                        : Colors.transparent,
                                minimumSize: Size(160.sp, 37.sp),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(
                                      7.sp), 
                                )),
                            child: Text(
                              'Online Consultation',
                              style: GoogleFonts.openSans(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                                color: userProvider.selectedAppointmentType ==
                                        'Online Consultation'
                                    ? Pallet.PURE_WHITE
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (userProvider.selectedAppointmentType ==
                          'Online Consultation')
                        SizedBox(
                          height: 40.h,
                          child: Center(
                            child: Text(
                              'Online Consultation is not available for now.',
                              style: GoogleFonts.openSans(color: Colors.red, fontSize: 12.sp),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),

              //* Consultation Fee section
              SizedBox(height: 5.h),
              Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, top: 10, bottom: 5),
                child: Row(
                  children: [
                    Text(
                      'Consultation Fee',
                      style:
                          GoogleFonts.openSans(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              //* Consultation Fee text field section
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Pallet.PURE_WHITE,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: consultationFeeController,
                    decoration: InputDecoration(
                      hintText: 'e.g.: R500',
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 16.0.sp,
                        height: 0.5.h,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0.h, horizontal: 25.0.w),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),

              //* No Show Fee section
              SizedBox(height: 5.h),
              Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, top: 10, bottom: 5),
                child: Row(
                  children: [
                    Text(
                      'No Show Fee',
                      style:
                          GoogleFonts.openSans(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              //* No Show Fee text field section
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Container(
                  height: 40.h,
                  decoration: BoxDecoration(
                    color: Pallet.PURE_WHITE,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: TextField(
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    controller: noShowFeeController,
                    decoration: InputDecoration(
                      hintStyle: GoogleFonts.openSans(
                        fontSize: 16.0.sp,
                        height: 0.5.sp,
                      ),
                      hintText: 'Free',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                          vertical: 15.0.h, horizontal: 25.0.w),
                    ),
                    textAlignVertical: TextAlignVertical.center,
                  ),
                ),
              ),

              //* Appointment Duration section
              Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, top: 10, bottom: 5),
                child: Row(
                  children: [
                    Text(
                      'Appointment Duration',
                      style:
                          GoogleFonts.openSans(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              //* Appointment Duration inputs section
              Padding(
                padding: const EdgeInsets.only(left: 25, right: 25),
                child: Container(
                  height: 30.h,
                  // padding: EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: Pallet.PURE_WHITE,
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: appointmentDuration == 15
                              ? Colors.blue.shade600
                              : Pallet.PURE_WHITE,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              appointmentDuration = 15;
                            });
                            _updateAppointmentDuration(15);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5, top: 2, right: 5),
                            child: Text(
                              '15 min',
                              style: GoogleFonts.openSans(
                                fontWeight: FontWeight.normal,
                                fontSize: 16.sp,
                                color: appointmentDuration == 15
                                    ? Pallet.PURE_WHITE
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: appointmentDuration == 30
                              ? Colors.blue.shade600
                              : Pallet.PURE_WHITE,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              appointmentDuration = 30;
                            });
                            _updateAppointmentDuration(30);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5, top: 2, right: 5),
                            child: Text(
                              '30 min',
                              style: GoogleFonts.openSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                                color: appointmentDuration == 30
                                    ? Pallet.PURE_WHITE
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 15.w),
                      Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: appointmentDuration == 60
                              ? Colors.blue.shade600
                              : Pallet.PURE_WHITE,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              appointmentDuration = 60;
                            });
                            _updateAppointmentDuration(60);
                          },
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: 5, top: 2, right: 5),
                            child: Text(
                              '60 min',
                              style: GoogleFonts.openSans(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.normal,
                                color: appointmentDuration == 60
                                    ? Pallet.PURE_WHITE
                                    : Colors.grey,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 2.w),
                      VerticalDivider(
                          width: 7.w, thickness: 1.sp, color: Colors.grey),
                      SizedBox(width: 2.w),
                      Container(
                        height: 30.h,
                        decoration: BoxDecoration(
                          color: (appointmentDuration != 15 &&
                                  appointmentDuration != 30 &&
                                  appointmentDuration != 60)
                              ? Colors.blue.shade600
                              : Colors.white,
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            _showCustomDurationDialog(context, (duration) {
                              setState(() {
                                appointmentDuration = duration;
                              });
                              _updateAppointmentDuration(appointmentDuration);
                            });
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            minimumSize: Size(5.sp, 4.sp),
                            elevation: 0,
                          ),
                          child: Text(
                            'Custom',
                            style: GoogleFonts.openSans(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.normal,
                              color: (appointmentDuration != 15 &&
                                      appointmentDuration != 30 &&
                                      appointmentDuration != 60)
                                  ? Pallet.PURE_WHITE
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              //* Date Range section
              Padding(
                padding: const EdgeInsets.only(
                    right: 20, left: 20, top: 10, bottom: 5),
                child: Row(
                  children: [
                    Text(
                      'Date Range',
                      style:
                          GoogleFonts.openSans(fontSize: 12.sp, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              //* Date Range inputs
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Radio(
                      value: 'Within a date range',
                      groupValue: selectedRadioButton,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedRadioButton = value;
                            selectedDateRange = 'Select a Range';
                          });
                          _updateSelectedRadioButton(value);
                        }
                      },
                    ),
                    Text('Within a date range'),
                    SizedBox(
                      width: 10.w,
                    ),
                    if (selectedRadioButton == 'Within a date range')
                      Container(
                        height: 40.h,
                        color: Pallet.PURE_WHITE,
                        child: GestureDetector(
                          onTap: () {
                            _selectDateRange(
                                context); //* Function to select date range
                          },
                          child: Padding(
                            padding:
                                const EdgeInsets.only(left: 5, top: 7, right: 5),
                            child: Text(
                              selectedDateRange,
                              style: GoogleFonts.openSans(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.normal,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Row(
                  children: [
                    Radio(
                      value: 'Continue indefinitely',
                      groupValue: selectedRadioButton,
                      onChanged: (String? value) {
                        if (value != null) {
                          setState(() {
                            selectedRadioButton = value;
                            selectedDateRange = 'Continue indefinitely';
                          });
                          _updateSelectedRadioButton(value);
                        }
                      },
                    ),
                    Text('Continue indefinitely'),
                  ],
                ),
              ),

              //buttons....................
              SizedBox(
                height: 2.h,
              ),
              MyButtonWidgets(
                buttonTextPrimary: 'Save',
                onPressedPrimary: () {
                  //* Get all inputs
                  double? consultationFee =
                      double.tryParse(consultationFeeController.text);
                  double? noShowFee = double.tryParse(noShowFeeController.text);
                  String appointmentType = userProvider.selectedAppointmentType;

                  //* Function to determine a boolean value for appointmentType
                  bool isOnlineConsultation(String appointmentType) {
                    if (appointmentType == 'Online Consultation') {
                      return true;
                    } else if (appointmentType == 'in person visit') {
                      return false;
                    }
                    return false;
                  }

                  bool isOnlineAppointment =
                      isOnlineConsultation(appointmentType);

                  //* Function to determine a boolean value for appointmentType
                  bool isRunForever(String selectedRadioButton) {
                    if (selectedRadioButton == 'Continue indefinitely') {
                      return true;
                    } else if (selectedRadioButton == 'Within a date range') {
                      return false;
                    }
                    return false;
                  }

                  bool isRunForeverResults = isRunForever(selectedRadioButton);

                  //* Update the JSON data with new inputs
                  APIService.updateRequestBody(
                    consultationFee: consultationFee,
                    noShowFee: noShowFee,
                    appointmentType: isOnlineAppointment,
                    appointmentDuration: appointmentDuration,
                    selectedRadioButton: isRunForeverResults,
                    selectedDateRange: selectedDateRange,
                  );

                  //* Now send the updated JSON data to the backend
                  APIService.sendDataToBackendFromJSONFile(context,
                      onSuccess: () {
                    _navigateTOWorkingHoursPage();
                  });
                },
                buttonTextSecondary: 'Cancel',
                onPressedSecondary: () {
                  Navigator.pop(context);
                },
              ).buildButtons(primaryFirst: false),
            ],
          ),
        ),
        //buttons....................
      ),
    );
  }

  Future<void> _showCustomDurationDialog(
      BuildContext context, Function(int) onDurationSelected) async {
    int customDuration = 0; //* Track custom duration input
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              title: Text('Enter Custom Duration'),
              content: TextFormField(
                keyboardType: TextInputType.number,
                onChanged: (value) {
                  setState(() {
                    customDuration = int.tryParse(value) ??
                        0; //* Update custom duration input
                  });
                },
                decoration: InputDecoration(
                  hintText: 'Enter duration in minutes',
                ),
              ),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    onDurationSelected(
                        customDuration); //* Pass custom duration to callback
                    Navigator.of(context).pop();
                  },
                  child: Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
