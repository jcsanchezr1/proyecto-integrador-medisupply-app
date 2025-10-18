import 'package:flutter/material.dart';

import 'package:google_fonts/google_fonts.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import 'poppins_text.dart';

class DropDownWidget extends StatefulWidget {

  final String sHintText;
  final String sLabel;
  final String? Function(String?)? validator;
  final List<dynamic> lItems;

  const DropDownWidget(
    {
      super.key,
      required this.sHintText,
      required this.sLabel,
      required this.lItems,
      this.validator
    }
  );

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();

}

class _DropDownWidgetState extends State<DropDownWidget> {

  String? selectedLanguage;

  @override
  Widget build( BuildContext context ) {

    return SizedBox(
      width: ResponsiveApp.dWidth( 312.0 ),
      child: DropdownButtonFormField<String>(
        validator: widget.validator,
        iconEnabledColor: ColorsApp.secondaryColor,
        iconDisabledColor: ColorsApp.secondaryColor,
        hint: PoppinsText(
          sText: widget.sHintText,
          dFontSize: ResponsiveApp.dSize(13.0),
          colorText: ColorsApp.textColor
        ),
        dropdownColor: ColorsApp.backgroundColor,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.symmetric( horizontal: ResponsiveApp.dWidth( 16.0 ), vertical: ResponsiveApp.dHeight( 18.0 ) ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.secondaryColor)
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.secondaryColor)
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular( 8.0 ),
            borderSide: const BorderSide( color: ColorsApp.secondaryColor)
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
          )
        ),
        items: widget.lItems.map(( item ) => DropdownMenuItem<String>(
            value: item["id"],
            child: PoppinsText(
              sText: item["name"],
              dFontSize: ResponsiveApp.dSize(12.0),
              colorText: ColorsApp.textColor
            )
          )
        ).toList(),
        onChanged: (value) {
          if (value != null) {
            setState( () {
              for ( var item in widget.lItems ) {
                item["selected"] = false;
              }
              widget.lItems.firstWhere((item) => item["id"] == value)["selected"] = true;
              selectedLanguage = value;
            } );
          }
        },
        value: selectedLanguage
      )
    );

  }

}