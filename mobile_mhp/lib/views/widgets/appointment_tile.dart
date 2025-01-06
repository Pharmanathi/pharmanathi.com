import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/models/appointment.dart';
import 'package:pharma_nathi/views/widgets/appiontment_details.dart';
import './custom_google_fonts.dart';

class AppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const AppointmentTile({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppiontmentDetails(
              appointment: appointment,
            ),
          ),
        );
      },
      child: SizedBox(
        height: 90.h,
        // width: 354.w,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //* Appointment Time Text
            // Expanded(
            //   flex: 1,
            //   child: Text(
            //     appointment.appointmentTime,
            //     style: GoogleFontsCustom.openSans(
            //       fontSize: 10.sp,
            //       color: Pallet.NEUTRAL_900,
            //       fontWeight: FontWeight.w100,
            //     ),
            //   ),
            // ),
            Container(
              padding: EdgeInsets.all(8.0),
              width: 45.w,
              child: Text(
                appointment.appointmentTime,
                style: GoogleFontsCustom.openSans(
                  fontSize: 10.sp,
                  color: Pallet.NEUTRAL_900,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            //* Vertical Divider
            Container(
              width: 0.2,
              height: 120,
              color: Pallet.SECONDARY_500,
              // margin: const EdgeInsets.symmetric(horizontal: 2),
            ),
            // Details Container
            SizedBox(
              width: 299.w,
              height: 90.h,
              child: Column(
                children: [
                  Container(
                    height: 80.h,
                    // width: 299.w,
                    decoration: BoxDecoration(
                      color: appointment.status == 'In Progress'
                          ? Pallet.PRIMARY_COLOR
                          : Pallet.PURE_WHITE,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Profile Image
                          Padding(
                            padding: const EdgeInsets.only(left: 5, right: 8),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundImage:
                                  NetworkImage(appointment.imageURL),
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Appointment Details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  appointment.patientName,
                                  style: GoogleFontsCustom.openSans(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: appointment.status == 'In Progress'
                                        ? Pallet.BACKGROUND_COLOR
                                        : Pallet.Black,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 3),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    appointment.appointmentDuration,
                                    style: GoogleFontsCustom.openSans(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w500,
                                      color: appointment.status == 'In Progress'
                                          ? Pallet.BACKGROUND_COLOR
                                          : Pallet.SECONDARY_500,
                                    ),
                                  ),
                                ),
                                // Appointment Status Container
                                Row(
                                  children: [
                                    Container(
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: appointment.status == 'Upcoming'
                                            ? Pallet.SECONDARY_500
                                            : appointment.status ==
                                                    'In Progress'
                                                ? Pallet.PURE_WHITE
                                                : appointment.status ==
                                                        'Completed'
                                                    ? Pallet.SECONDARY_500
                                                    : Pallet.SECONDARY_500,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        child: Text(
                                          appointment.status,
                                          style: GoogleFontsCustom.openSans(
                                              fontSize: 10,
                                              color: appointment.status ==
                                                      'Upcoming'
                                                  ? Pallet.PURE_WHITE
                                                  : appointment.status ==
                                                          'In Progress'
                                                      ? Pallet.PRIMARY_COLOR
                                                      : appointment.status ==
                                                              'Completed'
                                                          ? Pallet.PURE_WHITE
                                                          : Pallet.PURE_WHITE),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 15),
                                    Container(
                                      height: 20.h,
                                      decoration: BoxDecoration(
                                        color: appointment.isOnlineAppointment
                                            ? Pallet.SECONDARY_500
                                            : appointment.status ==
                                                    'In Progress'
                                                ? Pallet.PURE_WHITE
                                                : Pallet.SECONDARY_500,
                                        borderRadius: BorderRadius.circular(5),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 3),
                                        child: Text(
                                          appointment.isOnlineAppointment
                                              ? 'Online'
                                              : 'In Person',
                                          style: GoogleFontsCustom.openSans(
                                            fontSize: 10.sp,
                                            color:
                                                appointment.isOnlineAppointment
                                                    ? Pallet.PURE_WHITE
                                                    : appointment.status ==
                                                            'In Progress'
                                                        ? Pallet.PRIMARY_COLOR
                                                        : Pallet.PURE_WHITE,
                                          ),
                                        ),
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
                  ),
                  // Push main card upward
                  SizedBox(
                    height: 10,
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
