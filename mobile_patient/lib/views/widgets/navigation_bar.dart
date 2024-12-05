import 'package:patient/config/color_const.dart';
import 'package:flutter/material.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final Color selectedColor;
  final Color unselectedColor;

  CustomBottomNavigationBar({
    required this.currentIndex,
    required this.onTap,
    this.selectedColor = Pallet.PRIMARY_COLOR,
    this.unselectedColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      type: BottomNavigationBarType.fixed,
      onTap: (index) {
        onTap(index); //* Call the provided callback to handle tap events
        switch (index) {
          case 0:
            Navigator.pushNamed(context, '/appointments');
            break;
          case 1:
            Navigator.pushNamed(context, '/doctors');
            break;
          // case 0:
          //   Navigator.pushNamed(context, '/appointments');
          //   break;
          case 2:
            Navigator.pushNamed(context, '/profile_settings');
            break;
        }
      },
      items: [
        // _buildBottomNavigationBarItem(
        //   icon: 'assets/images/Icon open-home.png',
        //   label: '',
        //   isSelected: currentIndex == 0,
        // ),
        _buildBottomNavigationBarItem(
          icon: 'assets/images/Icon open-calendar.png',
          label: '',
          isSelected: currentIndex == 0,
        ),
        _buildBottomNavigationBarItem(
          icon: 'assets/images/Group 16.png',
          label: '',
          isSelected: currentIndex == 1,
        ),

        _buildBottomNavigationBarItem(
          icon: 'assets/images/Icon awesome-user-alt.png',
          label: '',
          isSelected: currentIndex == 3,
        ),
      ],
    );
  }

  BottomNavigationBarItem _buildBottomNavigationBarItem({
    required String icon,
    required String label,
    required bool isSelected,
  }) {
    return BottomNavigationBarItem(
      icon: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 10.0),
            child: Image.asset(
              icon,
              width: 54,
              height: 24,
              color: isSelected ? selectedColor : unselectedColor,
            ),
          ),
          if (isSelected)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Align(
                alignment: Alignment.topCenter,
                child: Container(
                  width: 50,
                  height: 4.0,
                  decoration: BoxDecoration(
                    color: selectedColor,
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ),
        ],
      ),
      label: label,
    );
  }
}
