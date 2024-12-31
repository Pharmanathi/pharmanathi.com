// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/views/screens/boardingOnScehduleScreen.dart';
import 'package:pharma_nathi/views/widgets/onboard_details_screen.dart';

import '../widgets/buttons.dart';

class OnboardScreen extends StatefulWidget {
  final log = logger(OnboardScreen);

  OnboardScreen({super.key});

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  final log = logger(OnboardScreen);

  void skipOnboarding(BuildContext context) {
    Navigator.pushNamed(context, '/home_page');
  }

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
                      height: 100.h,
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
                    // Text(
                    //   'PharmaNathi',
                    //   style: GoogleFonts.openSans(
                    //     fontSize: 32.sp,
                    //     fontWeight: FontWeight.bold,
                    //     color: Color.fromARGB(255, 247, 247, 251),
                    //   ),
                    // ),
                  ],
                ),
              ),
              SizedBox(
                height: 5.0.h,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/onboard_appointments.png',
                      height: 225.86.h,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20.sp),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // SizedBox(height: 10.h),
                    Text(
                      'Streamline Your \nPractice',
                      textAlign: TextAlign.left,
                      style: GoogleFonts.openSans(
                          fontSize: 24.sp,
                          color: Pallet.NATURAL_FAINT,
                          fontWeight: FontWeight.bold,
                          height: 1.1.h),
                    ),
                    SizedBox(height: 24.h),
                    RichText(
                        text: TextSpan(
                            style: GoogleFonts.openSans(
                              fontSize: 16.sp,
                              color: Pallet.NATURAL_FAINT,
                              fontWeight: FontWeight.normal,
                            ),
                            children: <TextSpan>[
                          TextSpan(
                              text: 'Welcome to PharmaNathi, where managing'
                                  ' your appointments has never been easier.\n'),
                          TextSpan(
                              text:
                                  'Simplify your schedule, connect with patients,'
                                  ' and enhance your practice\'s efficiency.\n'),
                          TextSpan(
                              text: 'Let\'s get started!',
                              style: GoogleFonts.openSans(
                                  fontWeight: FontWeight.bold))
                        ])),
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
                    //   buttonTextSecondary: 'NEXT',
                    //   onPressedSecondary: () {
                    //     Navigator.push(
                    //       context,
                    //       MaterialPageRoute(
                    //         builder: (context) => SecondBoardingScreen(),
                    //       ),
                    //     );
                    //   },
                    //   buttonTextPrimary: "SKIP",
                    // ).buildButtons(primaryFirst: true),
                    SecondaryButton(
                        text: "NEXT",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => SecondBoardingScreen(),
                            ),
                          );
                        }),
                    SizedBox(
                      height: 12.0.h,
                    ),
                    PrimaryButtonOutline(
                        text: "SKIP",
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => OnboardDetailsScreen(),
                            ),
                          );
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
