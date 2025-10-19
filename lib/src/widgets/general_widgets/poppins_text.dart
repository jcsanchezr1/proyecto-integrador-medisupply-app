import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

class PoppinsText extends StatelessWidget {
  
  final String sText;
  final double dFontSize;
  final int? iMaxLines;
  final Color colorText;
  final FontWeight fontWeight;
  final FontStyle fontStyle;
  final TextAlign textAlign;
  final TextOverflow textOverflow;
  const PoppinsText(
    {
      super.key,
      required this.sText,
      required this.dFontSize,
      required this.colorText,
      this.iMaxLines,
      this.fontWeight = FontWeight.normal,
      this.fontStyle = FontStyle.normal,
      this.textAlign = TextAlign.start,
      this.textOverflow = TextOverflow.ellipsis
    }
  );
  @override
  Widget build( BuildContext context ) {
    return Text(
      sText,
      overflow: textOverflow,
      maxLines: iMaxLines,
      textAlign: textAlign,
      style: GoogleFonts.poppins(
        color: colorText, 
        fontSize: dFontSize,
        fontWeight: fontWeight,
        fontStyle: fontStyle
      )
    );
  }
}