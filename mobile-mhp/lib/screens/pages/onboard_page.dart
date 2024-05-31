// ignore_for_file: prefer_const_constructors

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:pharma_nathi/logging.dart';
import 'package:pharma_nathi/screens/components/forms/form1.dart';
import 'package:pharma_nathi/screens/components/forms/form2.dart';
import 'package:pharma_nathi/screens/components/forms/form3.dart';
import 'package:pharma_nathi/screens/components/forms/form4.dart';
import 'package:pharma_nathi/services/onboard_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../components/UserProvider.dart';

class OnboardScreen extends StatefulWidget {
  final log = logger(OnboardScreen);
  int currentIndex;
  late List<Widget> pages;
  final GlobalKey<Form1State> form1Key;
  final GlobalKey<Form2State> form2Key;
  final GlobalKey<Form3State> form3Key;
  final GlobalKey<Form4State> form4Key;

  List<Map<String, dynamic>> formDataList = [];

  OnboardScreen({
    Key? key,
    required this.currentIndex,
    required this.form1Key,
    required this.form2Key,
    required this.form3Key,
    required this.form4Key,
  }) : super(key: key) {
    //* Initialize pages list
    pages = [
      Form1(
        key: GlobalKey<Form1State>(),
        currentIndex: currentIndex, //* Pass currentIndex to Form1
        onFormChanged: (formData) {
          addFormData(formData);
        },
      ),
      Form2(
        key: GlobalKey<Form2State>(),
        onFormChanged: (formData) {
          addFormData(formData);
        },
      ),
      Form3(
        key: GlobalKey<Form3State>(),
        onFormChanged: (formData) {
          addFormData(formData);
        },
      ),
      Form4(
        key: GlobalKey<Form4State>(),
        onFormChanged: (formData) {
          addFormData(formData);
        },
      ),
    ];
  }

  void addFormData(Map<String, dynamic> formData) {
    formDataList.add(formData);
  }

  @override
  _OnboardScreenState createState() => _OnboardScreenState();

  static Future<void> setOnboardingCompleted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('firstTime', false);
  }
}

class _OnboardScreenState extends State<OnboardScreen> {
  final log = logger(OnboardScreen);

  void updateContent(BuildContext context) {
    setState(() {
      if (widget.currentIndex < widget.pages.length - 1) {
        widget.currentIndex++;
        // Capture form data before navigating to the next page
        switch (widget.currentIndex) {
          case 1:
            // Capture form data from Form1
            final formData = widget.form1Key.currentState?.getFormData();
            if (formData != null) {
              widget.formDataList.add(formData);
              log.i('Form 1 Data:');
              log.i(formData);
            }
            break;
          case 2:
            // Capture form data from Form2
            final formData = widget.form2Key.currentState?.getFormData();
            if (formData != null) {
              widget.formDataList.add(formData);
              log.i('Form 2 Data:');
              log.i(formData);
            }
            break;
          case 3:
            // Capture form data from Form3
            final formData = widget.form3Key.currentState?.getFormData();
            if (formData != null) {
              widget.formDataList.add(formData);
              log.i('Form 3 Data:');
              log.i(formData);
            }
            break;
          case 4:
            // Capture form data from Form4
            final formData = widget.form4Key.currentState?.getFormData();
            if (formData != null) {
              widget.formDataList.add(formData);
              log.i('Form 4 Data:');
              log.i(formData);
            }
            break;
        }
      } else {
        // Existing code for sending form data to API
        sendFormDataToAPI(context);
      }
    });

    // Schedule a callback to log "Content updated" after the frame has finished rendering
    WidgetsBinding.instance.addPostFrameCallback((_) {
      log.i('Content updated, currentIndex: ${widget.currentIndex}');
    });
  }

  void sendFormDataToAPI(context) {
    // Check if any form data is null
    if (widget.formDataList.any((formData) => formData.containsValue(null))) {
      log.e('Form data is incomplete');
      return;
    }

    // Separate data by forms
    List<Map<String, dynamic>> form1Data = [];
    List<Map<String, dynamic>> form2Data = [];
    List<Map<String, dynamic>> form3Data = [];
    List<Map<String, dynamic>> form4Data = [];

    for (var formData in widget.formDataList) {
      // Print out the keys present in the formData map
      log.i('Keys in formData: ${formData.keys}');

      if (formData.containsKey('selectedTitle')) {
        form1Data.add(formData);
      } else if (formData.containsKey('email')) {
        form2Data.add(formData);
      } else if (formData.containsKey('universities')) {
        form3Data.add(formData);
      } else if (formData.containsKey('spcaNumber')) {
        form4Data.add(formData);
      }
    }

    // Call API to send form data to backend
    APIService.sendFormData(widget.formDataList, context);

    // Log data for each form
    log.d('Sending data to backend (Form 1): ${jsonEncode(form1Data)}');
    log.d('Sending data to backend (Form 2): ${jsonEncode(form2Data)}');
    log.d('Sending data to backend (Form 3): ${jsonEncode(form3Data)}');
    log.d('Sending data to backend (Form 4): ${jsonEncode(form4Data)}');

    // Set onboarding completed and navigate to home page
    OnboardScreen.setOnboardingCompleted();
    Navigator.pushReplacementNamed(context, '/home_page');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
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
                  'assets/images/Logo.png',
                  color: Colors.white,
                  width: 50,
                  height: 50,
                ),
                Text(
                  'PHARMA',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                Text(
                  'NATHI',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              width: double.infinity,
              color: Color(0xFFFFFFFF),
              child: Padding(
                padding: const EdgeInsets.all(25.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    widget.pages[widget.currentIndex],
                    SizedBox(
                      height: 50,
                    ),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          updateContent(context);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF6F7ED7),
                          minimumSize: Size(320, 50),
                        ),
                        child: Text(
                          'NEXT',
                          style: TextStyle(
                            color: Color(0xFFFFFFFF),
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
