// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_import, use_super_parameters, library_private_types_in_public_api, sized_box_for_whitespace, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:client_pharmanathi/services/booking_api.dart';
import 'package:flutter/services.dart';
import 'package:client_pharmanathi/screens/components/calender/calender.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../components/calender/events.dart';

class Bookings extends StatefulWidget {
  final String name;
  final int doctorId;
  final int appointmentType;
  final String title;
  final String imageUrl;
  final String status;
  final String distance;
  final String rating;
  final String location;
  final bool has_consulted_before;
  final String experience;
  final ValueNotifier<List<String>> selectedTimeSlots;
  final DateTime selectedDay;

  // Constructor with named parameters
  Bookings({
    Key? key,
    required this.name,
    required this.title,
    required this.doctorId,
    required this.appointmentType,
    required this.has_consulted_before,
    required this.imageUrl,
    required this.status,
    required this.distance,
    required this.rating,
    required this.location,
    required this.experience,
    required this.selectedTimeSlots,
    DateTime? selectedDay,
  })  : selectedDay =
            selectedDay ?? DateTime.now(), //* Initialization selectedDay
        super(key: key);

  @override
  _BookingsState createState() => _BookingsState();
}

class _BookingsState extends State<Bookings> {
  int selectedButtonIndex = 0;
  String selectedAppointmentType = '';
  String typeOfPayment = '';
  String selectedPaymentType = '';
  String? selectedInsuranceOption;
  File? _pickedFile;
  DateTime? selectedDay;
  List<Event> selectedEvents = [];
  String? timeOfTheAppointment;
  DateTime? dayOfAppiontment;

  TextEditingController addressController = TextEditingController();
  TextEditingController reasonForVisitControler = TextEditingController();

  void handleButtonTap(int index) {
    setState(() {
      selectedButtonIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();

    //* Initialize timeOfTheAppointment with the initial value of selectedTimeSlots
    timeOfTheAppointment = widget.selectedTimeSlots.value.isNotEmpty
        ? widget.selectedTimeSlots.value[0]
        : null;

    //* Initialize selectedDay with the initial value
    selectedDay = widget.selectedDay;
  }

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null) {
      setState(() {
        _pickedFile = File(result.files.single.path!);
      });
    }
  }

  //* Function to navigate to the next step
  void _navigateToNextStep() {
    setState(() {
      selectedButtonIndex++;

      //* Update selectedDay with the latest value from the widget
      selectedDay = widget.selectedDay;
    });
  }

