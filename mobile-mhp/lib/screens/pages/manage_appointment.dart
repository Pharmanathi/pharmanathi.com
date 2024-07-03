// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unused_local_variable, use_key_in_widget_constructors, library_private_types_in_public_api

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../services/manage_appointment_api.dart';
import '../../views/widjets/buttons.dart';

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

  void _navigateToProfilePage() {
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    var userProvider =
        Provider.of<UserProvider>(context); //* Accessing the UserProvider
    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Expanded(
            child: Column(
              children: [
                //* Top heading with back button section
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 25, right: 30, left: 30),
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
                      style: TextStyle(
                        fontSize: 25,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    Padding(
                      padding:
                          const EdgeInsets.only(top: 22, left: 45, right: 40),
                      child: Text(
                        'Your information will be shared with our Medical Expert team who will verify your identity',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  ],
                ),

                //* Appointment types section
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Row(
                    children: [
                      Text(
                        'Appointment Type',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                //* Appointment type buttons section
                Column(
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
                            minimumSize: Size(180, 40),
                            elevation: 0,
                          ),
                          child: Text(
                            'In Person Visit',
                            style: TextStyle(
                              color: userProvider.selectedAppointmentType ==
                                      'In Person Visit'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        ElevatedButton(
                          onPressed: () {
                            if (userProvider.selectedAppointmentType !=
                                'Online Consultation') {
                              userProvider
                                  .updateAppointmentType('Online Consultation');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Online Consultation is not available for now.',
                                    style: TextStyle(
                                      color: Colors.red,
                                    ),
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
                                    ? Colors.blue
                                    : Colors.transparent,
                            minimumSize: Size(180, 40),
                            elevation: 0,
                          ),
                          child: Text(
                            'Online Consultation',
                            style: TextStyle(
                              color: userProvider.selectedAppointmentType ==
                                      'Online Consultation'
                                  ? Colors.white
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (userProvider.selectedAppointmentType ==
                        'Online Consultation')
                      SizedBox(
                        height: 40,
                        child: Center(
                          child: Text(
                            'Online Consultation is not available for now.',
                            style: TextStyle(
                              color: Colors.red,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                //* Consultation Fee section
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 20, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'Consultation Fee',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                //* Consultation Fee text field section
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: consultationFeeController,
                      decoration: InputDecoration(
                        hintText: 'e.g.: R500',
                        hintStyle: TextStyle(
                          fontSize: 16.0,
                          height: 1, // Adjust this value as needed
                        ),
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),

                //* No Show Fee section
                SizedBox(height: 5),
                Padding(
                  padding: const EdgeInsets.only(
                      right: 20, left: 20, top: 10, bottom: 5),
                  child: Row(
                    children: [
                      Text(
                        'No Show Fee',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                //* No Show Fee text field section
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: TextField(
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      controller: noShowFeeController,
                      decoration: InputDecoration(
                        hintText: 'Free',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.all(10.0),
                      ),
                    ),
                  ),
                ),

                //* Appointment Duration section
                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Text(
                        'Appointment Duration',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                //* Appointment Duration inputs section
                Padding(
                  padding: const EdgeInsets.only(left: 25, right: 25),
                  child: Container(
                    height: 50,
                    padding: EdgeInsets.all(16.0),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              appointmentDuration = 15;
                            });
                            _updateAppointmentDuration(15);
                          },
                          child: Text(
                            '15 min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appointmentDuration == 15
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              appointmentDuration = 30;
                            });
                            _updateAppointmentDuration(30);
                          },
                          child: Text(
                            '30 min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appointmentDuration == 30
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              appointmentDuration = 60;
                            });
                            _updateAppointmentDuration(60);
                          },
                          child: Text(
                            '60 min',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: appointmentDuration == 60
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                        SizedBox(width: 5),
                        VerticalDivider(
                            width: 7, thickness: 1, color: Colors.grey),
                        SizedBox(width: 5),
                        ElevatedButton(
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
                            minimumSize: Size(5, 4),
                            elevation: 0,
                          ),
                          child: Text(
                            'Custom',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: (appointmentDuration != 15 &&
                                      appointmentDuration != 30 &&
                                      appointmentDuration != 60)
                                  ? Colors.blue
                                  : Colors.grey,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                //* Date Range section
                Padding(
                  padding: const EdgeInsets.only(right: 20, left: 20, top: 10),
                  child: Row(
                    children: [
                      Text(
                        'Date Range',
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),

                //* Date Range inputs
                Row(
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
                    if (selectedRadioButton == 'Within a date range')
                      GestureDetector(
                        onTap: () {
                          _selectDateRange(
                              context); //* Function to select date range
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(left: 10),
                          child: Text(
                            selectedDateRange,
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),

                Row(
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

                //buttons....................
                SizedBox(
                  height: 2,
                ),
                MyButtonWidgets(
                  buttonText1: 'Save',
                  onPressed1: () {
                    //* Get all inputs
                    double? consultationFee =
                        double.tryParse(consultationFeeController.text);
                    double? noShowFee =
                        double.tryParse(noShowFeeController.text);
                    String appointmentType =
                        userProvider.selectedAppointmentType;
                    //* function to determmine a boolean valuefor appointmentType
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

                    //* function to determmine a boolean valuefor appointmentType
                    bool isRunForever(String selectedRadioButton) {
                      if (selectedRadioButton == 'Continue indefinitely') {
                        return true;
                      } else if (selectedRadioButton == 'Within a date range') {
                        return false;
                      }
                      return false;
                    }

                    bool isRunForeverResults =
                        isRunForever(selectedRadioButton);

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
                      _navigateToProfilePage();
                    });
                  },
                  buttonText2: 'Cancel',
                  onPressed2: () {
                    Navigator.pop(context);
                  },
                ).buildButton(),
              ],
            ),
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
