// ignore_for_file: must_be_immutable, prefer_const_constructors, non_constant_identifier_names, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/views/widgets/appiontment_details.dart';

import '../../models/appointment.dart';

class UpcomingAppointmentTile extends StatelessWidget {
  final Appointment appointment;

  const UpcomingAppointmentTile({
    Key? key,
    required this.appointment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to AppiontmentDetails page with corresponding data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AppiontmentDetails(
              appointment: appointment,
            ),
          ),
        );
      },
      child: Container(
        height: 140.sp, 
        width: 194.sp, 
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
               SizedBox(height: 42.sp),
              Text(
                appointment.patientName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.openSans(fontSize: 16.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                appointment.appointmentTime,
                style: GoogleFonts.openSans(fontSize: 12, color: Colors.grey),
              ),
              SizedBox(height: 8),
              Text(
                appointment.appointmentDate,
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
              // SizedBox(height: 8),
              // Text(
              //   'Status: ${appointment.status}',
              //   style: TextStyle(
              //     fontSize: 12,
              //     color: appointment.status == "Upcoming"
              //         ? Colors.green
              //         : Colors.red,
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }
}
