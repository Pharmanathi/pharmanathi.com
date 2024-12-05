import 'package:patient/config/color_const.dart';
import 'package:patient/helpers/api_helpers.dart';
import 'package:patient/model/appointment_data.dart';
import 'package:flutter/material.dart';

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
        color: Pallet.PURE_WHITE,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 20),
            Text(
              appointment.appointmentDate,
              style: const TextStyle(
                fontSize: 12,
                color: Pallet.NEUTRAL_200,
                fontWeight: FontWeight.w300,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              formatAppointmentTime(
                  appointment.appointmentTime, appointment.endTime),
              style: const TextStyle(
                fontSize: 12,
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
