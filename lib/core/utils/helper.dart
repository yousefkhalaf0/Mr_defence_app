import 'package:flutter/material.dart';

class Helper {
  static double getResponsiveFontSize(
    BuildContext context, {
    required double fontSize,
  }) {
    double scaleFactor = _getScaleFactor(context);
    double responsiveFontSize = fontSize * scaleFactor;
    double lowerLimit = fontSize * 0.8;
    double upperLimit = fontSize * 1.2;
    return responsiveFontSize.clamp(lowerLimit, upperLimit);
  }

  static double _getScaleFactor(BuildContext context) {
    double screenWidth = MediaQuery.sizeOf(context).width;
    if (screenWidth < 600) {
      return screenWidth / 400;
    } else if (screenWidth < 900) {
      return screenWidth / 700;
    } else {
      return screenWidth / 1000;
    }
  }
}
