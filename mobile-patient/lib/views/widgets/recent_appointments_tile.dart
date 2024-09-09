import 'package:client_pharmanathi/helpers/api_helpers.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:flutter/material.dart';


class RecentAppointmentsTile extends StatelessWidget {
  final Appointment appointment; 
  const RecentAppointmentsTile({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    
     String name = ApiHelper.toTitleCase(appointment.doctor.doctorLastName);

    return Container(
      height: 50,
      width: 170,
      margin: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Align(
        alignment: Alignment.bottomLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, top: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                appointment.appointmentDate,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                appointment.appointmentTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
