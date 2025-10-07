import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:medisupply_app/src/pages/login_page.dart';

import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/utils/language_util.dart';
import 'package:medisupply_app/src/utils/responsive_app.dart';

Locale _getDeviceLocale() {
  
  final String sLanguageCode = PlatformDispatcher.instance.locale.languageCode;

  if ( sLanguageCode.startsWith( 'es' ) ) {
    return Locale( 'es', 'CO' );
  } else {
    return Locale( 'en', 'US' );
  }

}

Future<Locale> _getInitialLocale() async {

  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? savedLanguageCode = prefs.getString('languageCode');

  if (savedLanguageCode != null) {
    return Locale(savedLanguageCode);
  }

  return _getDeviceLocale();

}

void main() async {

  WidgetsFlutterBinding.ensureInitialized();
  
  Locale deviceLocale = await _getInitialLocale();

  SystemChrome.setSystemUIOverlayStyle(
    SystemUiOverlayStyle(
      statusBarColor: Colors.transparent
    )
  );

  runApp( MyApp( locale: deviceLocale ) );

}

class MyApp extends StatefulWidget {

  final Locale? locale;
  
  const MyApp( { super.key, this.locale } );

  @override
  State<MyApp> createState() => _MyAppState();

}

class _MyAppState extends State<MyApp> {

  late Locale _currentLocale;

  @override
  void initState() {
    super.initState();
    _currentLocale = widget.locale!;
    LanguageUtils().setCallBack( setLocale );
  }

  void setLocale( Locale locale ) => setState( () => _currentLocale = locale );

  @override
  void didChangeDependencies() {
    
    ResponsiveApp.init(context, 360, 800);

    if (ResponsiveApp.bTablet()) {
      ResponsiveApp.init(context, 900, 1220);
    }

    List<DeviceOrientation> lOrientations = ResponsiveApp.bTablet() ? [
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ] : [
      DeviceOrientation.portraitUp
    ];

    SystemChrome.setPreferredOrientations(lOrientations);

    super.didChangeDependencies();

  }

  @override
  Widget build( BuildContext context ) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'MediSupply',
      home: const LoginPage(),
      theme: ThemeData(
        scaffoldBackgroundColor: ColorsApp.backgroundColor,
        textSelectionTheme: TextSelectionThemeData(
          cursorColor: ColorsApp.secondaryColor,
          selectionColor: ColorsApp.primaryColor.withValues( alpha: 0.2 ),
          selectionHandleColor: ColorsApp.primaryColor
        )
      ),
      locale: _currentLocale,
      localizationsDelegates: [
        TextsUtil.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate
      ],
      supportedLocales: [const Locale('en', 'US'), const Locale('es', 'CO')]
    );

  }

}