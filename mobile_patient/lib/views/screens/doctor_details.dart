// ignore_for_file: prefer_typing_uninitialized_variables, sort_child_properties_last

import 'dart:math';

import 'package:patient/config/color_const.dart';
import 'package:patient/model/doctor_data.dart';
import 'package:patient/screens/components/UserProvider.dart';
import 'package:patient/views/widgets/HeaderWidget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
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
              text: "Doctor's Profile",
              showBackButton: true,
            ),
            // ignore: prefer_const_constructors
            Container(
              height: 10.h,
              color: Pallet.BACKGROUND_COLOR,
              // color: const Color.fromARGB(255, 22, 76, 156),
              // child: const SizedBox(height: 20,),
            ),
            SizedBox(
              height: 20.h,
            ),
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
                                style: GoogleFonts.openSans(
                                    fontSize: 50.sp,
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold),
                              ),
                        radius: 40.sp,
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  // Doctor's name
                  Padding(
                    padding: const EdgeInsets.all(2.0),
                    child: Text(
                      'Dr ${widget.doctor.doctorFullName}',
                      style: GoogleFonts.openSans(
                        color: Colors.black,
                        fontSize: 22.0.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Text(
                    widget.doctor.getAllSpecialityNames(),
                    style: GoogleFonts.openSans(
                        color: Pallet.NEUTRAL_200,
                        fontSize: 15.0.sp,
                        fontStyle: FontStyle.normal),
                  ),
                ],
              ),
            ),
            SizedBox(height: 30.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Consultation fee',
                        style: GoogleFonts.openSans(
                          color: Colors.black,
                          fontSize: 11.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'R ${widget.doctor.appointmentType?.cost ?? 'N/A'}',
                        style: GoogleFonts.openSans(
                          color: Pallet.NEUTRAL_200,
                          fontSize: 14.0.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 25.w),
                Container(
                  height: 32.h,
                  child: ElevatedButton(
                    onPressed: () {
                      // Navigate to the booking  page
                      var selectedDay;
                      var selectedTimeSlots;
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => Bookings(
                              doctor: widget.doctor,
                              selectedTimeSlots:
                                  selectedTimeSlots ?? ValueNotifier([]),
                              selectedDay: selectedDay ?? DateTime.now(),
                            ),
                          ));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor:  Pallet.PRIMARY_650,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 2.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Book Appointment",
                      style: GoogleFonts.openSans(
                          color: Pallet.PURE_WHITE,
                          fontSize: 14.sp,
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.normal),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 35.h),
            Expanded(
              child: Container(
                width: double.infinity.sp,
                color: Pallet.BACKGROUND_COLOR,
                child: Padding(
                  padding: const EdgeInsets.only(top: 25.0,left: 15,right: 15),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        buildSectionTile('Experience and Qualifications',
                            Icons.military_tech_outlined),
                        SizedBox(height: 10.h),
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
          height: 60.h,
          width: 60.w,
          color: Colors.white,
          child: Icon(
            icon,
            color: Pallet.PRIMARY_COLOR,
          ),
        ),
        SizedBox(width: 2.w),
        Expanded(
          child: Container(
            height: 60.h,
            color: Colors.white,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.openSans(
                        color: Pallet.BLACK,
                        fontWeight: FontWeight.normal,
                        fontStyle: FontStyle.normal,
                        fontSize: 15.sp),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 12.0.sp,
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
