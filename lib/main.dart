import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:medisupply_app/src/pages/splash_page.dart';

import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/utils/language_util.dart';
import 'package:medisupply_app/src/utils/responsive_app.dart';

import 'src/providers/order_provider.dart';
import 'src/providers/login_provider.dart';
import 'src/providers/create_visit_provider.dart';
import 'src/providers/create_account_provider.dart';

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

  await dotenv.load(fileName: ".env");
  
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider( create: ( _ ) => LoginProvider() ),
        ChangeNotifierProvider( create: ( _ ) => CreateAccountProvider() ),
        ChangeNotifierProvider( create: ( _ ) => OrderProvider() ),
        ChangeNotifierProvider( create: ( _ ) => CreateVisitProvider() )
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'MediSupply',
        home: const SplashPage(),
        theme: ThemeData(
          scaffoldBackgroundColor: ColorsApp.backgroundColor,
          textSelectionTheme: TextSelectionThemeData(
            cursorColor: ColorsApp.secondaryColor,
            selectionColor: ColorsApp.primaryColor.withValues( alpha: 0.2 ),
            selectionHandleColor: ColorsApp.primaryColor
          ),
          colorScheme: ColorScheme.light( primary: ColorsApp.primaryColor ),
        ),
        locale: _currentLocale,
        localizationsDelegates: [
          TextsUtil.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate
        ],
        supportedLocales: [const Locale('en', 'US'), const Locale('es', 'ES')]
      )
    );

  }

}