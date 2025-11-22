import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/poppins_text.dart';

class DateFilter extends StatefulWidget {

  final void Function( DateTime? selectedDate ) onDateSelected;

  const DateFilter(
    {
      super.key,
      required this.onDateSelected
    }
  );

  @override
  State<DateFilter> createState() => _DateFilterState();

}

class _DateFilterState extends State<DateFilter> {

  DateTime? selectedDate;

  Future<void> _selectDate() async {

    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2100)
    );

    if (pickedDate != null) {

      setState( () => selectedDate = pickedDate );

      widget.onDateSelected(pickedDate);

    }

  }

  @override
  Widget build( BuildContext context ) {

    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: ResponsiveApp.dWidth( 16.0 ),
          vertical: selectedDate != null ? ResponsiveApp.dHeight( 4.0 ) : ResponsiveApp.dHeight( 16.0 )
        ),
        margin: EdgeInsets.symmetric(
          horizontal: ResponsiveApp.dWidth( 16.0 ),
          vertical: ResponsiveApp.dHeight( 8.0 )
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular( 12.0 ),
          color: ColorsApp.cardBackgroundColor
        ),
        child: Row(
          children: [
            Icon(
              Icons.date_range,
              color: ColorsApp.borderColor,
              semanticLabel: 'Select date'
            ),
            SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
            Expanded(
              child: PoppinsText(
                sText: selectedDate == null ? TextsUtil.of(context)?.getText( 'visits.date_filter' )
                : TextsUtil.of(context)?.formatLocalizedDate( context, selectedDate!.toIso8601String() ) ?? '',
                dFontSize: ResponsiveApp.dSize( 12.0 ),
                colorText: ColorsApp.textColor
              )
            ),
            SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
            selectedDate == null ? Icon(
              Icons.arrow_drop_down,
              color: ColorsApp.borderColor,
              semanticLabel: 'Open date picker'
            ) : IconButton(
              icon: Icon(
                Icons.close,
                color: ColorsApp.borderColor,
                semanticLabel: 'Clear date filter',
              ),
              onPressed: () {
                setState(() => selectedDate = null);
                widget.onDateSelected( null );
              }
            )
          ]
        )
      )
    );

  }
}