// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/views/screens/boardingOnScehduleScreen.dart';

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
                padding: const EdgeInsets.only(top: 30, left: 25, right: 25),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/pharmanathi-mhp-icon.png',
                      height: 100,
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 253, 253, 253),
                      ),
                    ),
                    Text(
                      'PharmaNathi',
                      style: TextStyle(
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                        color: Color.fromARGB(255, 247, 247, 251),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/nodata.png',
                      height: 200,
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 25.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    SizedBox(height: 10),
                    Text(
                      'Streamline Your \nPractice',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 17,
                        color: Pallet.NATURAL_FAINT,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'Welcome to PharmaNathi, where managing'
                      ' your appointments has never been easier.\n'
                      'Simplify your schedule, connect with patients,\n'
                      'and enhance your practice\'s efficiency.\n'
                      'Let\'s get started!',
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontSize: 14,
                        color: Pallet.NATURAL_FAINT,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.all(25.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    MyButtonWidgets(
                      buttonTextSecondary: 'NEXT',
                      onPressedSecondary: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => SecondBoardingScreen(),
                          ),
                        );
                      },
                      buttonTextPrimary: 'SKIP',
                      onPressedPrimary: () {
                         skipOnboarding(context);
                      },
                    ).buildButtons(primaryFirst: true),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
