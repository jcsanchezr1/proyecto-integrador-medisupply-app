import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medisupply_app/src/classes/client.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import '../../providers/create_visit_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

class ClientsMultiSelect extends StatefulWidget {

  const ClientsMultiSelect( { super.key } );

  @override
  State<ClientsMultiSelect> createState() => _ClientsMultiSelectState();

}

class _ClientsMultiSelectState extends State<ClientsMultiSelect> {

  @override
  Widget build( BuildContext context ) {

    final createVisitProvider = Provider.of<CreateVisitProvider>( context );

    return Container(
      height: ResponsiveApp.dHeight( 48.0 ),
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveApp.dWidth( 24.0 ),
        vertical: ResponsiveApp.dHeight( 12.0 )
      ),
      child: MultiSelectBottomSheetField(
        buttonIcon: Icon(
          Icons.arrow_drop_down_rounded,
          color: ColorsApp.textColor,
          size: ResponsiveApp.dSize( 24.0 )
        ),
        initialChildSize: 0.4,
        listType: MultiSelectListType.CHIP,
        searchable: true,
        buttonText: Text(
          TextsUtil.of(context)!.getText( 'new_visit.select_clients' ),
          style: GoogleFonts.poppins(
            color: ColorsApp.textColor,
            fontSize: ResponsiveApp.dSize( 12.0 )
          )
        ),
        title: Text(
          TextsUtil.of(context)!.getText( 'new_visit.clients' ),
          style: GoogleFonts.poppins(
            color: ColorsApp.secondaryColor,
            fontSize: ResponsiveApp.dSize( 16.0 ),
            fontWeight: FontWeight.w500
          )
        ),
        cancelText: Text(
          TextsUtil.of(context)!.getText( 'new_visit.cancel' ),
          style: GoogleFonts.poppins(
            color: ColorsApp.primaryColor,
            fontSize: ResponsiveApp.dSize( 14.0 ),
            fontWeight: FontWeight.w500
          )
        ),
        confirmText: Text(
          TextsUtil.of(context)!.getText( 'new_visit.confirm' ),
          style: GoogleFonts.poppins(
            color: ColorsApp.primaryColor,
            fontSize: ResponsiveApp.dSize( 14.0 ),
            fontWeight: FontWeight.w500
          )
        ),
        searchHint: TextsUtil.of(context)!.getText( 'new_visit.search' ),
        searchHintStyle: GoogleFonts.poppins(
          color: ColorsApp.textColor,
          fontSize: ResponsiveApp.dSize( 14.0 )
        ),
        searchTextStyle: GoogleFonts.poppins(
          color: ColorsApp.secondaryColor,
          fontSize: ResponsiveApp.dSize( 14.0 )
        ),
        itemsTextStyle: GoogleFonts.poppins(
          color: ColorsApp.secondaryColor,
          fontSize: ResponsiveApp.dSize( 14.0 )
        ),
        selectedItemsTextStyle: GoogleFonts.poppins(
          color: ColorsApp.primaryColor,
          fontSize: ResponsiveApp.dSize( 14.0 )
        ),
        items: createVisitProvider.lItems,
        onConfirm: (values) => createVisitProvider.setSelectedClients(values.cast<Client>()),
        chipDisplay: MultiSelectChipDisplay(
          onTap: (value) => createVisitProvider.removeClientSelected(value as Client)
        ),
        isDismissible: false,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular( 12.0 ),
          color: ColorsApp.cardBackgroundColor,
          border: Border.all(
            color: ColorsApp.borderColor,
            width: 1.0
          )
        )
      )
    );

  }

}