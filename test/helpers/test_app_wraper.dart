import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';

Widget createTestApp(Widget child) {
  return MediaQuery(
    data: const MediaQueryData(size: Size(1080, 1920)),
    child: MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginProvider()),
      ],
      child: MaterialApp(
        home: child,
        locale: const Locale('es', 'ES'),
        localizationsDelegates: [
          TextsUtil.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('es', 'ES'),
        ],
      ),
    ),
  );
}
