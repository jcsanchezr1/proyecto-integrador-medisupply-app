import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

class OrderInfoItem extends StatelessWidget {

  final String sLabel;
  final String sValue;

  const OrderInfoItem(
    {
      super.key,
      required this.sLabel,
      required this.sValue
    }
  );

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        children: [
          TextSpan(
            text: sLabel,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveApp.dSize( 12.0 ),
              color: ColorsApp.textColor,
              fontWeight: FontWeight.w600
            )
          ),
          TextSpan(
            text: sValue,
            style: GoogleFonts.poppins(
              fontSize: ResponsiveApp.dSize( 12.0 ),
              color: ColorsApp.textColor
            )
          )
        ]
      )
    );
  }
}