import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

class FindingsTextField extends StatefulWidget {

  final TextEditingController controller;

  const FindingsTextField(
    {
      super.key,
      required this.controller
    }
  );

  @override
  State<FindingsTextField> createState() => _FindingsTextFieldState();

}

class _FindingsTextFieldState extends State<FindingsTextField> {

  @override
  Widget build( BuildContext context ) {

    return TextFormField(
      controller: widget.controller,
      maxLines: 8,
      style: GoogleFonts.poppins(
        fontSize: ResponsiveApp.dSize( 14.0 ),
        color: ColorsApp.textColor
      ),
      decoration: InputDecoration(
        labelText: TextsUtil.of(context)!.getText('visit_detail.findings_label'),
        hintText: TextsUtil.of(context)!.getText('visit_detail.findings_hint'),
        labelStyle: GoogleFonts.poppins(
          fontSize: ResponsiveApp.dSize( 16.0 ),
          color: ColorsApp.textColor,
          backgroundColor: ColorsApp.backgroundColor
        ),
        hintStyle: GoogleFonts.poppins(
          fontSize: ResponsiveApp.dSize( 12.0 ),
          color: ColorsApp.textColor
        ),
        contentPadding: EdgeInsets.symmetric(
          horizontal: ResponsiveApp.dWidth( 16.0 ),
          vertical: ResponsiveApp.dHeight( 12.0 )
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
          borderSide: const BorderSide( color: ColorsApp.secondaryColor)
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
          borderSide: const BorderSide( color: ColorsApp.secondaryColor)
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
          borderSide: const BorderSide( color: ColorsApp.secondaryColor)
        ),
        errorStyle: GoogleFonts.poppins(),
        errorMaxLines: 3,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
          borderSide: const BorderSide( color: ColorsApp.secondaryColor)
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular( 12.0 ),
          borderSide: const BorderSide( color: ColorsApp.secondaryColor )
        )
      )
    );

  }

}