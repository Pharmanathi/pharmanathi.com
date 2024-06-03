// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, sort_child_properties_last

import 'dart:math';

import 'package:client_pharmanathi/helpers/api_helpers.dart';
import 'package:client_pharmanathi/screens/components/appointments/appointment_data.dart';
import 'package:client_pharmanathi/screens/components/appointments/appointment_details_tile.dart';
import 'package:flutter/material.dart';



class ProfileCard extends StatelessWidget {
  final time;
  final name;
  final date;
  final appointmentTime;
  final imageURL;
  final status;
  final title;
  final consult_details;
  final clinic_name;
  final clinic_address;
  final String appiontmenType;

  final AppointmentData otherData;

  ProfileCard(
      {required this.otherData,
      required this.appointmentTime,
      required this.appiontmenType,
      required this.imageURL,
      required this.consult_details,
      required this.clinic_name,
      required this.clinic_address,
      required this.name,
      required this.date,
      required this.status,
      required this.title,
      required this.time});


       // Function to generate a random color
  Color getRandomColor() {
    Random random = Random();
    return Color.fromARGB(
      255,
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
    );
  }

  @override
  Widget build(BuildContext context) {
    String alteredname = ApiHelper.toTitleCase(name);

    return GestureDetector(
      onTap: () {
        // Navigate to OnlineConsultation page with corresponding data
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineConsultation(
              // Pass the corresponding data to OnlineConsultation
              title: title,
              imageURL: imageURL,
              consult_details: consult_details,
              clinic_name: clinic_name,
              clinic_address: clinic_address,
              appointmentTime: appointmentTime,
              name: name,
              date: date,
              status: status,
              time: appointmentTime,
              // Add more parameters as needed
            ),
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(top: 0, right: 10, left: 10, bottom: 0),
        child: Container(
          height: 160,
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white70,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Container(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        top: 15, bottom: 10, left: 24, right: 6),
                    child: Align(
                      alignment: Alignment.center,
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              CircleAvatar(
                                 backgroundColor: imageURL.isNotEmpty
                                  ? null // No background color if imageURL is available
                                  : getRandomColor(), // Random background color if imageURL is not available
                                child: imageURL.isNotEmpty
                                    ? Image.network(imageURL)
                                    : Text(
                                        name.isNotEmpty ? name[0] : '',
                                        style: TextStyle(
                                            fontSize: 14,
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold),
                                      ), //* Display the first letter of the name if imageURL is not available

                                     radius: 30,
                              ),
                              SizedBox(
                                width: 7,
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(10),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 30),
                                          child: SizedBox(
                                            width: 200,
                                            child: Text(
                                              'Dr.$alteredname',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(right: 70),
                                          child: Text(
                                            title,
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.normal,
                                                color: Colors.grey),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          Container(
                            width: double.infinity,
                            child: Expanded(
                              child: Divider(
                                color:Color(0xFFF7F9FC),
                                thickness: 2,
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.only(left: 0),
                                          child: Text(
                                            'Date',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                        // SizedBox(
                                        //   height: 10,
                                        // ),
                                         Padding(
                                          padding: const EdgeInsets.only(left: 0),
                                          child: Text(
                                            'Time',
                                            style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      child: Column(
                                        children: [
                                          Text(
                                            date,
                                            style: TextStyle(
                                              fontSize: 10,
                                            ),
                                          ),
                                          Text(
                                            appointmentTime,
                                            style: TextStyle(
                                              fontSize: 10,
                                              fontWeight: FontWeight.w200,
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
                                            // height: 30,
                                            // width: 100,
                                            decoration: BoxDecoration(
                                              color: status == 'Upcoming'
                                                  ? Colors.grey
                                                  : Color.fromARGB(
                                                      255, 181, 241, 212),
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.all(6),
                                              child: Text(
                                                status,
                                                style: TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.normal,
                                                  color: status == 'Upcoming'
                                                      ? Colors.white
                                                      : Colors.grey,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
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
              ),
            ],
          ),
        ),
      ),
    );
  }
}
