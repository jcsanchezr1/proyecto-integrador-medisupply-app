import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../general_widgets/poppins_text.dart';

class InfoVisitItem extends StatelessWidget {

  final IconData icon;
  final String sText;

  const InfoVisitItem(
    {
      super.key,
      required this.icon,
      required this.sText
    }
  );

  @override
  Widget build( BuildContext context ) {

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: ColorsApp.primaryColor,
          semanticLabel: icon.codePoint.toString()
        ),
        SizedBox(width: ResponsiveApp.dWidth(8.0)),
        Expanded(
          child: PoppinsText(
            sText: sText,
            dFontSize: ResponsiveApp.dSize( 12.0 ),
            colorText: ColorsApp.textColor,
            textOverflow: TextOverflow.ellipsis
          )
        )
      ]
    );

  }

}