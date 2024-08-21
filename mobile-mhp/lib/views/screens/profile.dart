// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, use_super_parameters, use_build_context_synchronously

import 'package:pharma_nathi/blocs/sign_in_bloc.dart';
import 'package:pharma_nathi/routes/app_routes.dart';
import 'package:pharma_nathi/screens/components/UserProvider.dart';
import 'package:pharma_nathi/views/screens/manage_appointment.dart';
import 'package:pharma_nathi/screens/pages/working_hours.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/image_data.dart';
import '../widgets/buttons.dart';
import '../widgets/navigationbar.dart';
import 'account.dart';
import 'package:google_sign_in/google_sign_in.dart';

class MyProfile extends StatefulWidget {
  const MyProfile(
      {Key? key, required Null Function(dynamic newImage) onImageChanged})
      : super(key: key);

  @override
  State<MyProfile> createState() => _MyProfileState();
}

class _MyProfileState extends State<MyProfile> {
  int _selectedIndex = 3;

  // method with modal for logging out
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
                  style: TextStyle(
                    fontSize: 25,
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
                height: 200,
                color: Color(0xFF6F7ED7),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(80),
                      child: Text(
                        'Profile',
                        style: TextStyle(
                          fontSize: 25,
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
                height: 300,
              ),
            ],
          ),
          Positioned(
            top: 140,
            left: 30,
            right: 30,
            bottom: 2,
            child: Container(
              color: Color(0xFFF7F9FC),
              height: 100,
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
                          radius: 30,
                        ),
                        SizedBox(width: 20),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 170,
                              child: Text(
                                'Dr. ${userProvider.user?.firstName} ${userProvider.user?.lastName}',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.only(top: 5),
                              child: Text(
                                profession,
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 560,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
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
                                  width: 15,
                                ),
                                Text(
                                  'Account Information',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                      width: 500,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
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
                                  width: 15,
                                ),
                                Text(
                                  'Education',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                      width: 500,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
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
                                  width: 15,
                                ),
                                Text(
                                  'Profesional Information',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                      width: 500,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
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
                                      minimumSize: Size(320, 50),
                                    ),
                                    child: Text('Working Hours'),
                                  ),
                                  SizedBox(
                                    height: 10,
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
                                      minimumSize: Size(320, 50),
                                      shadowColor: Colors.transparent,
                                      side: BorderSide(
                                        color: Color(0xFF6F7ED7),
                                        width: 1,
                                      ),
                                    ),
                                    child: Text('Manage Appointments'),
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
                                  width: 15,
                                ),
                                Text(
                                  'Manage Schedule',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                      width: 500,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
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
                                  width: 15,
                                ),
                                Text(
                                  'Log Out',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w500,
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
                      width: 500,
                      child: Divider(
                        color: Colors.grey,
                        thickness: 0.5,
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
