import 'dart:math';

import 'package:flutter/material.dart';

class ResponsiveApp {

  static num _nScaleFactor = 1;
  static num _nHeightScaleFactor = 1;
  static num nFactorTablet = 1.7281;
  static num _nWidthScaleFactor = 1;
  static num _nWidthScreen = 0;
  static num _nHeightScreen = 0;
  static num _nAspectRatio = 0;
  static num _nLongDim = 0;
  static num _nShortDim = 0;
  static num nScaleFactorH = 0.4906;

  static void init( BuildContext context, double designWidth, double designHeight ) {

    _nScaleFactor = ( sqrt( pow( MediaQuery.of( context).size.width, 2) + pow( MediaQuery.of( context ).size.height, 2 ) ) ) / ( sqrt( pow( designWidth, 2 )+ pow( designHeight, 2 ) ) );
    _nHeightScaleFactor = MediaQuery.of( context ).size.height / designHeight;
    _nWidthScaleFactor = MediaQuery.of( context ).size.width / designWidth;
    _nWidthScreen = MediaQuery.of( context ).size.width;
    _nHeightScreen = MediaQuery.of( context ).size.height;
    _nAspectRatio = MediaQuery.of( context ).size.aspectRatio;
    _nLongDim = MediaQuery.of( context ).size.longestSide;
    _nShortDim = MediaQuery.of( context ).size.shortestSide;

  }

  static double dHeight( double designHeight ) {

    bool bTablet = ResponsiveApp.bTablet();
     
    if ( bTablet ) {

      return designHeight * _nHeightScaleFactor * ( _nAspectRatio * nFactorTablet );
    
    } else {

      return designHeight * _nHeightScaleFactor;

    }

  }

  static double dWidth( double designWidth ) {

    bool bTablet = ResponsiveApp.bTablet();

    if ( bTablet ) {

      return designWidth * _nWidthScaleFactor * ( _nAspectRatio * nFactorTablet );
      
     } else {

      return designWidth * _nWidthScaleFactor;
     
     }
  
  }

  static double dSize( double designSize ) => designSize * _nScaleFactor;

  static double dWidthScreen() => _nWidthScreen * 1;

  static double dHeightScreen() => _nHeightScreen * 1;

  static double dAspectRatio() => _nAspectRatio * 1;
  
  static double dLongDim() => _nLongDim * 1;

  static double dShortDim() => _nShortDim * 1;

  static bool bTablet() {

    return ( ResponsiveApp.dWidthScreen() != ResponsiveApp.dHeightScreen() &&
      ResponsiveApp.dAspectRatio() >= 0.62 &&
      ResponsiveApp.dWidthScreen() >= 768
    );

  }

}
