// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors, prefer_const_constructors_in_immutables
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      showSelectedLabels: false,
      showUnselectedLabels: false,
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        onTap(index); // Call the provided callback to handle tap events
        switch (index) {
          case 0:
            Navigator.pushNamed(
                context, '/home_page'); // Navigate to the Home screen
            break;
          case 1:
            Navigator.pushNamed(context,
                '/appointments'); // Navigate to the Appointments screen
            break;
          case 2:
            Navigator.pushNamed(context,
                '/patient_list'); // Navigate to the Appointments screen
            break;
          case 3:
            Navigator.pushNamed(
                context, '/profile'); // Navigate to the Appointments screen
            break;
          // case 4:
          // Navigator.pushNamed(context, '/profile'); // Navigate to the Appointments screen
          // break;
          // Add cases for other items if needed
        }
      },
      items: [
        BottomNavigationBarItem(
          icon: Icon(Icons.home, size: 32.w),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month, size: 32.w),
          label: 'Appointment',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.wallet),
        //   label: 'Walet',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.group, size: 32.w),
          label: 'Patient',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person, size: 32.w),
          label: 'Profile',
        ),
      ],
    );
  }
}
