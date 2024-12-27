// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:math';

import 'package:client_pharmanathi/config/color_const.dart';
import 'package:client_pharmanathi/helpers/api_helpers.dart';
import 'package:client_pharmanathi/main.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:client_pharmanathi/views/widgets/appointment_details_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class AppointmentListItem extends StatelessWidget {
  final Appointment appointment;

  const AppointmentListItem({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return ProfileCard(appointment: appointment);
  }
}

class ProfileCard extends StatelessWidget {
  final Appointment appointment;

  const ProfileCard({super.key, required this.appointment});

  //* Function to generate a random color
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  String formatAppointmentDate(String dateString) {
    final DateFormat inputFormat = DateFormat('dd MMM y');
    final DateTime parsedDate = inputFormat.parse(dateString);
    return DateFormat('EEEE d MMM y').format(parsedDate);
  }

  //* i really didnt want to remove the AM/PM right from the model since we still utilise those in other part of the code
  String formatAppointmentTime(String startTime, String endTime) {
    final DateFormat inputFormat12 = DateFormat.jm();
    final DateFormat inputFormat24 = DateFormat('HH:mm');

    DateTime start;
    DateTime end;

    //* parsing the start time in both 12-hour and 24-hour formats
    try {
      start = inputFormat12.parse(startTime);
    } catch (e) {
      start = inputFormat24.parse(startTime);
    }

    //* parsing the end time in both 12-hour and 24-hour formats
    try {
      end = inputFormat12.parse(endTime);
    } catch (e) {
      end = inputFormat24.parse(endTime);
    }

    //* the output format to exclude AM/PM (24-hour format).
    final DateFormat outputFormat = DateFormat('HH:mm');

    //* return the times without AM/PM.
    return '${outputFormat.format(start)} - ${outputFormat.format(end)}';
  }

  @override
  Widget build(BuildContext context) {
    String alteredname =
        ApiHelper.toTitleCase(appointment.doctor.doctorLastName);

    return GestureDetector(
      onTap: () {
        // Navigate to OnlineConsultation page with corresponding data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppiontmentDetails(
              appointment: appointment,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 12, left: 12, bottom: 5),
        child: SizedBox(
          height: 160.h,
          child: Column(
            children: [
              Container(
                  decoration: BoxDecoration(
                    color: Pallet.PURE_WHITE,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 10, left: 24, right: 6),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                backgroundColor: appointment
                                        .doctor.imageURL.isNotEmpty
                                    ? null // No background color if imageURL is available
                                    : getRandomColor(), // Random background color if imageURL is not available
                                child: appointment.doctor.imageURL.isNotEmpty
                                    // ? Image.network(appointment.doctor.imageURL)
                                    ? ClipOval(
                                        child: Image.network(
                                          appointment.doctor.imageURL,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                      )
                                    : Text(
                                        appointment.patient.firstName.isNotEmpty
                                            ? appointment.patient.firstName[0]
                                            : '',
                                        style: GoogleFonts.openSans(
                                            fontSize: 14.sp,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ), //* Display the first letter of the name if imageURL is not available

                                radius: 28.sp,
                              ),
                              SizedBox(
                                width: 26.w,
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 30),
                                          child: SizedBox(
                                            // width: 100,
                                            child: Text(
                                              'Dr. $alteredname',
                                              style: GoogleFonts.openSans(
                                                fontSize: 14.sp,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 70),
                                          child: Text(
                                            appointment.doctor
                                                .getAllSpecialityNames(),
                                            style: GoogleFonts.openSans(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.normal,
                                              color: Colors.grey,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            child: Divider(
                              color: Color(0xFFF7F9FC),
                              thickness: 2.sp,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0),
                                          child: Text(
                                            'Date',
                                            style: GoogleFonts.openSans(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(left: 0),
                                          child: Text(
                                            'Time',
                                            style: GoogleFonts.openSans(
                                                fontSize: 10.sp,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            formatAppointmentDate(
                                                appointment.appointmentDate),
                                            style:GoogleFonts.openSans(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w200,
                                            ),
                                          ),
                                          Text(
                                            formatAppointmentTime(
                                                appointment.appointmentTime,
                                                appointment.endTime),
                                            style:GoogleFonts.openSans(
                                              fontSize: 10.sp,
                                              fontWeight: FontWeight.w200,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8),
                                      child: Row(
                                        children: [
                                          Container(
                                            // height: 30,
                                            // width: 100,
                                            decoration: BoxDecoration(
                                              color: {
                                                'Upcoming': Pallet.NEUTRAL_200,
                                                'Unpaid': Color(0xFFFE16E47),
                                                'Completed': Pallet.WARNING_70,
                                              }[appointment.status],
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                appointment.status,
                                                style: GoogleFonts.openSans(
                                                  fontSize: 10.sp,
                                                  fontWeight: FontWeight.normal,
                                                  color: {
                                                    'Upcoming': Colors.white,
                                                    'Unpaid': Colors.white,
                                                    'Completed': Colors.grey
                                                  }[appointment.status],
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }
}
