import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/create_visit_provider.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/poppins_text.dart';

class DateVisit extends StatefulWidget {

  const DateVisit( { super.key } );

  @override
  State<DateVisit> createState() => _DateVisitState();

}

class _DateVisitState extends State<DateVisit> {

  DateTime? selectedDate;

   Future<void> _selectDate() async {

    final createVisitProvider = Provider.of<CreateVisitProvider>( context, listen: false );

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100)
    );

    if (pickedDate != null) {

      setState( () => selectedDate = pickedDate );
      createVisitProvider.setSelectedDate( pickedDate );

    }

  }

  @override
  Widget build( BuildContext context ) {

    final createVisitProvider = Provider.of<CreateVisitProvider>( context );

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveApp.dWidth( 12.0 ),
          vertical: selectedDate != null ? ResponsiveApp.dHeight( 0.0 ) : ResponsiveApp.dHeight( 12.0 )
        ),
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveApp.dWidth( 24.0 ),
          vertical: ResponsiveApp.dHeight( 8.0 )
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular( 12.0 ),
          color: ColorsApp.cardBackgroundColor,
          border: Border.all( color: ColorsApp.borderColor )
        ),
        child: Row(
          children: [
            Expanded(
              child: PoppinsText(
                sText: selectedDate == null ? TextsUtil.of(context)?.getText( 'visits.date_filter' )
                : TextsUtil.of(context)?.formatLocalizedDate( context, selectedDate!.toIso8601String() ) ?? '',
                dFontSize: ResponsiveApp.dSize( 12.0 ),
                colorText: selectedDate == null ? ColorsApp.textColor : ColorsApp.secondaryColor
              )
            ),
            SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
            selectedDate == null ? Icon(
              Icons.arrow_drop_down_rounded,
              color: ColorsApp.textColor,
              semanticLabel: 'Open date picker'
            ) : IconButton(
              icon: Icon(
                Icons.close,
                color: ColorsApp.secondaryColor,
                semanticLabel: 'Clear date filter',
              ),
              onPressed: () => setState(() {
                selectedDate = null;
                createVisitProvider.setSelectedDate( null );
              })
            )
          ]
        )
      )
    );

  }

}