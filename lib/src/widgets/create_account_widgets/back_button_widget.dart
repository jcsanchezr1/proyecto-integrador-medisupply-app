import 'package:flutter/material.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/poppins_text.dart';

class BackButtonWidget extends StatelessWidget {
  
  const BackButtonWidget( { super.key } );

  @override
  Widget build( BuildContext context ) {

    return TextButton.icon(
      onPressed: () => Navigator.pop( context ),
      label: PoppinsText(
        sText: TextsUtil.of(context)?.getText( 'create_account.back_button' ) ?? 'Back',
        dFontSize: ResponsiveApp.dSize( 13.0 ),
        colorText: ColorsApp.secondaryTextColor
      ),
      icon: Icon(
        Icons.arrow_back_rounded,
        color: ColorsApp.secondaryTextColor,
        size: ResponsiveApp.dSize( 24.0 ),
        semanticLabel: 'Back'
      )
    );

  }

}