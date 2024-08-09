import 'package:client_pharmanathi/helpers/api_helpers.dart';
import 'package:client_pharmanathi/model/appointment_data.dart';
import 'package:flutter/material.dart';


class RecentAppointmentsTile extends StatelessWidget {
  final Appointment appointment; 
  const RecentAppointmentsTile({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    
     String name = ApiHelper.toTitleCase(appointment.doctor.doctorName);

    return Container(
      height: 100,
      width: 180,
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
                'Dr. $name',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                appointment.appointmentTypeRepr,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              Text(
                appointment.appointmentTime,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 8),
              const Text(
                "In Person Visit",//TODO :get the type oof apponitment they choose
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
