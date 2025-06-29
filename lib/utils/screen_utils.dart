import 'package:flutter/material.dart';

class ScreenUtils {
  static double screenWidth(BuildContext context) {
    return MediaQuery.of(context).size.width;
  }

  static double screenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  static bool isSmallScreen(BuildContext context) {
    return screenWidth(context) < 350;
  }

  static bool isMediumScreen(BuildContext context) {
    return screenWidth(context) >= 350 && screenWidth(context) < 400;
  }

  static bool isLargeScreen(BuildContext context) {
    return screenWidth(context) >= 400;
  }

  static EdgeInsets getResponsivePadding(BuildContext context) {
    if (isSmallScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 20, vertical: 16);
    } else if (isMediumScreen(context)) {
      return const EdgeInsets.symmetric(horizontal: 30, vertical: 20);
    } else {
      return const EdgeInsets.symmetric(horizontal: 40, vertical: 24);
    }
  }

  static double getResponsiveFontSize(BuildContext context, double baseSize) {
    if (isSmallScreen(context)) {
      return baseSize * 0.9;
    } else if (isLargeScreen(context)) {
      return baseSize * 1.1;
    }
    return baseSize;
  }
}
