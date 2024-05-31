// ignore_for_file: prefer_typing_uninitialized_variables, non_constant_identifier_names, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/appointments/appointment_data.dart';
import '../../pages/appiontment_details.dart';

class ProfileCard extends StatelessWidget {
  final time;
  final name;
  final appointmentDate;
  final imageURL;
  final status;
  final String clinic_name;
  final String clinic_address;
  final String consult_details;
  final String patientdetails;

  final Appointment appointmentData;

  const ProfileCard(
      {super.key, required this.appointmentData,
      required this.appointmentDate,
      required this.imageURL,
      required this.patientdetails,
      required this.clinic_name,
      required this.consult_details,
      required this.clinic_address,
      required this.name,
      required this.status,
      required this.time});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        //* Navigate to OnlineConsultation page with corresponding data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineConsultation(
              //* Pass the corresponding data to OnlineConsultation
              patientName: name,
              appointmentTime: time,
              details: patientdetails,
              clinic_name: clinic_name,
              clinic_address: clinic_address,
              appiontment_date: appointmentDate,
              time: time,
              consult_details: consult_details,
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
                    time,
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
                              AssetImage('assets/images/sample.JPG'),
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
                                            name,
                                            style: const TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                      Text(
                                        time,
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
                                          color: status == 'Upcoming'
                                              ? const Color(0xFFECF7EF)
                                              : status == 'In Progress'
                                                  ? const Color(0xFF6F7ED7)
                                                  : status == 'Completed'
                                                      ? const Color(0xFFECF7EF)
                                                      : const Color(0xFFECF7EF),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(6),
                                          child: Text(
                                            status,
                                            style: TextStyle(
                                              fontSize: 12,
                                              fontWeight: FontWeight.normal,
                                              color: status == 'Upcoming'
                                                  ? Colors.grey
                                                  : status == 'In Progress'
                                                      ? Colors.white
                                                      : status == 'Completed'
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
