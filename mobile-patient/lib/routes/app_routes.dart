// ignore_for_file: prefer_const_constructors, use_key_in_widget_constructors

import 'package:client_pharmanathi/views/screens/sign_in.dart';
import 'package:flutter/material.dart';
import '../screens/pages/onboard_page.dart';
import '../views/screens/home_page.dart';
import '../views/screens/appointment.dart';
import '../views/screens/doctors.dart';
import '../views/screens/profile_settings.dart';


class AppRoutes {
  static const String onboarding = '/onboarding';
  static const String signIn = '/sign_in';
  static const String homePage = '/home_page';
  static const String appointments = '/appointments';
  static const String doctors = '/doctors';
  static const String profileSettings = '/profile_settings';

  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case onboarding:
        return MaterialPageRoute(
          builder: (context) => OnboardScreen(
            currentIndex: 0,
            headings: OnboardScreen.sampleHeadings,
            texts: OnboardScreen.sampleTexts,
          ),
        );
      case signIn:
        return MaterialPageRoute(
          builder: (context) => GoogleSignInWidget(),
        );
      case homePage:
        return MaterialPageRoute(
          builder: (context) => HomePage(),
        );
      case appointments:
        return MaterialPageRoute(
          builder: (context) => Appointments(),
        );
      case doctors:
        return MaterialPageRoute(
          builder: (context) => Doctors(),
        );
      case profileSettings:
        return MaterialPageRoute(
          builder: (context) => ProfileSetting(),
        );
      default:
        return _errorRoute();
    }
  }

  static Route<dynamic> _errorRoute() {
    return MaterialPageRoute(
      builder: (context) => Scaffold(
        appBar: AppBar(
          title: Text('Error'),
        ),
        body: Center(
          child: Text('404 - Page not found'),
        ),
      ),
    );
  }
}
