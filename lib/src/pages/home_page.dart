import 'package:flutter/material.dart';

import '../utils/colors_app.dart';

import '../utils/responsive_app.dart';

import '../widgets/general_widgets/poppins_text.dart';
import '../widgets/general_widgets/drawer_menu_widget.dart';

class HomePage extends StatelessWidget {
  
  const HomePage(
    {
      super.key = const Key('home_page')
    }
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: DrawerMenuWidget(),
      appBar: AppBar(
        leading: Builder(
          builder: ( context ) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: Icon(
              Icons.menu_rounded,
              color: ColorsApp.secondaryColor,
              semanticLabel: 'Menu'
            )
          )
        ),
        title: PoppinsText(
          sText: 'MediSupply',
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor,
          fontWeight: FontWeight.w500
        ),
        backgroundColor: ColorsApp.backgroundColor,
        elevation: 0
      ),
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