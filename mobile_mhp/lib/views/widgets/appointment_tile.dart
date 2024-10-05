import 'package:flutter/material.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/models/appointment.dart';
import 'package:pharma_nathi/views/widgets/appiontment_details.dart';

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
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            //* Appointment Time Text
            Expanded(
              flex: 1,
              child: Text(
                appointment.appointmentTime,
                style: const TextStyle(
                  fontSize: 10,
                  color: Pallet.SECONDARY_500,
                  fontWeight: FontWeight.w100,
                ),
              ),
            ),
            //* Vertical Divider
            Container(
              width: 1,
              height: 100, 
              color: Pallet.SECONDARY_500,
              margin: const EdgeInsets.symmetric(horizontal: 2),
            ),
            // Details Container
            Expanded(
              flex: 5,
              child: Container(
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
                          backgroundImage: NetworkImage(appointment.imageURL),
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
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: appointment.status == 'In Progress'
                                    ? Pallet.PRIMARY_COLOR
                                    : Pallet.Black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: Text(
                                appointment.appointmentDuration,
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w100,
                                  color: appointment.status == 'In Progress'
                                      ? Pallet.PRIMARY_COLOR
                                      : Pallet.SECONDARY_500,
                                ),
                              ),
                            ),
                            // Appointment Status Container
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: appointment.status == 'Upcoming'
                                        ? Pallet.SECONDARY_500
                                        : appointment.status == 'In Progress'
                                            ? Pallet.PURE_WHITE
                                            : appointment.status == 'Completed'
                                                ? Pallet.SECONDARY_500
                                                : Pallet.SECONDARY_500,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Text(
                                      appointment.status,
                                      style: TextStyle(
                                          fontSize: 10,
                                          color:
                                              appointment.status == 'Upcoming'
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
                                  decoration: BoxDecoration(
                                    color: appointment.isOnlineAppointment
                                        ? Pallet.SECONDARY_500
                                        : appointment.status == 'In Progress'
                                            ? Pallet.PURE_WHITE
                                            : Pallet.SECONDARY_500,
                                    borderRadius: BorderRadius.circular(5),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 6),
                                    child: Text(
                                      appointment.isOnlineAppointment
                                          ? 'Online'
                                          : 'In Person',
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: appointment.isOnlineAppointment
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
            ),
          ],
        ),
      ),
    );
  }
}
