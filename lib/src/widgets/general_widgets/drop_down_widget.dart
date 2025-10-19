import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../providers/create_account_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import '../../utils/texts_util.dart';
import 'poppins_text.dart';

class DropDownWidget extends StatefulWidget {

  final String sHintText;
  final String sLabel;
  final String? Function(String?)? validator;
  final List<dynamic> lItems;
  final bool bType;

  const DropDownWidget(
    {
      super.key,
      required this.sHintText,
      required this.sLabel,
      required this.lItems,
      this.bType = true,
      this.validator
    }
  );

  @override
  State<DropDownWidget> createState() => _DropDownWidgetState();

}

class _DropDownWidgetState extends State<DropDownWidget> {

  String? selectedLanguage;

  onChanged( String? sValue ) async {

    final createAccountProvider = Provider.of<CreateAccountProvider>( context, listen: false );

    if (sValue != null) {
      setState( () {
        for ( var item in widget.lItems ) {
          item["selected"] = false;
        }
        widget.lItems.firstWhere((item) => item["id"] == sValue)["selected"] = true;
        selectedLanguage = sValue;
      } );

      try {
        if( widget.bType ) {
          final List<dynamic> typesEs = await TextsUtil.getSpanishText('create_account.types');
          final selectedItem = typesEs.firstWhere((item) => item["id"] == sValue);
          createAccountProvider.sSelectedType = selectedItem["name"];
        } else {
          final List<dynamic> specialitiesEs = await TextsUtil.getSpanishText('create_account.specialities');
          final selectedItem = specialitiesEs.firstWhere((item) => item["id"] == sValue);
          createAccountProvider.sSelectedSpeciality = selectedItem["name"];
        }
      } catch (e) {
        // Fallback for tests where assets are not available
        final selectedItem = widget.lItems.firstWhere((item) => item["id"] == sValue);
        if( widget.bType ) {
          createAccountProvider.sSelectedType = selectedItem["name"];
        } else {
          createAccountProvider.sSelectedSpeciality = selectedItem["name"];
        }
      }

    }

  }

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
              dFontSize: ResponsiveApp.dSize(13.0),
              colorText: ColorsApp.textColor
            )
          )
        ).toList(),
        onChanged: onChanged,
        value: selectedLanguage
      )
    );

  }

}