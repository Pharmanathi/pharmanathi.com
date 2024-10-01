import 'package:flutter/material.dart';
import 'package:pharma_nathi/views/widgets/appiontment_details.dart';
import '../../models/appointment.dart';

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
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Appointment Time Text
            Text(
              appointment.appointmentTime,
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w100,
              ),
            ),
            const SizedBox(width: 6), // Space between time text and container
            // Details Container
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
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
                      const SizedBox(width: 8), // Space between avatar and text
                      // Appointment Details
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              appointment.patientName,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              appointment.appointmentTime,
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w100,
                              ),
                            ),
                            const SizedBox(height: 3),
                            // Appointment Status Container
                            Container(
                              decoration: BoxDecoration(
                                color: appointment.status == 'Upcoming'
                                    ? const Color(0xFFECF7EF)
                                    : appointment.status == 'In Progress'
                                        ? const Color(0xFF6F7ED7)
                                        : appointment.status == 'Completed'
                                            ? const Color(0xFFECF7EF)
                                            : const Color(0xFFECF7EF),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 6),
                                child: Text(
                                  appointment.status,
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: appointment.status == 'Upcoming'
                                        ? Colors.grey
                                        : appointment.status == 'In Progress'
                                            ? Colors.white
                                            : appointment.status == 'Completed'
                                                ? Colors.blue
                                                : Colors.blue,
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
