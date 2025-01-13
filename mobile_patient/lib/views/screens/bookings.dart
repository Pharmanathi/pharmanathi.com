// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, unnecessary_import, use_super_parameters, library_private_types_in_public_api, sized_box_for_whitespace, unnecessary_string_interpolations, prefer_interpolation_to_compose_strings

import 'dart:io';
import 'package:patient/Repository/appointment_repository.dart';
import 'package:patient/blocs/appointment_bloc.dart';
import 'package:patient/config/color_const.dart';
import 'package:patient/model/doctor_data.dart';
import 'package:patient/views/widgets/buttons.dart';
import 'package:patient/main.dart';
import 'package:flutter/services.dart';
import 'package:patient/views/widgets/calender.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../services/api_provider.dart';
import '../../model/calender_events.dart';

class Bookings extends StatefulWidget {
  final Doctor doctor;
  final ValueNotifier<List<String>> selectedTimeSlots;
  final DateTime selectedDay;

  // Constructor with named parameters
  Bookings({
    Key? key,
    required this.doctor,
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
  late AppointmentBloc _appointmentBloc;
  bool _isLoading = false;

  void handleButtonTap(int index) {
    setState(() {
      selectedButtonIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _appointmentBloc = AppointmentBloc(AppointmentRepository(ApiProvider()));

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

  Future<void> _bookAppointment() async {
    setState(() {
      _isLoading = true;
    });

    try {
      //* Ensure timeOfTheAppointment and selectedDay are not null
      if (timeOfTheAppointment == null || selectedDay == null) {
        throw Exception('Time or date is not set.');
      }

      //* Check if timeOfTheAppointment is in the expected format
      if (timeOfTheAppointment!.length < 5) {
        throw Exception('Invalid time format.');
      }

      //* Extract hour and minute from timeOfTheAppointment
      final hourMinute = timeOfTheAppointment!.substring(0, 5).split(':');
      final appointmentStartTime = DateTime(
        dayOfAppiontment!.year,
        dayOfAppiontment!.month,
        dayOfAppiontment!.day,
        int.parse(hourMinute[0]),
        int.parse(hourMinute[1]),
      );

      //* Format the start_time to match backend requirements
      final formattedStartTime = appointmentStartTime.toIso8601String();

      int appointmentType = widget.doctor.appointmentTypes.first.id;

      //* Modify typeOfPayment based on the api requirements
      String modifyTypeOfPayment(String typeOfPayment) {
        // Modify typeOfPayment based on the condition
        // if (typeOfPayment == 'Before Visit') {
        //   return 'BV';
        // } else if (typeOfPayment == 'After Visit') {
        //   return 'AV';
        // }
        // Return the original typeOfPayment if no modification is needed
        return "BV";
      }

      String modifiedPaymentType = modifyTypeOfPayment(typeOfPayment);
      String reasonForVisit = reasonForVisitControler.text;
      int doctorId = widget.doctor.id;

      //* appointment data we sending to the backend
      Map<String, dynamic> appointmentData = {
        'doctor': doctorId,
        'start_time': formattedStartTime,
        'reason': reasonForVisit,
        'appointment_type': appointmentType,
        'payment_process': modifiedPaymentType,
        'payment_provider':
            'Paystack', //TODO: Replace with actual selected payment provider when its possible to do so
      };

      //* Book appointment and handle response within AppointmentBloc
      await _appointmentBloc.bookAppointment(context, appointmentData);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error booking appointment: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.PURE_WHITE,
      body: Column(
        children: [
          //  header container
          Container(
            width: double.infinity,
            height: 130.h,
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
                      Text(
                        'Booking',
                        style: GoogleFonts.openSans(
                            color: Colors.white,
                            fontSize: 21.0.sp,
                            fontWeight: FontWeight.normal,
                            fontStyle: FontStyle.normal),
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
                    width: 0.2.w,
                  ),
                ),
              ),
              child: Row(
                children: [
                  buildNavButton(0, '1.TIME'),
                  buildNavButton(1, '2.DETAILS'),
                  buildNavButton(2, '3.SURMARY'),
                ],
              ),
            ),
          ),

          //* Switch between different sections based on the selected button index
          if (selectedButtonIndex == 0)
            Container(
                height: 600.h,
                child: Column(
                  children: [
                    Container(
                      height: 550.h,
                      child: Visibility(
                        visible: selectedButtonIndex == 0,
                        child: TableEventsExample(
                          doctorId: widget.doctor.id,
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
                      child: MyButtonWidgets(
                          buttonTextPrimary: 'NEXT',
                          onPressedPrimary: () {
                            _navigateToNextStep();
                          }).buildButtons(primaryFirst: false),
                    ),
                  ],
                ))
          else if (selectedButtonIndex == 1)
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: buildSectionTitle(
                          'Write the reason of your visit, please'),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20.0),
                      child: TextField(
                        controller: reasonForVisitControler,
                        decoration: InputDecoration(
                          hintText: 'Reason for your visit',
                          hintStyle: GoogleFonts.openSans(
                              color: Pallet.NEUTRAL_150,
                              fontStyle: FontStyle.normal,
                              fontWeight: FontWeight.normal),
                          filled: true,
                          fillColor: Pallet.PRAMARY_75,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(5.0),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: EdgeInsets.symmetric(
                              vertical: 25.0.sp, horizontal: 5.sp),
                        ),
                        maxLines: null,
                      ),
                    ),

                    //fill uplaod input
                    buildDivider(),
                    buildSectionTitle(
                        'You may upload related EHR files, if you wish'),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: EdgeInsets.all(15),
                          margin: EdgeInsets.only(right: 10, bottom: 10),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(left: 0),
                                child: Container(
                                  width: 300.w,
                                  child: Text(
                                    'These files will only be available for your Doctor',
                                    style: GoogleFonts.openSans(
                                        color: Pallet.PRIMARY_250,
                                        fontSize: 12.sp),
                                  ),
                                ),
                              ),
                              SizedBox(height: 20.h),
                              ElevatedButton(
                                onPressed: _pickFile,
                                style: ElevatedButton.styleFrom(
                                  elevation: 0,
                                  backgroundColor: Pallet.PRAMARY_75,
                                  minimumSize: Size(117.sp, 40.sp),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(5.0),
                                    side: BorderSide(
                                      color: Pallet.PRIMARY_600,
                                      width: 1.0.w,
                                    ),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(Icons.publish_sharp),
                                    SizedBox(width: 7.w),
                                    Text('UPLOAD',
                                        style: GoogleFonts.openSans(
                                            fontSize: 14.sp,
                                            color: Pallet.PRIMARY_650,
                                            fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                              SizedBox(height: 10.h),
                              _pickedFile != null
                                  ? Column(
                                      children: [
                                        Text(
                                            'Selected File: ${_pickedFile!.path}'),
                                        SizedBox(height: 20.h),
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
                    Center(
                      child: MyButtonWidgets(
                          buttonTextPrimary: 'NEXT',
                          onPressedPrimary: () {
                            _navigateToNextStep();
                          }).buildButtons(primaryFirst: false),
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
                    //doctor name
                    SizedBox(
                      height: 30.h,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0,left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Doctor",
                                  style: GoogleFonts.openSans(
                                    color: Pallet.PRIMARY_250,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Text(
                                  "${widget.doctor.doctorFullName}",
                                  style: GoogleFonts.openSans(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14.sp,
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
                    buildDivider(),
                    //date..................
                    Padding(
                      padding: const EdgeInsets.only(top: 5.0,left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Date",
                                  style: GoogleFonts.openSans(
                                    color: Pallet.PRIMARY_250,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Text(
                                  "${dayOfAppiontment != null ? "${dayOfAppiontment!.day} ${_getMonthName(dayOfAppiontment!.month)} ${dayOfAppiontment!.year}" : "Select a day"}",
                                  style: GoogleFonts.openSans(
                                    color: Colors.black,
                                    fontSize: 14.sp,
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
                      padding: const EdgeInsets.only(top: 2.0,left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Time",
                                  style: GoogleFonts.openSans(
                                    color: Pallet.PRIMARY_250,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Text(
                                  timeOfTheAppointment ?? "Select a time",
                                  style: GoogleFonts.openSans(
                                    color: Colors.black,
                                    fontSize: 14.sp,
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
                      padding: const EdgeInsets.only(top: 2.0,left: 20,right: 20),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 300.w,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Consultation fes",
                                  style: GoogleFonts.openSans(
                                    color: Pallet.PRIMARY_250,
                                    fontWeight: FontWeight.normal,
                                    fontSize: 14.sp,
                                  ),
                                ),
                                SizedBox(
                                  height: 8.h,
                                ),
                                Text(
                                  widget.doctor.appointmentType?.cost
                                          .toString() ??
                                      '',
                                  style: GoogleFonts.openSans(
                                    color: Colors.black,
                                    fontSize: 14.sp,
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
                    buildDivider(),
                    SizedBox(
                      height: 20.h,
                    ),
                    Center(
                      child: MyButtonWidgets(
                        buttonTextPrimary: _isLoading
                            ? ''
                            : 'Book Appointment', // Button text when not loading
                        onPressedPrimary: _isLoading
                            ? null
                            : _bookAppointment, // Disable button when loading
                      ).buildButtons(
                        primaryFirst: false,
                        primaryWidget: _isLoading
                            ? CircularProgressIndicator(
                                valueColor: AlwaysStoppedAnimation<Color>(
                                    Colors.white), // Loading indicator color
                                strokeWidth: 1.0,
                              )
                            : null, // Only show the spinner when loading
                      ),
                    ),
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
                width: 3.w,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.only(right: 10),
            child: Text(
              text,
              style: GoogleFonts.openSans(
                fontWeight: FontWeight.bold,
                fontSize: 14.sp,
                fontStyle: FontStyle.normal,
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
        style: GoogleFonts.openSans(
          color: Colors.black,
          fontSize: 15.0.sp,
          fontStyle: FontStyle.normal,
          fontWeight: FontWeight.normal,
        ),
      ),
    );
  }

  // Common divider widget
  Widget buildDivider() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Align(
        alignment: Alignment.center,
        child: FractionallySizedBox(
          widthFactor: 0.95.sp, //* Set the width to 95% of the available space
          child: Divider(
            color: Colors.grey[200],
          ),
        ),
      ),
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
