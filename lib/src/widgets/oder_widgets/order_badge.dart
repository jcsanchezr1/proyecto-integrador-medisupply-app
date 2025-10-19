import 'package:flutter/material.dart';

import '../../utils/responsive_app.dart';
import '../general_widgets/poppins_text.dart';

class OrderBadge extends StatelessWidget {

  final String sLabel;
  final Color colorBadge;

  const OrderBadge(
    {
      super.key,
      required this.sLabel,
      required this.colorBadge
    }
  );

  @override
  Widget build( BuildContext context ) {

    return Container(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveApp.dHeight( 4.0),
        horizontal: ResponsiveApp.dWidth( 10.0 ),
      ),
      decoration: BoxDecoration(
        color: colorBadge.withValues( alpha: 0.1 ),
        borderRadius: BorderRadius.circular( ResponsiveApp.dSize( 8.0 ) ),
        border: Border.all( color: colorBadge )
      ),
      child: PoppinsText(
        sText: sLabel,
        dFontSize: ResponsiveApp.dSize( 10.0 ),
        colorText: colorBadge,
        fontWeight: FontWeight.w500
      )
    );

  }

}