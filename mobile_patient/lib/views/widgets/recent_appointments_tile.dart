import 'package:client_pharmanathi/config/color_const.dart';
import 'package:client_pharmanathi/helpers/api_helpers.dart';
import 'package:client_pharmanathi/main.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';

class RecentAppointmentsTile extends StatelessWidget {
  final Appointment appointment;
  const RecentAppointmentsTile({super.key, required this.appointment});

  String formatAppointmentTime(String startTime, String endTime) {
    return '$startTime - $endTime';
  }

  @override
  Widget build(BuildContext context) {
    String name = ApiHelper.toTitleCase(appointment.doctor.doctorFullName);

    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color:Pallet.PURE_WHITE,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style:GoogleFonts.openSans(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 20.h),
            Text(
              appointment.appointmentDate,
              style:GoogleFonts.openSans(
                fontSize: 12.sp,
                color: Pallet.NEUTRAL_200,
                fontWeight: FontWeight.w300,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              formatAppointmentTime(
                  appointment.appointmentTime, appointment.endTime),
              style:GoogleFonts.openSans(
                fontSize: 12.sp,
                color: Pallet.NEUTRAL_200,
                fontWeight: FontWeight.w300,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
