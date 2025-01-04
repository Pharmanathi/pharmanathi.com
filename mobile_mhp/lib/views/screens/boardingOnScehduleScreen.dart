// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/logging.dart';

import '../../config/color_const.dart';
import '../../views/widgets/onboard_details_screen.dart';
import '../widgets/buttons.dart';

class SecondBoardingScreen extends StatefulWidget {
  final log = logger(SecondBoardingScreen);

  SecondBoardingScreen({super.key});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<SecondBoardingScreen> {
  final log = logger(SecondBoardingScreen);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.PRIMARY_COLOR,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 25, right: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pharmanathi-mhp-icon.png',
                      height: 90.h,
                    ),
                    Text(
                      'Welcome to\nPharmaNathi',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.openSans(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 253, 253, 253),
                          height: 1.1.h),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: 4.0.h,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/onboard_pic1.png',
                      height: 200.h,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.sp),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 10.h),
                    Text(
                      'Control Your\nSchedule with Ease',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.openSans(
                        fontSize: 24.sp,
                        height: 1.1.h,
                        color: Pallet.NATURAL_FAINT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 24.h),
                    Text(
                      'Easily view, schedule, and manage appointments all in one place. Customize '
                      'your availability, reduce no-shows with automatic reminders, and keep your practice '
                      'running smoothly.',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.openSans(
                        fontSize: 16.sp,
                        color: Pallet.NATURAL_FAINT,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.h),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // MyButtonWidgets(
                    //   buttonTextSecondary: 'GET STARTED',
                    //   onPressedSecondary: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => OnboardDetailsScreen(),
                    //       ),
                    //     );
                    //   },
                    //   buttonTextPrimary: 'BACK',
                    //   onPressedPrimary: () {
                    //     Navigator.pop(context);
                    //   },
                    // ).buildButtons(primaryFirst: true),
                    SecondaryButton(
                        text: "GET STARTED",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardDetailsScreen(),
                            ),
                          );
                        }),
                    SizedBox(
                      height: 12.0.h,
                    ),
                    PrimaryButtonOutline(
                        text: "BACK",
                        onPressed: () {
                          Navigator.pop(context);
                        })
                  ],
                ),
              ),
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
