// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, library_private_types_in_public_api, prefer_const_constructors_in_immutables, must_be_immutable, use_super_parameters

import 'package:patient/config/color_const.dart';
import 'package:patient/routes/app_routes.dart';
import 'package:patient/views/widgets/buttons.dart';
import 'package:patient/screens/components/text_and_heading.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardScreen extends StatefulWidget {
  int currentIndex;
  final List<String> headings;
  final List<String> texts;

  // Sample onboarding texts
  static const List<String> sampleHeadings = [
    'Welcome to \nPharma Nathi',
    'Schedule \nAppointments',
    'Receive Timely \nReminders',
    'Personalized \nHealthcare',
  ];

  static const List<String> sampleTexts = [
    'Experience hassle-free healthcare with PharmaNathi.\n \nEasily book, manage, and stay updated on your doctors appointments \n \nYour health journey starts here!',
    'Say goodbye to long queues and phone calls. \n \nWith PharmaNathi, booking appointments is a breeze.\n \nChoose your preferred doctor, select a convenient time, and manage your health on your terms',
    'Never miss an appointment again.\n \nOur app keeps you informed with timely reminders, ensuring you are always prepared for your upcoming healthcare appointments.\n \nYour health, our priority',
    'PharmaNathi puts you in control of your health.\n \nEnjoy unlimited access to your health records, prescription renewals, and more.\n \nYour journey to better health starts now.',
  ];

  OnboardScreen({
    Key? key,
    required this.currentIndex,
    required this.headings,
    required this.texts,
  })  : assert(headings.length == texts.length,
            'Headings and texts must have the same length'),
        super(key: key);

  void handleOnboardingCompletion(BuildContext context) {
    Navigator.pushNamed(context, AppRoutes.appointments);
  }

// New method to check if it's the first time opening the app
  static Future<bool> isFirstTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('firstTime') ?? true;
  }

  // New method to mark that the onboarding has been completed
  static Future<void> setOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);
  }

  OnboardScreen.initial({
    Key? key,
  })  : currentIndex = 0,
        headings = const [],
        texts = const [],
        super(key: key);

  @override
  _OnboardScreenState createState() => _OnboardScreenState();
}

class _OnboardScreenState extends State<OnboardScreen> {
  void updateContent(BuildContext context) {
    setState(() {
      if (widget.currentIndex < 3) {
        widget.currentIndex++;
      } else {
        // Update the onboarding completion status
        OnboardScreen.setOnboardingCompleted();

        // Navigate to the home_page
        Navigator.pushNamed(context, AppRoutes.appointments);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Pallet.PURE_WHITE,
      body: Column(
        children: [
          // 1st container for the logo
          Container(
            height: 200,
            width: double.infinity,
            color: Color(0xFF6F7ED7),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 25,
                ),
                Image.asset(
                  'assets/images/onbaording-logo.png',
                  color: Colors.white,
                  // height: 100,
                ),
              ],
            ),
          ),

          // 2nd container for content
          SizedBox(height: 30,),
          Flexible(
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                color: Color(0xFFFFFFFF),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          if (widget.currentIndex < widget.headings.length)
                            TextAndHeadingComponents.buildHeading(
                                widget.headings[widget.currentIndex]),
                        ],
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Column(
                        children: [
                          if (widget.currentIndex < widget.texts.length)
                            TextAndHeadingComponents.buildText(
                                widget.texts[widget.currentIndex]),
                        ],
                      ),
                      SizedBox(
                        height: 60,
                      ),
                      Center(
                        child: MyButtonWidgets(
                          buttonTextSecondary: 'Skip',
                          onPressedSecondary: () {
                             widget.handleOnboardingCompletion(context);
                          },
                          buttonTextPrimary: 'Next',
                          onPressedPrimary: () {
                             updateContent(context);
                          },
                        ).buildButtons(primaryFirst: false),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
