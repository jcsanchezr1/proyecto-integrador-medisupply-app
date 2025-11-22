import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import '../providers/login_provider.dart';

import '../utils/colors_app.dart';
import '../utils/texts_util.dart';
import '../utils/responsive_app.dart';

import '../widgets/general_widgets/poppins_text.dart';
import '../widgets/general_widgets/drawer_menu_widget.dart';

import 'orders_pages/orders_page.dart';
import 'visits_pages/visits_page.dart';
import 'clients_pages/clients_page.dart';

class HomePage extends StatefulWidget {
  
  const HomePage( { super.key = const Key('home_page') } );

  @override
  State<HomePage> createState() => _HomePageState();
  
}

class _HomePageState extends State<HomePage> {

  int iIndexNavigation = 0;

  List<Widget> lPages = [ const OrdersPage(), ClientsPage(), VisitsPage() ];

  @override
  Widget build( BuildContext context ) {

    final loginProvider = Provider.of<LoginProvider>( context );

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
          sText: TextsUtil.of(context)?.getText(
            iIndexNavigation == 0 ? 'orders.title' : iIndexNavigation == 1 ? 'clients.title' : 'visits.title'
          ) ?? 'Home',
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor,
          fontWeight: FontWeight.w500
        ),
        backgroundColor: ColorsApp.backgroundColor,
        elevation: 0.0,
        scrolledUnderElevation: 0.0
      ),
      bottomNavigationBar: loginProvider.oUser!.sRole == 'Cliente' ? null : NavigationBar(
        onDestinationSelected: (int index) {
          setState( () => iIndexNavigation = index );
        },
        backgroundColor: ColorsApp.backgroundColor,
        selectedIndex: iIndexNavigation,
        indicatorColor: ColorsApp.secondaryColor,
        labelTextStyle: WidgetStateProperty.all<TextStyle>(
          GoogleFonts.poppins(
            fontSize: ResponsiveApp.dSize( 12.0 ),
            color: ColorsApp.textColor,
            fontWeight: FontWeight.w500
          )
        ),
        destinations: [
          NavigationDestination(
            selectedIcon: Icon( Icons.local_shipping_outlined, color: ColorsApp.secondaryTextColor, size: ResponsiveApp.dSize( 24.0 ) ),
            icon: Icon( Icons.local_shipping_outlined, color: ColorsApp.textColor, size: ResponsiveApp.dSize( 24.0 ) ),
            label: TextsUtil.of(context)?.getText( 'tabs.orders' ) ?? 'Orders'
          ),
          NavigationDestination(
            selectedIcon: Icon( Icons.person_outline, color: ColorsApp.secondaryTextColor, size: ResponsiveApp.dSize( 24.0 ) ),
            icon: Icon( Icons.person_outline, color: ColorsApp.textColor, size: ResponsiveApp.dSize( 24.0 ) ),
            label: TextsUtil.of(context)?.getText( 'tabs.clients' ) ?? 'Clients'
          ),
          NavigationDestination(
            selectedIcon: Icon( Icons.groups_outlined, color: ColorsApp.secondaryTextColor, size: ResponsiveApp.dSize( 24.0 ) ),
            icon: Icon( Icons.groups_outlined, color: ColorsApp.textColor, size: ResponsiveApp.dSize( 24.0 ) ),
            label: TextsUtil.of(context)?.getText( 'tabs.visits' ) ?? 'Visits'
          )
        ]
      ),
      body: lPages.elementAt( iIndexNavigation )
    );
  }
}