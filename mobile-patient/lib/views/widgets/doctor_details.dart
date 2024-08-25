// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, sort_child_properties_last

import 'dart:math';

import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:client_pharmanathi/screens/components/UserProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../screens/bookings.dart';

class DoctorDetails extends StatefulWidget {
   final Doctor doctor;

  const DoctorDetails({
    Key? key,
    required this.doctor,
  }) : super(key: key);

  @override
  State<DoctorDetails> createState() => _DoctorDetailsState();
}

//* Function to generate a random color
Color getRandomColor() {
  Random random = Random();
  return Color.fromARGB(
    255,
    random.nextInt(256),
    random.nextInt(256),
    random.nextInt(256),
  );
}

class _DoctorDetailsState extends State<DoctorDetails> {
  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    userProvider.setDoctorId(widget.doctor.id);

    return Scaffold(
      body: Center(
        child: Column(
          children: [
            //  header container
            Container(
              width: double.infinity,
              height: 130,
              color: const Color(0xFF6F7ED7),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 70, right: 110),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(right: 50),
                          child: GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                          ),
                        ),
                        const Text(
                          'Doctor Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            //container for video icon and text icon
            Container(
                // height: 80,
                // color: Colors.grey[100],
                // child: Padding(
                //   padding: const EdgeInsets.all(20.0),
                //   child: Row(
                //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //     children: [
                //       Row(
                //         children: [
                //           Icon(
                //             Icons.videocam,
                //             color: Colors.blue,
                //           ),
                //           SizedBox(
                //             width: 10,
                //           ),
                //           Text(
                //             'Video Call',
                //             style: TextStyle(
                //               color: Colors.blue,
                //               fontSize: 12.0,
                //               fontWeight: FontWeight.bold,
                //             ),
                //           ),
                //         ],
                //       ),
                //       Container(
                //         color: const Color.fromARGB(255, 203, 230, 253),
                //         // decoration: BoxDecoration(),
                //         child: Padding(
                //           padding: const EdgeInsets.all(5.0),
                //           child: Icon(
                //             Icons.message,
                //             color: Colors.blue,
                //           ),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
                ),
            Container(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.doctor.imageURL.isNotEmpty
                            ? null // No background color if imageUrl is available
                            : getRandomColor(), // Random background color if imageUrl is not available
                        child:  widget.doctor.imageURL.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                 widget.doctor.imageURL,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Text(
                                widget.doctor.doctorFullName.isNotEmpty ? widget.doctor.doctorFullName[0] : '',
                                style: TextStyle(
                                    fontSize: 50,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ), //* Display the first letter of the name if imageUrl is not available
                        radius: 80,
                      ),
                      // Positioned(
                      //   right: 20,
                      //   bottom: 10,
                      //   child: Container(
                      //     width: 12,
                      //     height: 20,
                      //     decoration: BoxDecoration(
                      //       shape: BoxShape.circle,
                      //       color: widget.status == 'online'
                      //           ? Colors.green
                      //           : Colors.grey,
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                  //doctor's name
                  Padding(
                    padding: const EdgeInsets.all(5.0),
                    child: Text(
                      widget.doctor.doctorFullName,
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 20.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  //profission
                  // Padding(
                  //   padding: const EdgeInsets.all(5.0),
                  //   child: Text(
                  //     widget.title,
                  //     style: TextStyle(
                  //       color: Colors.grey,
                  //       fontSize: 15.0,
                  //       fontWeight: FontWeight.normal,
                  //     ),
                  //   ),
                  // ),
                  //ratings
                  Padding(
                    padding: const EdgeInsets.only(left: 190),
                    child: Row(
                      children: [
                        // Icon(
                        //   Icons.star,
                        //   color: Colors.blue,
                        //   size: 17,
                        // ),
                        SizedBox(
                          width: 5,
                        ),
                        // Text(
                        //   widget.rating,
                        //   style: TextStyle(
                        //     color: Colors.grey,
                        //     fontSize: 15.0,
                        //     fontWeight: FontWeight.normal,
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Container(
              child: Padding(
                padding: const EdgeInsets.only(top: 25, left: 50),
                child: Row(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.location_pin,
                          color: Colors.blue,
                        ),
                        Column(
                          children: [
                            Text(
                              'Location',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 15.0,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                            // Container(
                            //   width: 100,
                            //   child: Text(
                            //     widget.doctor.,
                            //     style: TextStyle(
                            //       color: Colors.grey,
                            //       fontSize: 15.0,
                            //       fontWeight: FontWeight.normal,
                            //     ),
                            //   ),
                            // ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Container(
                      height: 50,
                      width: 1,
                      color: Colors.grey[200],
                      margin: EdgeInsets.symmetric(horizontal: 10),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          Icon(
                            Icons.star,
                            color: Colors.blue,
                          ),
                          Column(
                            children: [
                              Text(
                                'Expperience',
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 15.0,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                              // Text(
                              //   widget.experience,
                              //   style: TextStyle(
                              //     color: Colors.grey,
                              //     fontSize: 15.0,
                              //     fontWeight: FontWeight.normal,
                              //   ),
                              // ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Divider(height: 0.5, color: Colors.grey[200]),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Navigate to the booking  page
                    var selectedDay;
                    var _selectedTimeSlots;
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Bookings(
                            doctor: widget.doctor,
                            selectedTimeSlots:
                                _selectedTimeSlots ?? ValueNotifier([]),
                            selectedDay: selectedDay ?? DateTime.now(),
                          ),
                        ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6F7ED7),
                    padding:
                        EdgeInsets.symmetric(horizontal: 50.0, vertical: 15.0),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.0),
                    ),
                    elevation: 0,
                    textStyle: TextStyle(
                      fontSize: 16.0,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  child: Text(
                    "Book Appointment",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                height: 270,
                color: Colors.grey[200],
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          //valid insurances
                          // Container(
                          //     child: buildSectionTile(
                          //         'Valid Insurances', Icons.business_center)),
                          SizedBox(height: 10),
                          //experiance an qualifications
                          Container(
                              child: buildSectionTile(
                                  'Experiance an Qualification',
                                  Icons.military_tech_outlined)),
                          // SizedBox(height: 10),
                          //personal information
                          // Container(
                          //     child: buildSectionTile(
                          //         'Personal Information', Icons.person_2)),
                          // SizedBox(height: 10),
                          //reviews
                          // Container(
                          //     child: buildSectionTile('Reviews', Icons.star)),
                          SizedBox(height: 10),
                          //working address
                          Container(
                              child: buildSectionTile(
                                  'Working Address', Icons.location_pin)),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSectionTile(String title, IconData icon) {
    return Row(
      children: [
        Container(
          height: 60,
          width: 60,
          color: Colors.white,
          child: Icon(
            icon,
            color: Colors.blue,
          ),
        ),
        SizedBox(
          width: 2,
        ),
        Container(
          height: 60,
          color: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  width: 225,
                  child: Text(
                    title,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(left: 17),
                  child: Icon(
                    Icons.arrow_forward_ios,
                    size: 12.0,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ),
        )
      ],
    );
  }
}
