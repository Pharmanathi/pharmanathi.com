// ignore_for_file: use_full_hex_values_for_flutter_colors, constant_identifier_names

import 'package:flutter/material.dart';

class Pallet {
  const Pallet._();
  // *Colors from Coolors palette
  static const Color PRIMARY_COLOR = Color.fromARGB(255, 101, 115, 207);
  static const Color SECONDARY_COLOR = Color(0xFF8D96A6);
  static const Color SUCCESS = Color(0xFF96D14E);
  static const Color Black = Colors.black;
  static const Color BACKGROUND_COLOR = Color(0xFFF7F9FC);
  static const Color PURE_WHITE = Color.fromRGBO(255, 255, 255, 1);
  static const Color BACKGROUND_50 = Color(0xFFF7F9FC);
  static const Color WARNING = Color(0xFFFCDC620);
  static const Color NATURAL_FAINT = Color(0xFFFF4F7FA);
  static const Color PRAMARY_50 = Color(0xFFFF1F2FB);
  static const Color PRAMARY_75 = Color(0xFFF7F9FC);
  static const Color PRAMARY_80 = Color(0xFFEDEFF8);
  static const Color PRAMARY_100 = Color(0xFFFD2D7F3);
  static const Color PRIMARY_200 = Color(0xFFFBDC4ED);
  static const Color PRIMARY_300 = Color(0xFFF9FA9E4);
  static const Color PRIMMARY_400 = Color(0xFFF8C98DF);
  static const Color PRIMARY_500 = Color(0xFFF6F7ED7);
  static const Color PRIMARY_600 = Color(0xFFF6573C4);
  static const Color PRIMARY_700 = Color(0xFFF4F5999);
  static const Color PRIMARY_800 = Color(0xFFF3D4576);
  static const Color PRIMARY_900 = Color(0xFFF2F355A);
  static const Color SECONDARY_50 = Color(0xFFFF4F5F6);
  static const Color SECONDARY_100 = Color(0xFFFDCDEE3);
  static const Color SECONDARY_200 = Color(0xFFFCBCFD6);
  static const Color SECONDARY_300 = Color(0xFFFB3B9C3);
  static const Color SECONDARY_400 = Color(0xFFFA4ABB8);
  static const Color SECONDARY_500 = Color(0xFFF8D96A6);
  static const Color SECONDARY_600 = Color(0xFFF808997);
  static const Color SECONDARY_700 = Color(0xFFF646B76);
  static const Color SECONDARY_800 = Color(0xFFF4E535B);
  static const Color SECONDARY_900 = Color(0xFFF3B3F46);
  static const Color WARNING_50 = Color(0xFFFFAF9E9);
  static const Color WARNING_100 = Color(0xFFFF0EDBA);
  static const Color WARNING_200 = Color(0xFFFE8E598);
  static const Color WARNING_300 = Color(0xFFFDED96A);
  static const Color WARNING_400 = Color(0xFFFD7D14D);
  static const Color WARNING_500 = Color(0xFFFCDC620);
  static const Color WARNING_600 = Color(0xFFFBBB41D);
  static const Color WARNING_700 = Color(0xFFF928D17);
  static const Color WARNING_800 = Color(0xFFF716D12);
  static const Color WARNING_900 = Color(0xFFF56530D);
  static const Color NEUTRAL_50 = Color(0xFFFE8E9EB);
  static const Color NEUTRAL_100 = Color(0xFFFB8B9BF);
  static const Color NEUTRAL_200 = Color(0xFFF9698A1);
  static const Color NEUTRAL_300 = Color(0xFFF666876);
  static const Color NEUTRAL_400 = Color(0xFFF484B5B);
  static const Color NEUTRAL_500 = Color(0xFFF1A1E32);
  static const Color NEUTRAL_600 = Color(0xFFF181B2E);
  static const Color NEUTRAL_700 = Color(0xFFF121524);
  static const Color NEUTRAL_800 = Color(0xFFF0E111C);
  static const Color NEUTRAL_900 = Color(0xFFF0B0D15);
  static const Color DANGER_50 = Color(0xFFFFBEDE8);
  static const Color DANGER_100 = Color(0xFFFF4C7B8);
  static const Color DANGER_200 = Color(0xFFFEEAC95);
  static const Color DANGER_300 = Color(0xFFFE68665);
  static const Color DANGER_400 = Color(0xFFFE16E47);
  static const Color DANGER_500 = Color(0xFFFDA4A19);
  static const Color DANGER_600 = Color(0xFFFC64317);
  static const Color DANGER_700 = Color(0xFFF9B3512);
  static const Color DANGER_800 = Color(0xFFF78290E);
  static const Color DANGER_900 = Color(0xFFF5C1F0B);
  static const Color TRANSPARENT = Colors.transparent;
}

class AppColors {

  static const List<Color> primaryGradientColors = [
    primaryColor,
    secondaryColor,
  ];

  static const List<Color> successGradientColors = [
    green,
    blue,
  ];

  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: primaryGradientColors,
  );

  static const LinearGradient successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: successGradientColors,
  );

  const AppColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const purple = Color(0xFF6941C6);

  static const Color primaryColor = Color(0xff6067FA);

  static const Color secondaryColor = Color(0xff7730F1);

  static const Color dimGrey = Color(0xFF585757);

  static const Color unselectedColorLight = Color(0xFF8E9497);
  static const Color unselectedColorDark = Color(0xFF768992);

  static const Color blue = Color(0xff00BCFF);
  static const Color darkBlue = Color(0xff007AFF);

  static const Color lightBlue = Color(0xff8CE1FF);

  static const Color lightGreen = Color(0xFFDFFEBF);
  static const Color black = Color(0xFF000000);
  static const Color grey =  Color(0xffEEEEEE);
  static const Color lightGrey = Color(0xFFF8F7F7);

  static const Color cardDark = Color(0xFF1F2326);
  static const Color cardDark2 = Color(0xFF16191B);

  static const Color iconDark = Color(0xffEFF0F5);
  static const Color iconLight = Color(0xFF535353);

  static const Color cardLight = Color(0xFFF6F7F8);
  static const Color cardLight2 = Color(0xffEFF0F5);

  static const Color dividerDark = Color(0xFF3A454E);
  static const Color dividerLight = Color(0xFFB7B7B7);

  static const Color lightBackground = Color(0xFFFFFFFF);
  static const Color darkBackground = Color(0xFF1B1E21);




  static const offBlack = Color(0xff444444);
  static const green = Color(0xffE2EDE1);
  static const lightPurple = Color(0xffECE3FA);
  static const darkPurple = Color(0xff7730F1);
  static const pink = Color(0xffFAF5F5);
  static const pink2 = Color(0xffF5F0FA);
  static const darkPink = Color(0xffE8CBD9);
  static const grey2 = Color(0xffE5E5E5);
  static const grey3 = Color(0xff878787);
  static const grey4 = Color(0xffA9A9A9);
  static const grey5 = Color(0xff333333);
  static const darkGrey = Color(0xff656565);
  static const orange = Color(0xffEED1CA);
  static const red = Color(0xffEB5757);
  static const lightBlue2 = Color(0xffE6F9FF);
  static const yellow = Color(0xffF8DB73);
  static const lightyellow = Color(0xffFFF4D1);
  static const borderForActivityContainerColor = Color(0xffE3D6EF);
}

