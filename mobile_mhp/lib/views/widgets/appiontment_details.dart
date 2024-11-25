// ignore_for_file: avoid_unnecessary_containers, prefer_const_literals_to_create_immutables, prefer_const_constructors, non_constant_identifier_names, use_super_parameters

import 'package:flutter/material.dart';
import 'package:pharma_nathi/config/color_const.dart';

import '../../models/appointment.dart';

class AppiontmentDetails extends StatelessWidget {
  final Appointment appointment;

  const AppiontmentDetails({super.key, required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Back button and the heading
              Container(
                decoration:
                    BoxDecoration(borderRadius: BorderRadius.circular(25)),
                child: Padding(
                  padding: const EdgeInsets.only(top: 25, right: 30, left: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: const Icon(
                          Icons.arrow_back,
                          color: Color(0xFF6F7ED7),
                        ),
                      ),
                      const Padding(
                        padding: EdgeInsets.only(left: 100, bottom: 5),
                        child: Text(
                          'Summary',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF6F7ED7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Heading (personal info)
              const Padding(
                padding: EdgeInsets.only(left: 15, top: 10, bottom: 10),
                child: Row(
                  children: [
                    Text(
                      'Personal Info',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              // Profile information
              Padding(
                padding: const EdgeInsets.only(left: 20, right: 20),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: Pallet.PURE_WHITE),
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Row(
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            CircleAvatar(
                              backgroundImage:
                                  NetworkImage(appointment.imageURL),
                              radius: 27,
                            ),
                            Positioned(
                              right: 0,
                              bottom: 0,
                              child: Container(
                                width: 12,
                                height: 20,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(width: 10),
                        Padding(
                          padding: const EdgeInsets.only(left: 5),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                appointment.patientName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 14, fontWeight: FontWeight.bold),
                              ),
                              Text(
                                appointment.consult_details,
                                style: const TextStyle(
                                  color: Colors.grey,
                                  fontSize: 14,
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
              // Heading (booking info)
              const Padding(
                padding: EdgeInsets.all(15.0),
                child: Row(
                  children: [
                    Text(
                      'Booking Info',
                      style:
                          TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              //* Booking details

              _buildBookingDetail(Icons.location_on_sharp,
                  appointment.clinic_name, appointment.clinic_address),
              _buildBookingDetail(Icons.calendar_month, 'Appointment Date',
                  appointment.appointmentDate),
              _buildBookingDetail(
                  Icons.timer, 'Time', appointment.appointmentTime),
              _buildBookingDetail(Icons.location_on_sharp,
                  'Reason for Consultation', appointment.consult_details),
              _buildBookingDetail(
                  Icons.money, 'Consultation Fee', appointment.consultationFee),

              //* Buttons
              const SizedBox(height: 40),
              // Center(
              //   child: MyButtonWidgets(
              //     buttonText1: 'RESCHEDULE',
              //     onPressed1: () {
              //       // Handle the custom button action
              //     },
              //     buttonText2: 'REJECT',
              //     onPressed2: () {
              //       // Handle the custom button action
              //     },
              //   ).buildButton(),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBookingDetail(IconData icon, String title, String subtitle) {
    return Container(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(
              left: 15,
              top: 15,
              right: 15,
              bottom: 10,
            ),
            child: Row(
              children: [
                Icon(
                  icon,
                  size: 22,
                  color: Colors.grey,
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 10),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 45, top: 0),
            child: Container(
              width: 200,
              child: Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
