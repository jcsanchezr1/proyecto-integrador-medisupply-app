import 'package:flutter/material.dart';

import '../utils/colors_app.dart';
import '../utils/responsive_app.dart';

import '../widgets/general_widgets/poppins_text.dart';

class HomePage extends StatelessWidget {
  const HomePage(
    {
      super.key = const Key('home_page')
    }
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: PoppinsText(
          sText: 'Bienvenido a MediSupply',
          dFontSize: ResponsiveApp.dSize( 14.0 ),
          colorText: ColorsApp.textColor
        )
      )
    );
  }
}