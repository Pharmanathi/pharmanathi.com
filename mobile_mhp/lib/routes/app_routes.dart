import 'package:flutter/material.dart';
import 'package:pharma_nathi/views/screens/account.dart';
import 'package:pharma_nathi/views/screens/boardingOnAppointmentScreen.dart';
import 'package:pharma_nathi/views/screens/earnings.dart';
import 'package:pharma_nathi/views/screens/appointments.dart';
import 'package:pharma_nathi/views/screens/home_page.dart';
import 'package:pharma_nathi/views/screens/notifications_screen.dart';
import 'package:pharma_nathi/views/screens/patient_list.dart';
import 'package:pharma_nathi/views/screens/profile.dart';
import 'package:pharma_nathi/views/screens/sign_in.dart';

class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign_in';
  static const String homePage = '/home_page';
  static const String appointments = '/appointments';
  static const String earnings = '/earnings';
  static const String patientList = '/patient_list';
  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String editprofile = '/edit_profile';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(builder: (context) => OnboardScreen());
      case signIn:
        return MaterialPageRoute(builder: (context) => GoogleSignInWidget());
      case homePage:
        return MaterialPageRoute(builder: (context) => const HomePage());
      case appointments:
        return MaterialPageRoute(builder: (context) => Appointments());
      case earnings:
        return MaterialPageRoute(builder: (context) => const Earnings());
      case patientList:
        return MaterialPageRoute(builder: (context) => const PatientList());
      case profile:
        return MaterialPageRoute(
          builder: (context) => MyProfile(
            onImageChanged: (newImage) {
              // Handle image change
            },
          ),
        );
      case editprofile:
        return MaterialPageRoute(
          builder: (context) => EditAccount(
            imageFile: null,
            onImageChanged: (newImage) {
              //* Handle image change logic here
            },
          ),
        );
      case notifications:
        return MaterialPageRoute(builder: (context) => NotificationsScreen());
      default:
        return null;
    }
  }
}
