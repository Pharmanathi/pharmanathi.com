// ignore_for_file: prefer_typing_uninitialized_variables, sort_child_properties_last

import 'dart:math';

import 'package:client_pharmanathi/config/color_const.dart';
import 'package:client_pharmanathi/model/doctor_data.dart';
import 'package:client_pharmanathi/screens/components/UserProvider.dart';
import 'package:client_pharmanathi/views/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'bookings.dart';

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
      backgroundColor: Pallet.PURE_WHITE,
      body: Center(
        child: Column(
          children: [
            const HeaderWidget(
              text: 'Doctor Profile',
              showBackButton: true,
            ),
            // ignore: prefer_const_constructors
            SizedBox(height: 20,),
            //* Container for video icon and text icon
            Container(
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        backgroundColor: widget.doctor.imageURL.isNotEmpty
                            ? null
                            : getRandomColor(), // Random background if no image
                        child: widget.doctor.imageURL.isNotEmpty
                            ? ClipOval(
                                child: Image.network(
                                  widget.doctor.imageURL,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              )
                            : Text(
                                widget.doctor.doctorFullName.isNotEmpty
                                    ? widget.doctor.doctorFullName[0]
                                    : '',
                                style: const TextStyle(
                                    fontSize: 50,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        radius: 50,
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  // Doctor's name
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      'Dr ${widget.doctor.doctorFullName}',
                      style: const TextStyle(
                        color: Colors.black,
                        fontSize: 22.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    widget.doctor.getAllSpecialityNames(),
                    style: const TextStyle(
                      color: Pallet.NEUTRAL_200,
                      fontSize: 15.0,
                      fontStyle: FontStyle.normal
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      const Text(
                        'Consultation fee',
                        style: TextStyle(
                          color: Colors.black,
                          fontSize: 11.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R ${widget.doctor.appointmentType?.cost ?? 'N/A'}',
                        style: const TextStyle(
                          color: Pallet.NEUTRAL_200,
                          fontSize: 16.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 25),
                Container(
                  height: 32,
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
                      backgroundColor: const Color(0xFF6F7ED7),
                      padding:
                          const EdgeInsets.symmetric(horizontal: 15.0, vertical: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      "Book Appointment",
                      style: TextStyle(
                        color: Pallet.PURE_WHITE,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.normal
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 35),
            Expanded(
              child: Container(
                width: double.infinity,
                color: Pallet.BACKGROUND_COLOR,
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildSectionTile('Experience and Qualifications',
                            Icons.military_tech_outlined),
                        const SizedBox(height: 10),
                        buildSectionTile('Working Address', Icons.location_pin),
                      ],
                    ),
                  ),
                ),
              ),
            ),
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
            color: Pallet.PRIMARY_COLOR,
          ),
        ),
        const SizedBox(width: 2),
        Expanded(
          child: Container(
            height: 60,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Pallet.BLACK,
                      fontWeight: FontWeight.normal,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios,
                    size: 12.0,
                    color: Pallet.NEUTRAL_200,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