  void _showSuccessMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('your appointment has been booked successfully!'),
        duration: Duration(seconds: 5),
        behavior: SnackBarBehavior.floating,
        backgroundColor: Colors.green,
      ),
    );
  }

  void _onSuccessNavigation() {
    Navigator.pushReplacementNamed(context, '/appointment');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          //  header container
          Container(
            width: double.infinity,
            height: 130,
            color: const Color(0xFF6F7ED7),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 70, right: 130),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(right: 50),
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: const Icon(
                            Icons.arrow_back,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Text(
                        'Booking',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Navigation buttons
          Padding(
            padding: const EdgeInsets.only(top: 30),
            child: Container(
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.grey,
                    width: 0.2,
                  ),
                ),
              ),
              child: Row(
                children: [
                  buildNavButton(0, '1.TIME'),
                  buildNavButton(1, '2.DETAILS'),
                  buildNavButton(2, '3.FINISH'),
                ],
              ),
            ),
          ),

          //* Switch between different sections based on the selected button index
          if (selectedButtonIndex == 0)
            Container(
                height: 600,
                child: Column(
                  children: [
                    Container(
                      height: 550,
                      child: Visibility(
                        visible: selectedButtonIndex == 0,
                        child: TableEventsExample(
                          doctorId: widget.doctorId,
                          onAppointmentTimeSelected: (selectedTimeSlot) {
                            setState(() {
                              // Assign selectedTimeSlot to timeOfTheAppointment
                              timeOfTheAppointment = selectedTimeSlot;

                              print(
                                  'Selected time slot in BookingScreen: $selectedTimeSlot');
                              print(
                                  'timeOfTheAppointment in BookingScreen: $timeOfTheAppointment');
                            });
                          },
                          onAppointmentDaySelected: (selectedDate) {
                            setState(() {
                              dayOfAppiontment = selectedDate;
                            });
                          },
                        ),
                      ),
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToNextStep();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6F7ED7),
                          padding: EdgeInsets.symmetric(
                              horizontal: 100.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          "NEXT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ))
          else if (selectedButtonIndex == 1)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildSectionTitle('Insurance'),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: DropdownButtonFormField<String>(
                        value: selectedInsuranceOption,
                        items: [
                          "Yes",
                          "No",
                          // Add more options as needed
                        ].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          // Handle the change in the selected weight
                          setState(() {
                            selectedInsuranceOption = newValue;
                          });
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.grey[200],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10.0),
                            borderSide: BorderSide.none,
                          ),
                          hintText: 'select',
                        ),
                      ),
                    ),
                    buildDivider(),
                    buildSectionTitle('Please state the reason for your visit'),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                          controller: reasonForVisitControler,
                          decoration: InputDecoration(
                              hintText: 'Reason for your visit',
                              hintStyle: TextStyle(color: Colors.grey),
                              filled: true,
                              fillColor: Colors.grey[200],
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.0),
                                borderSide: BorderSide.none,
                              ))),
                    ),
                    //fill uplaod input
                    buildDivider(),
                    buildSectionTitle(
                        'You may upload related EHR files if you wish'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.all(10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    Icons.lock,
                                    color: Colors.grey[700],
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 10),
                                    child: Container(
                                      width: 300,
                                      child: Text(
                                        'These files will only be available for your Doctor',
                                        style: TextStyle(
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: _pickFile,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        0.0), // Adjust the value as needed
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.publish_sharp),
                                    SizedBox(width: 10),
                                    Text('UPLOAD'),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10),
                              _pickedFile != null
                                  ? Column(
                                      children: [
                                        Text(
                                            'Selected File: ${_pickedFile!.path}'),
                                        SizedBox(height: 20),
                                        Image.file(_pickedFile!),
                                      ],
                                    )
                                  : Container(),
                            ],
                          ),
                        ),
                      ],
                    ),

                    buildDivider(),
                    buildSectionTitle('Paymment type'),
                    RadioListTile(
                      title: Text('Before Visit'),
                      value: 'Before Visit',
                      groupValue: typeOfPayment,
                      onChanged: (value) {
                        setState(() {
                          typeOfPayment = value as String;
                        });
                      },
                    ),
                    RadioListTile(
                      title: Text('After Visit'),
                      value: 'After Visit',
                      groupValue: typeOfPayment,
                      onChanged: (value) {
                        setState(() {
                          typeOfPayment = value as String;
                        });
                      },
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          _navigateToNextStep();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6F7ED7),
                          padding: EdgeInsets.symmetric(
                              horizontal: 100.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          "NEXT",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else if (selectedButtonIndex == 2)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Text(
                        "DETAILS",
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    //doctor name
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Doctor",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  widget.name,
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.person_2,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    //date..................
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "${dayOfAppiontment != null ? "${dayOfAppiontment!.day} ${_getMonthName(dayOfAppiontment!.month)} ${dayOfAppiontment!.year}" : "Select a day"}",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.calendar_month,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildDivider(),
                    //time...........

                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Time",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  timeOfTheAppointment ?? "Select a time",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.timelapse,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildDivider(),
                    //insurence..................
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Paymment",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "$typeOfPayment",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Icon(
                              Icons.work,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),

                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Get all inputs
                          String doctorName = widget.name;
                          String reasonForVisit = reasonForVisitControler.text;
                          int doctorId = widget.doctorId;
                          int appointmentType = widget.appointmentType;

                          // Modify typeOfPayment based on the api requirements
                          String modifyTypeOfPayment(String typeOfPayment) {
                            // Modify typeOfPayment based on the condition
                            if (typeOfPayment == 'Before Visit') {
                              return 'BV';
                            } else if (typeOfPayment == 'After Visit') {
                              return 'AV';
                            }
                            // Return the original typeOfPayment if no modification is needed
                            return typeOfPayment;
                          }

                          String modifiedPaymentType =
                              modifyTypeOfPayment(typeOfPayment);

                          // Function to update and send booking data
                          void bookAppointment() {
                            // Update the JSON data with new inputs
                            BookingAPIService.updateRequestBody(
                              appointmentType: appointmentType,
                              reasonForVisit: reasonForVisit,
                              appointmentDay: dayOfAppiontment,
                              doctorName: doctorName,
                              doctorId: doctorId,
                              timeOfAppointment: timeOfTheAppointment,
                              typeOfPayment: modifiedPaymentType,
                              uploadedEHRFiles: _pickedFile,
                            );

                            // Now send the updated JSON data to the backend
                            BookingAPIService.sendBookingDataToBackend(context,
                                onSuccess: () {
                              _showSuccessMessage();
                              _onSuccessNavigation();
                            });
                          }

                          if (!widget.has_consulted_before) {
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text("Confirm Booking"),
                                  content: Text(
                                      "Do you want to proceed with booking the appointment? By proceeding, you grant this Medical Professional permission to access both your medical and personal information. However, all information will remain strictly confidential."),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                        bookAppointment();
                                      },
                                      child: Text("Proceed"),
                                    ),
                                  ],
                                );
                              },
                            );
                          } else {
                            bookAppointment();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6F7ED7),
                          padding: EdgeInsets.symmetric(
                              horizontal: 100.0, vertical: 15.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          elevation: 0,
                          textStyle: TextStyle(
                            fontSize: 16.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        child: Text(
                          "Book Appointment",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  // Common button widget for navigation
  Widget buildNavButton(int index, String text) {
    return Expanded(
      child: InkWell(
        onTap: () => handleButtonTap(index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 15.0),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selectedButtonIndex == index
                    ? const Color(0xFF6F7ED7)
                    : Colors.transparent,
                width: 3.5,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selectedButtonIndex == index
                    ? const Color(0xFF6F7ED7)
                    : Colors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Common section title widget
  Widget buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, left: 15),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.black,
          fontSize: 15.0,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Common divider widget
  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Divider(height: 0, color: Colors.grey[200]),
    );
  }

//formating the month( changing the number the a month name)
  String _getMonthName(int month) {
    switch (month) {
      case 1:
        return "JAN";
      case 2:
        return "FEB";
      case 3:
        return "MAR";
      case 4:
        return "APR";
      case 5:
        return "MAY";
      case 6:
        return "JUN";
      case 7:
        return "JUL";
      case 8:
        return "AUG";
      case 9:
        return "SEP";
      case 10:
        return "OCT";
      case 11:
        return "NOV";
      case 12:
        return "DEC";
      default:
        return "";
    }
  }
}
