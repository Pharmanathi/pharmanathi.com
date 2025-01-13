// ignore_for_file: prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:patient/config/color_const.dart';

class TextAndHeadingComponents {
  static Widget buildHeading(String heading) {
    return Text(
      heading, // Use the provided heading parameter
      style: GoogleFonts.openSans(
        color:  Pallet.PRIMARY_COLOR,
        fontSize: 30.sp,
        fontWeight: FontWeight.bold,
        height: 1
      ),
    );
  }

  static Widget buildText(String text) {
    return Text(
      text, // Use the provided text parameter
      style: GoogleFonts.openSans(
        color: Pallet.NEUTRAL_200,
        fontSize: 14.sp,
      ),
    );
  }
}
