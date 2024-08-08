// ignore_for_file: prefer_const_constructors, prefer_const_literals_to_create_immutables, use_key_in_widget_constructors
import 'package:flutter/material.dart';

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
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        onTap(index); // Call the provided callback to handle tap events
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/home_page'); // Navigate to the Home screen
            break;
          // case 1:
          //   Navigator.pushNamed(context, '/chats'); // Navigate to the Appointments screen
          //   break;
            case 1:
            Navigator.pushNamed(context, '/doctors'); // Navigate to the Appointments screen
            break;
             case 2:
            Navigator.pushNamed(context, '/appointments'); // Navigate to the Appointments screen
            break;
             case 3:
            Navigator.pushNamed(context, '/profile_settings'); // Navigate to the Appointments screen
            break;
        }
      },
      items: [
        BottomNavigationBarItem(

          icon: Icon(Icons.home),
          label: 'Home',
        ),
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.maps_ugc),
        //   label: 'Chats',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.earbuds),
          label: 'Doctors',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.calendar_month),
          label: 'Appointments',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profile',
        ),
      ],
    );
  }
}
