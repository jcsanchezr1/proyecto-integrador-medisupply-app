import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../classes/user.dart';
import '../providers/login_provider.dart';

import '../utils/colors_app.dart';
import '../utils/responsive_app.dart';
import '../utils/slide_transition.dart';

import '../widgets/general_widgets/poppins_text.dart';

import 'home_page.dart';
import 'login_page.dart';

class SplashPage extends StatefulWidget {

  final bool skipDelay;
  final bool skipNavigation;
  
  const SplashPage( { super.key, this.skipDelay = false, this.skipNavigation = false } );

  @override
  State<SplashPage> createState() => _SplashPageState();

}

class _SplashPageState extends State<SplashPage> {

  initApp() async {

    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    final prefs = await SharedPreferences.getInstance();

    final accessToken = prefs.getString('accessToken');

    loginProvider.oUser = User(
      sAccessToken: accessToken,
      sRefreshToken: prefs.getString('refreshToken'),
      sName: prefs.getString('userName'),
      sEmail: prefs.getString('userEmail'),
      sRole: prefs.getString('userRole')
    );

    if (!widget.skipDelay) {
      await Future.delayed( const Duration( seconds: 3 ) );
    }

    if(!mounted) return;

    if (widget.skipNavigation) {
      return;
    }

    if( accessToken != null ) {
      Navigator.pushReplacement(
        context,
        SlidePageRoute( page: const HomePage() )
      );
    } else {
      Navigator.pushReplacement(
        context,
        SlidePageRoute( page: const LoginPage() )
      );
    }
  }

  @override
  void initState() {
    super.initState();
    initApp();
  }

  @override
  Widget build( BuildContext context ) {

    return Scaffold(
      backgroundColor: ColorsApp.primaryColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              "assets/images/white_logo.png",
              width: ResponsiveApp.dHeight( 80.0 ),
              height: ResponsiveApp.dHeight( 80.0 )
            ),
            SizedBox( height: ResponsiveApp.dHeight( 8.0 ) ),
            PoppinsText(
              sText: "MediSupply",
              dFontSize: ResponsiveApp.dSize( 16.0 ),
              colorText: ColorsApp.secondaryTextColor,
              fontWeight: FontWeight.w600
            )
          ]
        )
      )
    );

  }

}