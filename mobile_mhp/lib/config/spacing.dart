
import 'package:flutter/material.dart';
import 'package:pharma_nathi/config/color_const.dart';

class AppSpacings {
  const AppSpacings._();
  
  static const double cardPadding = 20;
  static const double radius = 12;
  static const double webWidth = 1080;
  static const double elementSpacing = cardPadding * 0.5;
  static const double cardOutlineWidth = 0.25;

  static const defaultBorderRadius = BorderRadius.only(
    topLeft: Radius.circular(radius),
    topRight: Radius.circular(radius),
    bottomLeft: Radius.circular(radius),
    bottomRight: Radius.circular(radius),
  );

  static const defaultBorderRadiusTextField = BorderRadius.only(
    topLeft: Radius.circular(radius * 0.5),
    topRight: Radius.circular(radius * 0.5),
    bottomLeft: Radius.circular(radius * 0.5),
    bottomRight: Radius.circular(radius * 0.5),
  );

  static const defaultCircularRadius = BorderRadius.only(
    topLeft: Radius.circular(999),
    topRight: Radius.circular(999),
    bottomLeft: Radius.circular(999),
    bottomRight: Radius.circular(999),
  );

  static const OutlineInputBorder outLineBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color:AppColors.primaryColor, width: 1.5),
  );

  static const OutlineInputBorder disabledOutLineBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color: AppColors.unselectedColorDark, width: 0.1),
  );
  static const OutlineInputBorder errorLineBorder = OutlineInputBorder(
    borderRadius: defaultBorderRadiusTextField,
    borderSide: BorderSide(color: AppColors.red, width: 1.2),
  );
}
