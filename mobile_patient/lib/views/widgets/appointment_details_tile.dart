// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, use_super_parameters

import 'package:patient/config/color_const.dart';
import 'package:patient/helpers/api_helpers.dart';
import 'package:patient/main.dart';
import 'package:patient/model/appointment_data.dart';
import 'package:patient/views/widgets/HeaderWidget.dart';
import 'package:patient/views/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class AppiontmentDetails extends StatelessWidget {
  final Appointment appointment;

  const AppiontmentDetails({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    String alteredname =
        ApiHelper.toTitleCase(appointment.doctor.doctorFullName);

    return Scaffold(
      backgroundColor: Color(0xFFF7F9FC),
      body: SingleChildScrollView(
        child: Column(
          children: [
            //back button and the heading
            Container(
                child: HeaderWidget(
              text: 'Appointment Details',
              showBackButton: true,
            )),
            Padding(
              padding: const EdgeInsets.only(top: 15, left: 15, right: 15),
              child: Container(
                width: double.infinity.sp,
                decoration: BoxDecoration(
                  color: Pallet.PURE_WHITE,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Row(
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(appointment.doctor.imageURL),
                            radius: 25.sp,
                          ),
                          // Positioned(
                          //   right: 0,
                          //   bottom: 0,
                          //   child: Container(
                          //     width: 12,
                          //     height: 20,
                          //     decoration: BoxDecoration(
                          //       shape: BoxShape.circle,
                          //       color: Colors.green,
                          //     ),
                          //   ),
                          // ),
                        ],
                      ),
                      SizedBox(width: 20.h),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Dr. $alteredname',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.openSans(
                                fontSize: 14.sp, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            appointment.doctor.getAllSpecialityNames(),
                            style: GoogleFonts.openSans(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.normal,
                              color: Colors.grey,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                      // Padding(
                      //   padding: const EdgeInsets.only(left: 40, top: 50),
                      //   child: Row(
                      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      //     crossAxisAlignment: CrossAxisAlignment.end,
                      //     children: [
                      //       Icon(
                      //         Icons.video_call_sharp,
                      //         color: Colors.grey,
                      //       ),
                      //       Icon(
                      //         Icons.phone,
                      //         color: Colors.grey,
                      //       ),
                      //       Icon(
                      //         Icons.messenger,
                      //         size: 19,
                      //         color: Colors.grey,
                      //       ),
                      //     ],
                      //   ),
                      // ),
                    ],
                  ),
                ),
              ),
            ),
            //heading(booking infor)
            Padding(
              padding: const EdgeInsets.only(
                  top: 20, right: 20, left: 20, bottom: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Booking Info',
                    style: GoogleFonts.openSans(
                        fontSize: 12.sp, fontWeight: FontWeight.bold),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Row(
                      children: [
                        Container(
                          // height: 20,
                          // width: 100,
                          decoration: BoxDecoration(
                            color: {
                              'Upcoming': Pallet.NEUTRAL_200,
                              'Unpaid': Color(0xFFFE16E47),
                              'Completed': Pallet.WARNING_70,
                            }[appointment.status],
                            borderRadius: BorderRadius.circular(12),
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
            ),
            Container(
              child: Column(
                children: [
                  _buildDetailRow(
                    icon: Icons.location_on_sharp,
                    title: 'Location',
                    value:
                        'Practice Name', // TODO: this should be the practice location
                  ),
                  _buildDetailRow(
                    icon: Icons.calendar_month,
                    title: 'Appointment Date',
                    value: appointment.appointmentDate,
                  ),
                  _buildDetailRow(
                    icon: Icons.timer,
                    title: 'Time',
                    value: appointment.appointmentTime,
                  ),
                  _buildDetailRow(
                    icon: Icons.location_on_sharp,
                    title: 'Reason for Consultation',
                    value: appointment.reason,
                  ),
                  _buildDetailRow(
                      icon: Icons.payment_outlined,
                      title: 'Consultation Fee',
                      value:
                          'R ${appointment.doctor.appointmentType?.cost ?? 0}'),
                ],
              ),
            ),
            //buttons
            SizedBox(height: 20.h),
            MyButtonWidgets(buttonTextPrimary: 'Done', onPressedPrimary: () {})
                .buildButtons(primaryFirst: false),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String title,
    required dynamic value, //* Use dynamic to accept both String and int
  }) {
    String displayValue;

    //* Convert value to string if it is not already a string
    if (value is String) {
      displayValue = value;
    } else if (value is int) {
      displayValue = value.toString();
    } else {
      displayValue = 'Invalid value'; //* Fallback in case of unsupported type
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              const EdgeInsets.only(left: 15, top: 15, right: 15, bottom: 10),
          child: Row(
            children: [
              Icon(
                icon,
                size: 19.sp,
                color: Colors.grey,
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Text(
                  title,
                  style: GoogleFonts.openSans(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(left: 45, top: 0),
          child: Text(
            displayValue,
            style: GoogleFonts.openSans(
              fontSize: 12.sp,
              color: Colors.grey,
            ),
          ),
        ),
      ],
    );
  }
}
