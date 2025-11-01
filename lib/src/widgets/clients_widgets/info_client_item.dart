import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../general_widgets/poppins_text.dart';

class InfoClientItem extends StatelessWidget {

  final String sInfo;
  final IconData iconData;

  const InfoClientItem(
    {
      super.key,
      required this.sInfo,
      required this.iconData
    }
  );

  @override
  Widget build( BuildContext context ) {

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: ResponsiveApp.dHeight( 8.0 ),
        horizontal: ResponsiveApp.dWidth( 24.0 )
      ),
      child: Row(
        children: [
          Icon(
            iconData,
            color: ColorsApp.primaryColor,
            semanticLabel: iconData.codePoint.toString()
          ),
          SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
          Expanded(
            child: PoppinsText(
              sText: sInfo,
              dFontSize: ResponsiveApp.dSize( 12.0 ),
              colorText: ColorsApp.textColor
            )
          )
        ]
      )
    );

  }

}