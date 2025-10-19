import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveApp {

  static num nScaleFactor = 1;
  static num nHeightScaleFactor = 1;
  static num nFactorTablet = 1.7281;
  static num nWidthScaleFactor = 1;
  static num nWidthScreen = 0;
  static num nHeightScreen = 0;
  static num nAspectRatio = 0;
  static num nLongDim = 0;
  static num nShortDim = 0;
  static num nScaleFactorH = 0.4906;

  static void init(BuildContext context, double designWidth, double designHeight) {
    nScaleFactor = (sqrt(pow(MediaQuery.of(context).size.width, 2) + pow(MediaQuery.of(context).size.height, 2))) /
        (sqrt(pow(designWidth, 2) + pow(designHeight, 2)));
    nHeightScaleFactor = MediaQuery.of(context).size.height / designHeight;
    nWidthScaleFactor = MediaQuery.of(context).size.width / designWidth;
    nWidthScreen = MediaQuery.of(context).size.width;
    nHeightScreen = MediaQuery.of(context).size.height;
    nAspectRatio = MediaQuery.of(context).size.aspectRatio;
    nLongDim = MediaQuery.of(context).size.longestSide;
    nShortDim = MediaQuery.of(context).size.shortestSide;
  }

  static double dHeight(double designHeight) {
    bool bTablet = ResponsiveApp.bTablet();
    if (bTablet) {
      return designHeight * nHeightScaleFactor * (nAspectRatio * nFactorTablet);
    } else {
      return designHeight * nHeightScaleFactor;
    }
  }

  static double dWidth(double designWidth) {
    bool bTablet = ResponsiveApp.bTablet();
    if (bTablet) {
      return designWidth * nWidthScaleFactor * (nAspectRatio * nFactorTablet);
    } else {
      return designWidth * nWidthScaleFactor;
    }
  }

  static double dSize(double designSize) => designSize * nScaleFactor;

  static double dWidthScreen() => nWidthScreen * 1;

  static double dHeightScreen() => nHeightScreen * 1;

  static double dAspectRatio() => nAspectRatio * 1;

  static double dLongDim() => nLongDim * 1;

  static double dShortDim() => nShortDim * 1;

  static bool bTablet() {
    return (ResponsiveApp.dWidthScreen() != ResponsiveApp.dHeightScreen() &&
        ResponsiveApp.dAspectRatio() >= 0.62 &&
        ResponsiveApp.dWidthScreen() >= 768);
  }

}
