// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_super_parameters, use_build_context_synchronously

import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/blocs/sign_in_bloc.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/routes/app_routes.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/views/screens/account.dart';
import 'package:pharma_nathi/views/screens/manage_appointment.dart';
import 'package:pharma_nathi/screens/pages/working_hours.dart';
import 'package:pharma_nathi/views/widgets/buttons.dart';
import 'package:pharma_nathi/views/widgets/navigationbar.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/image_data.dart';

class MyProfile extends StatefulWidget {
  const MyProfile(
      {Key? key, required Null Function(dynamic newImage) onImageChanged})
      : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  int _selectedIndex = 3;

  //* method with modal for logging out
  void _showModal(BuildContext context, GoogleSignInBloc googleSignInBloc) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(15.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Padding(
                  padding: const EdgeInsets.all(35.0),
                  child: Icon(
                    Icons.warning,
                    size: 48,
                    color: Colors.red,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Log Out?',
                  style: GoogleFonts.openSans(
                    fontSize: 25.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text('Are you sure you want to log out?'),
              ],
            ),
          ),
          actions: <Widget>[
            MyButtonWidgets(
              buttonTextPrimary: 'Log out',
              onPressedPrimary: () async {
                await googleSignInBloc.signOut();
                Navigator.of(context).pop();
                Navigator.pushNamedAndRemoveUntil(
                    context,AppRoutes.signIn, (route) => false);
              },
              buttonTextSecondary: 'Cancel',
              onPressedSecondary: () {
                Navigator.of(context).pop();
              },
            ).buildButtons(primaryFirst: true),
          ],
        );
      },
    );
  }

  //method to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final googleSignInBloc =
        Provider.of<GoogleSignInBloc>(context, listen: false);
    final imageProvider = Provider.of<ImageDataProvider>(context);
    final userProvider = Provider.of<UserProvider>(context);
    final specialities = userProvider.user?.doctorProfile?.specialities;

    String profession = 'Not Specified';
    if (specialities != null && specialities.isNotEmpty) {
      profession = specialities[0].name;
    }
    //* Truncate the profession string if it's too long
    const maxCharacters = 25;
    if (profession.length > maxCharacters) {
      profession = '${profession.substring(0, maxCharacters)}...';
    }

    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity,
                height: 200.h,
                color: Color(0xFF6F7ED7),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(80),
                      child: Text(
                        'Profile',
                        style: GoogleFonts.openSans(
                          fontSize: 25.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                color: Colors.white,
                height: 300.h,
              ),
            ],
          ),
          Positioned(
            top: 140.sp,
            left: 30.sp,
            right: 30.sp,
            bottom: 2.sp,
            child: Container(
              color: Color(0xFFF7F9FC),
              height: 100.h,
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  children: [
                    //profile picture and details
                    Row(
                      children: [
                        CircleAvatar(
                          backgroundImage:
                              NetworkImage(userProvider.picture ?? ''),
                          // backgroundImage: imageProvider.imageFile != null
                          //     ? FileImage(imageProvider.imageFile!)
                          //     : AssetImage('assets/images/sample.JPG')
                          //         as ImageProvider,
                          radius: 30.sp,
                        ),
                        SizedBox(width: 20.w),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 170.w,
                              child: Text(
                                'Dr. ${userProvider.user?.firstName} ${userProvider.user?.lastName}',
                                style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                profession,
                                style: GoogleFonts.openSans(
                                  fontSize: 14.sp,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20.h,
                    ),
                    SizedBox(
                      width: 560.w, //TODO:[Thabang] this is weird, need to find out why
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5.sp,
                      ),
                    ),
                    //account information...........
                    GestureDetector(
                      onTap: () async {
                        // Navigate to EditAccount and wait for the result
                        final newImage = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditAccount(
                              imageFile: imageProvider.imageFile,
                              onImageChanged: (newImage) {
                                // Update the image if the user picked a new one
                                if (newImage != null) {
                                  imageProvider.updateImageFile(newImage);
                                }
                              },
                            ),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(69, 173, 182, 241),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.person,
                                    color: Color(0xFF6F7ED7),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  'Account Information',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF6F7ED7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5.sp,
                      ),
                    ),
                    //Education.............................
                    GestureDetector(
                      onTap: () {
                        //handle
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(69, 173, 182, 241),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.cast_for_education_sharp,
                                    color: Color(0xFF6F7ED7),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  'Education',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF6F7ED7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5.sp,
                      ),
                    ),
                    //Profesional information....................
                    GestureDetector(
                      onTap: () {
                        //handle
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(69, 173, 182, 241),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.info,
                                    color: Color(0xFF6F7ED7),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  'Profesional Information',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF6F7ED7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5.sp,
                      ),
                    ),
                    //Manage Schedule.............................
                    GestureDetector(
                      onTap: () {
                        // Show a dialog with two options
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              // title: Text('Choose an option'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to the first page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                WorkingHours()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF6F7ED7),
                                      minimumSize: Size(320.sp, 50.sp),
                                    ),
                                    child: Text('Working Hours',
                                    style: GoogleFonts.openSans(color: Pallet.PURE_WHITE),),
                                  ),
                                  SizedBox(
                                    height: 10.h,
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      // Navigate to the second page
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ManageAppointment()),
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF6F7ED7),
                                      minimumSize: Size(320.sp, 50.sp),
                                      shadowColor: Colors.transparent,
                                      side: BorderSide(
                                        color: Color(0xFF6F7ED7),
                                        width: 1.w,
                                      ),
                                    ),
                                    child: Text('Manage Appointments',
                                     style: GoogleFonts.openSans(color: Pallet.PURE_WHITE),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(69, 173, 182, 241),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.cast_for_education_sharp,
                                    color: Color(0xFF6F7ED7),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  'Manage Schedule',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF6F7ED7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),

                    // //settings.......................
                    // GestureDetector(
                    //   onTap: () {
                    //     //handle
                    //   },
                    //   child: Container(
                    //     child: Padding(
                    //       padding: const EdgeInsets.only(top: 15, bottom: 10),
                    //       child: Row(
                    //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    //         children: [
                    //           Row(
                    //             children: [
                    //               Container(
                    //                 decoration: BoxDecoration(
                    //                   color: Color.fromARGB(69, 173, 182, 241),
                    //                   shape: BoxShape.rectangle,
                    //                   borderRadius: BorderRadius.circular(8.0),
                    //                 ),
                    //                 padding: EdgeInsets.all(10),
                    //                 child: Icon(
                    //                   Icons.settings,
                    //                   color: Color(0xFF6F7ED7),
                    //                 ),
                    //               ),
                    //               SizedBox(
                    //                 width: 15,
                    //               ),
                    //               Text(
                    //                 'Settings',
                    //                 style: TextStyle(
                    //                   fontSize: 15,
                    //                   fontWeight: FontWeight.w500,
                    //                 ),
                    //               ),
                    //             ],
                    //           ),
                    //           Row(
                    //             children: [
                    //               Icon(
                    //                 Icons.arrow_forward,
                    //                 color: Color(0xFF6F7ED7),
                    //               ),
                    //             ],
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ),
                    // ),
                    SizedBox(
                      width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5.sp,
                      ),
                    ),
                    //log out........................
                    GestureDetector(
                      onTap: () {
                        _showModal(context, googleSignInBloc);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(top: 15, bottom: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    color: Color.fromARGB(69, 173, 182, 241),
                                    shape: BoxShape.rectangle,
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  padding: EdgeInsets.all(10),
                                  child: Icon(
                                    Icons.logout,
                                    color: Color(0xFF6F7ED7),
                                  ),
                                ),
                                SizedBox(
                                  width: 15.w,
                                ),
                                Text(
                                  'Log out',
                                  style: GoogleFonts.openSans(
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Row(
                              children: [
                                Icon(
                                  Icons.arrow_forward,
                                  color: Color(0xFF6F7ED7),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(
                      width: 500.w, //TODO:[Thabang] this is weird, need to find out why
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: CustomBottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
