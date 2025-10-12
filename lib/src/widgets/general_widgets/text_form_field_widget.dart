import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import 'poppins_text.dart';

class TextFormFieldWidget extends StatefulWidget {

  final TextEditingController controller;
  final bool bIsPassword;
  final bool bEnabled;
  final bool bError;
  final String sLabel;
  final double dWidth;
  final String? Function(String?)? validator;
  final Key? fieldKey;

  const TextFormFieldWidget(
    {
      super.key,
      required this.controller,
      required this.sLabel,
      this.validator,
      this.dWidth = 312.0,
      this.bIsPassword = false,
      this.bEnabled = true,
      this.bError = false,
      this.fieldKey
    }
  );

  @override
  State<TextFormFieldWidget> createState() => _TextFormFieldWidgetState();
}

class _TextFormFieldWidgetState extends State<TextFormFieldWidget> {

  bool bObscure = true;

  @override
  Widget build( BuildContext context ) {

    return SizedBox(
      width: ResponsiveApp.dWidth( widget.dWidth ),
      child: TextFormField(
        key: widget.fieldKey,
        validator: widget.validator,
        enabled: widget.bEnabled,
        controller: widget.controller,
        obscureText: widget.bIsPassword ? bObscure : false,
        style: GoogleFonts.poppins(
          color: ColorsApp.secondaryColor,
          fontSize: ResponsiveApp.dSize( 14.0 )
        ),
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric( horizontal: ResponsiveApp.dWidth( 16.0 ), vertical: ResponsiveApp.dHeight( 18.0 ) ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.borderColor)
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.borderColor)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.borderColor)
          ),
          errorStyle: GoogleFonts.poppins(),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.secondaryColor)
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.secondaryColor )
          ),
          label: PoppinsText(
            sText: widget.sLabel,
            dFontSize: ResponsiveApp.dSize( 13.0 ),
            colorText: ColorsApp.textColor
          ),
          suffixIcon: widget.bIsPassword ? IconButton(
            onPressed: () => setState(() => bObscure = !bObscure ),
            icon: Icon(
              bObscure ? Icons.visibility_off : Icons.visibility,
              color: ColorsApp.primaryColor
            )
          ) : widget.bError ? Icon(
            Icons.error_rounded,
            color: ColorsApp.errorColor,
            size: ResponsiveApp.dSize( 24.0 )
          ) : const SizedBox()
        )
      )
    );

  }
}