
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:pharma_nathi/config/color_const.dart';


class AppTextThemes {
  /// TYPOGRAPY
  static double headline1Size = 34.sp;
  static double headline2Size = 28.sp;
  static double headline3Size = 22.sp;
  static double headline4Size = 20.sp;
  static double headline5Size = 17.sp;
  static double headline6Size = 16.sp;
  static double subtile1Size = 15.sp;
  static double subtile2Size = 13.sp;
  static double body1Size = 16.sp;
  static double body2Size = 14.sp;
  static double buttonSize = 15.sp;
  static double caption = 12.sp;
  static double overline = 10.sp;


  static TextTheme mobileTextThemeLight = TextTheme(
    displayLarge: TextStyle(
      fontSize: headline1Size,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
      // fontFamilyFallback: fontFamilyFallbacks,
    ),
    displayMedium: TextStyle(
      fontSize: headline2Size,
      color: AppColors.black,
      fontWeight: FontWeight.w600,
      // fontFamilyFallback: fontFamilyFallbacks,
    ),
    displaySmall: TextStyle(
      fontSize: headline3Size,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    headlineMedium: TextStyle(
      fontSize: headline4Size,
      color: AppColors.black,
      // fontFamilyFallback: fontFamilyFallbacks,
      fontWeight: FontWeight.w400,
    ),
    headlineSmall: TextStyle(
      fontSize: headline5Size,
      // fontFamilyFallback: fontFamilyFallbacks,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    titleLarge: TextStyle(
      // fontFamilyFallback: fontFamilyFallbacks,
      fontSize: headline6Size,
      color: AppColors.black,
      fontWeight: FontWeight.w800,
    ),
    titleMedium: TextStyle(
      // fontFamilyFallback: fontFamilyFallbacks,
      fontSize: subtile1Size,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
    ),
    titleSmall: TextStyle(
      // fontFamilyFallback: fontFamilyFallbacks,
      fontSize: subtile2Size,
      color: AppColors.black,
      fontWeight: FontWeight.w700,
    ),
    bodyLarge: TextStyle(
      fontSize: body1Size,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
    ),
    bodyMedium: TextStyle(
      fontSize: body2Size,
      // fontFamilyFallback: fontFamilyFallbacks,
      color: AppColors.black,
      fontWeight: FontWeight.w500,
    ),
    labelLarge: TextStyle(
      fontSize: buttonSize,
      color: AppColors.black,

      // fontFamilyFallback: fontFamilyFallbacks,
      fontWeight: FontWeight.w600,
    ),
    bodySmall: TextStyle(
      fontSize: caption,
      // fontFamilyFallback: fontFamilyFallbacks,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
    ),
    labelSmall: TextStyle(
      // fontFamilyFallback: fontFamilyFallbacks,
      fontSize: overline,
      color: AppColors.black,
      fontWeight: FontWeight.w400,
    ),
  );
}
