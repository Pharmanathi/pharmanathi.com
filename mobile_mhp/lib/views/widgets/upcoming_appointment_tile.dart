// ignore_for_file: must_be_immutable, prefer_const_constructors, non_constant_identifier_names, use_super_parameters

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_nathi/blocs/address_bloc.dart';
import 'package:pharma_nathi/views/widgets/appiontment_details.dart';
import 'package:provider/provider.dart';
import './custom_google_fonts.dart';
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
            builder: (context) => ChangeNotifierProvider.value(
              value: Provider.of<AddressBloc>(context, listen: false),
              child: AppiontmentDetails(
                appointment: appointment,
              ),
            ),
          ),
        );
      },
      child: Container(
        // height: 155.h,
        width: 170.w,
        margin: EdgeInsets.only(right: 8.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8.0, 40, 8, 8),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            SizedBox(height: 18.sp),
            Text(
              appointment.patientName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: GoogleFontsCustom.openSans(
                  fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              appointment.appointmentTime,
              style: GoogleFontsCustom.openSans(
                  fontSize: 12.sp, color: Colors.grey),
            ),
            SizedBox(height: 8),
            Text(
              appointment.appointmentDate,
              style: TextStyle(fontSize: 12.sp, color: Colors.grey),
            ),
          ]),
        ),
      ),
    );
  }
}
