import 'package:flutter/material.dart';
import '../../models/appointment.dart';
import 'appiontment_details.dart';


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
             appointment:  appointment,
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 0),
        child: Container(
          height: 135,
          child: Column(
            children: [
              Row(
                children: [
                  Text(
                    appointment.appointmentTime,
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w100,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Flexible(
                    child: Divider(
                      color: Colors.grey,
                      thickness: 1,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: Container(
                  width: 345,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Align(
                      alignment: Alignment.center,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                           CircleAvatar(
                          radius: 32,
                          backgroundImage:
                              AssetImage(appointment.imageURL?? ''),
                        ),
                          Padding(
                            padding: const EdgeInsets.only(left: 10),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 30),
                                        child: Container(
                                          width: 200,
                                          child: Text(
                                            appointment.patientName,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        appointment.appointmentTime,
                                        style: const TextStyle(
                                          fontSize: 12,
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
                                          padding: const EdgeInsets.all(6),
                                          child: Text(
                                            appointment.status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
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
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
