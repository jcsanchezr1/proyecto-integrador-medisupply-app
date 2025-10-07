import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import 'poppins_text.dart';

class MainButton extends StatelessWidget {

  final String sLabel;
  final Function() onPressed;

  const MainButton(
    { 
      super.key,
      required this.sLabel,
      required this.onPressed
    }
  );

  @override
  Widget build( BuildContext context ) {

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: ColorsApp.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
        ),
        fixedSize: Size( ResponsiveApp.dWidth( 312.0 ), ResponsiveApp.dHeight( 40.0 ) ),
      ),
      onPressed: onPressed,
      child: PoppinsText(
        sText: sLabel,
         colorText: ColorsApp.secondaryTextColor,
         dFontSize: ResponsiveApp.dSize( 14.0 ),
         fontWeight: FontWeight.w500
      )
    );

  }
  
}