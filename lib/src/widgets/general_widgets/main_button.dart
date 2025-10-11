import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/login_provider.dart';

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

    final loginProvider = Provider.of<LoginProvider>( context );

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: loginProvider.bLoading ? ColorsApp.primaryColor.withValues( alpha: 0.5 ) : ColorsApp.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
        ),
        fixedSize: Size( ResponsiveApp.dWidth( 312.0 ), ResponsiveApp.dHeight( 40.0 ) ),
      ),
      onPressed: loginProvider.bLoading ? null : onPressed,
      child: loginProvider.bLoading ? SizedBox(
        height: ResponsiveApp.dHeight( 24.0 ),
        width: ResponsiveApp.dWidth( 24.0 ),
        child: CircularProgressIndicator(
          color: ColorsApp.backgroundColor
        )
      )
      : PoppinsText(
        sText: sLabel,
         colorText: ColorsApp.secondaryTextColor,
         dFontSize: ResponsiveApp.dSize( 14.0 ),
         fontWeight: FontWeight.w500
      )
    );

  }
  
}