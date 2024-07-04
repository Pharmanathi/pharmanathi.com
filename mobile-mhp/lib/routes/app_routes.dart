// lib/src/routes/app_routes.dart

import 'package:flutter/material.dart';
import 'package:pharma_nathi/screens/components/forms/form1.dart';
import 'package:pharma_nathi/screens/components/forms/form2.dart';
import 'package:pharma_nathi/screens/components/forms/form3.dart';
import 'package:pharma_nathi/screens/components/forms/form4.dart';
import 'package:pharma_nathi/screens/pages/onboard_page.dart';
import 'package:pharma_nathi/screens/pages/signIn.dart';
import 'package:pharma_nathi/views/screens/earnings.dart';
import 'package:pharma_nathi/views/screens/appointments.dart';
import 'package:pharma_nathi/views/screens/home_page.dart';
import 'package:pharma_nathi/views/screens/patient_list.dart';
import 'package:pharma_nathi/views/screens/profile.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/signIn';
  static const String homePage = '/home_page';
  static const String appointments = '/appointments';
  static const String earnings = '/earnings';
  static const String patientList = '/patient_list';
  static const String profile = '/profile';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (context) => OnboardScreen(
            currentIndex: 0,
            form1Key: GlobalKey<Form1State>(),
            form2Key: GlobalKey<Form2State>(),
            form3Key: GlobalKey<Form3State>(),
            form4Key: GlobalKey<Form4State>(),
          ),
        );
      case signIn:
        return MaterialPageRoute(
          builder: (context) => const GoogleSignInWidget(),
        );
      case homePage:
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      case appointments:
        return MaterialPageRoute(
          builder: (context) => Appointments(),
        );
      case earnings:
        return MaterialPageRoute(
          builder: (context) => const Earnings(),
        );
      case patientList:
        return MaterialPageRoute(
          builder: (context) => const PatientList(),
        );
      case profile:
        return MaterialPageRoute(
          builder: (context) => MyProfile(
            onImageChanged: (newImage) {
              // Handle image change
            },
          ),
        );
      default:
        return null;
    }
  }
}
