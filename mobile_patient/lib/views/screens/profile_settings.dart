// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_build_context_synchronously

import 'package:patient/blocs/sign_in_bloc.dart';
import 'package:patient/config/color_const.dart';
import 'package:patient/routes/app_routes.dart';
import 'package:patient/views/widgets/buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../helpers/api_helpers.dart';
import '../../screens/components/UserProvider.dart';
import '../widgets/navigation_bar.dart';

class ProfileSetting extends StatefulWidget {
  const ProfileSetting({super.key});

  @override
  State<ProfileSetting> createState() => _ProfileSettingState();
}

class _ProfileSettingState extends State<ProfileSetting> {
  int _selectedIndex = 2;

  // Method to handle navigation
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

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
                    context, AppRoutes.signIn, (route) => false);
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

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final String email = '${userProvider.email}';
    final googleSignInBloc =
        Provider.of<GoogleSignInBloc>(context, listen: false);
    String alteredname = ApiHelper.toTitleCase('${userProvider.name}');

    return Scaffold(
      backgroundColor: Pallet.PURE_WHITE,
      body: Stack(
        children: [
          Column(
            children: [
              Container(
                width: double.infinity.sp,
                height: 290.h,
                color: Color(0xFF6F7ED7),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(
                              top: 60, left: 90, right: 60, bottom: 60),
                          child: Text(
                            'Profile Settings',
                            style: GoogleFonts.openSans(
                              fontSize: 25.sp,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                color: Pallet.PURE_WHITE,
                height: 300.h,
              ),
            ],
          ),
          Positioned(
            top: 110.sp,
            left: 30.sp,
            right: 30.sp,
            bottom: 3.sp,
            child: Container(
              color: Pallet.BACKGROUND_COLOR,
              height: 100.sp,
              child: Padding(
                padding: const EdgeInsets.all(35.0),
                child: Column(
                  children: [
                    // Profile picture and details
                    Container(
                      child: Column(
                        children: [
                          CircleAvatar(
                            backgroundImage:
                                NetworkImage(userProvider.picture ?? ''),
                            radius: 80.sp,
                          ),
                          // Doctor's name
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              alteredname,
                              style: GoogleFonts.openSans(
                                color: Colors.black,
                                fontSize: 20.0.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          // Profession
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Text(
                              email,
                              style: GoogleFonts.openSans(
                                color: Colors.grey,
                                fontSize: 15.0.sp,
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    buildDivider(),

                    // // Account settings
                    // GestureDetector(
                    //   onTap: () async {},
                    //   child: Container(
                    //     child: buildSectionTile(
                    //         'Account settings', Icons.border_color),
                    //   ),
                    // ),
                    // buildDivider(),

                    // // Notifications
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle notifications
                    //   },
                    //   child: Container(
                    //     child: buildSectionTile(
                    //         'Notification', Icons.notifications),
                    //   ),
                    // ),
                    // buildDivider(),

                    // // Support
                    // GestureDetector(
                    //   onTap: () {
                    //     // Handle support
                    //   },
                    //   child: Container(
                    //     child: buildSectionTile('Support', Icons.help),
                    //   ),
                    // ),
                    // buildDivider(),

                    // Log out
                    GestureDetector(
                      onTap: () {
                        _showModal(context, googleSignInBloc);
                      },
                      child: Container(
                        child: buildSectionTile('Logout', Icons.logout),
                      ),
                    ),
                    buildDivider(),
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

  Widget buildSectionTile(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(top: 10, bottom: 5),
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
                  icon,
                  color: Color(0xFF6F7ED7),
                ),
              ),
              SizedBox(
                width: 15.sp,
              ),
              Text(
                title,
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
                Icons.arrow_forward_ios,
                size: 12.0.sp,
                color: Color(0xFF6F7ED7),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget buildDivider() {
    return Container(
      width: 500.w,
      child: Divider(
        color: Colors.grey,
        thickness: 0.5.sp,
      ),
    );
  }
}
