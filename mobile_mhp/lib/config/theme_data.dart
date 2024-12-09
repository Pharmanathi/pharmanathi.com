
import 'package:flutter/material.dart';
import 'package:pharma_nathi/config/color_const.dart';
import 'package:pharma_nathi/config/spacing.dart';
import 'package:pharma_nathi/config/text_theme.dart';

class AppThemeData {
  static ThemeData themeLight = ThemeData(
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.cardLight,
      foregroundColor: AppColors.cardLight,
      iconTheme: IconThemeData(
        color: AppColors.cardDark,
        size: 22,
      ),
      elevation: 0,
      toolbarHeight: 47,
    ),
    dividerTheme: const DividerThemeData(
      color: AppColors.dividerLight,
      thickness: AppSpacings.cardOutlineWidth,
    ),
    dividerColor: AppColors.dividerLight,
    colorScheme: const ColorScheme(
      background: AppColors.cardLight,
      onBackground: AppColors.primaryColor,
      primary: AppColors.primaryColor,
      secondary: Colors.transparent,
      onPrimary: AppColors.primaryColor,
      surface: AppColors.white,
      onSurface: AppColors.white,
      brightness: Brightness.light,
      error: AppColors.red,
      onError: AppColors.red,
      onSecondary: AppColors.white,
      tertiary: AppColors.secondaryColor,
    ),
    scaffoldBackgroundColor: AppColors.lightBackground,
    primaryColor: AppColors.primaryColor,
    buttonTheme: const ButtonThemeData(
      height: 47,
      splashColor: AppColors.lightGrey,
    ),
    hintColor: AppColors.white,
    indicatorColor: AppColors.white,
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.all(AppColors.cardDark),
      splashRadius: AppSpacings.cardPadding,
    ),
    iconTheme: const IconThemeData(
      color: AppColors.iconLight,
      size: 22,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.cardLight,
      elevation: 0,
      showSelectedLabels: false,
      type: BottomNavigationBarType.fixed,
      showUnselectedLabels: false,
      selectedItemColor: AppColors.black,
      unselectedItemColor: AppColors.grey,
      selectedIconTheme: IconThemeData(
        color: AppColors.black,
        size: 22,
      ),
      unselectedIconTheme: IconThemeData(
        color: AppColors.unselectedColorLight,
        size: 22,
      ),
    ),
    splashColor: Colors.transparent,
    inputDecorationTheme: InputDecorationTheme(
      fillColor: AppColors.lightBackground,
      filled: true,
      hintStyle: AppTextThemes.mobileTextThemeLight.bodySmall?.copyWith(
        color: AppColors.unselectedColorLight,
      ),
      iconColor: AppColors.black,
      border: AppSpacings.outLineBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.dividerLight,
        ),
      ),
      focusColor: AppColors.white,
      enabledBorder: AppSpacings.outLineBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.dividerLight,
        ),
      ),
      errorBorder: AppSpacings.errorLineBorder,
      focusedErrorBorder: AppSpacings.errorLineBorder,
      focusedBorder: AppSpacings.outLineBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.primaryColor,
        ),
      ),
      disabledBorder: AppSpacings.disabledOutLineBorder.copyWith(
        borderSide: const BorderSide(
          color: AppColors.unselectedColorLight,
        ),
      ),
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(
        vertical: AppSpacings.elementSpacing * 1.5,
        horizontal: AppSpacings.cardPadding,
      ),
    ),
    primaryIconTheme: const IconThemeData(
      color: AppColors.black,
      size: 18,
    ),
    visualDensity: VisualDensity.adaptivePlatformDensity,
    unselectedWidgetColor: AppColors.unselectedColorLight,
    canvasColor: AppColors.cardLight2,
    cardColor: AppColors.cardLight,
    cardTheme: const CardTheme(
      shape: RoundedRectangleBorder(borderRadius: AppSpacings.defaultBorderRadius),
      color: AppColors.cardLight,
    ),
    textTheme: AppTextThemes.mobileTextThemeLight,
    primaryTextTheme: AppTextThemes.mobileTextThemeLight,
    textSelectionTheme: const TextSelectionThemeData(cursorColor: AppColors.blue),
  );
}

extension ThemeExtension on BuildContext {
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  ThemeData get theme => Theme.of(this);
  TextTheme get textTheme => theme.textTheme;

  bool get isLight => theme.brightness == Brightness.light;

  double get height => MediaQuery.of(this).size.height;
  double get width => MediaQuery.of(this).size.width;
}
