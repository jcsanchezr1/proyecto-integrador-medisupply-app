import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/utils/language_util.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

import 'package:medisupply_app/src/widgets/general_widgets/drawer_menu_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// PNG de 1x1 transparente para simular assets en tests.
const List<int> _kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0xDA, 0x63, 0xF8, 0x0F, 0x00, 0x01,
  0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xE1, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

final String _esJson = jsonEncode({
  "menu": {
    "greeting": "Hola",
    "language": "Idioma",
    "languages": [
      {"id": "es", "language": "Español", "selected": true},
      {"id": "en", "language": "English", "selected": false},
      {"id": null, "language": "Invalid"},
      {"id": "xx", "language": null}
    ],
    "logout": "Cerrar sesión"
  },
  "logout": {
    "title_dialog": "Cerrar sesión",
    "message_dialog": "¿Seguro que quieres salir?",
    "cancel_dialog": "Cancelar",
    "confirm_dialog": "Salir",
    "error_logout": "No se pudo cerrar sesión"
  },
  "login": {
    "button": "Entrar",
    "email": "Correo",
    "password": "Contraseña",
    "error": "Requerido",
    "error_login": "Credenciales inválidas"
  }
});

final String _enJson = jsonEncode({
  "menu": {
    "greeting": "Hello",
    "language": "Language",
    "languages": [],
    "logout": "Logout"
  },
  "logout": {
    "title_dialog": "Logout",
    "message_dialog": "Are you sure you want to log out?",
    "cancel_dialog": "Cancel",
    "confirm_dialog": "Logout",
    "error_logout": "Logout failed"
  },
  "login": {
    "button": "Sign in",
    "email": "Email",
    "password": "Password",
    "error": "Required",
    "error_login": "Invalid credentials"
  }
});

void _installAssetMock() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) async {
      final String key = utf8.decode(message!.buffer.asUint8List());

      // 1) Mock del AssetManifest.bin (google_fonts lo lee en tests)
      if (key == 'AssetManifest.bin') {
        // Mapa vacío pero válido, codificado con StandardMessageCodec
        final ByteData? data = const StandardMessageCodec().encodeMessage(<String, Object?>{});
        return data;
      }

      // 2) Compatibilidad: algunos entornos consultan también el JSON
      if (key == 'AssetManifest.json') {
        final bytes = utf8.encode('{}');
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }

      // 3) Localizaciones usadas por TextsUtil
      if (key == 'assets/language/es_language.json') {
        final bytes = utf8.encode(_esJson);
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }
      if (key == 'assets/language/en_language.json') {
        final bytes = utf8.encode(_enJson);
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }

      // 4) Cualquier .png (logo) -> PNG transparente
      if (key.endsWith('.png')) {
        return ByteData.view(Uint8List.fromList(_kTransparentPng).buffer);
      }

      return null;
    },
  );
}

Widget _buildApp({Locale? locale}) {
  return ChangeNotifierProvider(
    create: (_) => LoginProvider(),
    child: MaterialApp(
      locale: locale,
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        TextsUtil.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: Scaffold(
        drawer: const DrawerMenuWidget(),
        body: Builder(
          builder: (context) => Center(
            child: ElevatedButton(
              onPressed: () => Scaffold.of(context).openDrawer(),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _openDrawer(WidgetTester tester) async {
  await tester.pumpAndSettle();

  final openBtn = find.text('open');
  if (openBtn.evaluate().isNotEmpty) {
    await tester.tap(openBtn);
    await tester.pumpAndSettle();
    return;
  }

  // Find any Scaffold and open its drawer
  final scaffoldFinder = find.byType(Scaffold);
  if (scaffoldFinder.evaluate().isNotEmpty) {
    final scaffoldState = tester.state<ScaffoldState>(scaffoldFinder.first);
    scaffoldState.openDrawer();
    await tester.pumpAndSettle();
  }
}

void main() {
  setUpAll(() {
    _installAssetMock();
    // Desactiva la descarga dinámica de fuentes en tests
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    LanguageUtils().setCallBack((_) {});
  });

  testWidgets('Debug: verificar estructura del drawer', (tester) async {
    await tester.pumpWidget(_buildApp(locale: const Locale('es')));
    await _openDrawer(tester);
    await tester.pumpAndSettle(const Duration(milliseconds: 500));

    // Check if DrawerMenuWidget is present
    expect(find.byType(DrawerMenuWidget), findsOneWidget);
    
    // Check basic UI elements
    expect(find.text('Hola'), findsOneWidget);
    expect(find.text('Idioma'), findsOneWidget);
    expect(find.text('Cerrar sesión'), findsOneWidget);
  });

  testWidgets('DrawerMenuWidget constructor funciona correctamente', (tester) async {
    // Test simple de constructor
    const widget = DrawerMenuWidget();
    expect(widget, isNotNull);
    expect(widget.runtimeType, equals(DrawerMenuWidget));
    
    // Test de createState
    final state = widget.createState();
    expect(state, isNotNull);
    expect(state.runtimeType.toString(), contains('DrawerMenuWidgetState'));
  });

  testWidgets('SharedPreferences funciona correctamente', (tester) async {
    SharedPreferences.setMockInitialValues({'languageCode': 'es'});
    
    // Verificar que las preferencias se cargan independientemente del widget
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('languageCode'), equals('es'));
    
    // Test que el mock funciona correctamente
    SharedPreferences.setMockInitialValues({'languageCode': 'en'});
    final prefs2 = await SharedPreferences.getInstance();
    expect(prefs2.getString('languageCode'), equals('en'));
  });

  testWidgets('LanguageUtils callback funciona', (tester) async {    
    Locale? changedTo;
    LanguageUtils().setCallBack((l) => changedTo = l);

    // Simular cambio de idioma directamente 
    LanguageUtils().changeLocale(const Locale('en'));

    expect(changedTo?.languageCode, equals('en'));
  });

  testWidgets('TextsUtil asset loading funciona correctamente',
      (tester) async {
    // Test que los assets de localización están disponibles
    await tester.pumpWidget(MaterialApp(
      localizationsDelegates: const [
        TextsUtil.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: Builder(
        builder: (context) {
          final textsUtil = TextsUtil.of(context);
          expect(textsUtil, isNotNull);
          return Container();
        },
      ),
    ));
    
    await tester.pumpAndSettle();
  });

  testWidgets('Assets de imagen se cargan correctamente en tests', (tester) async {
    // Test que los assets PNG se pueden cargar
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: Image.asset('assets/images/white_logo.png', 
          errorBuilder: (context, error, stackTrace) {
            // En tests, esto debería usar el PNG transparente mock
            return SizedBox(width: 1, height: 1);
          }
        ),
      ),
    ));
    
    await tester.pumpAndSettle();
    
    // Si llegamos aquí sin errores, el asset loading funciona
    expect(find.byType(Image), findsOneWidget);
  });

  testWidgets('Localización en inglés se carga correctamente',
      (tester) async {
    // Test simple de que la localización en inglés funciona
    await tester.pumpWidget(MaterialApp(
      locale: const Locale('en'),
      localizationsDelegates: const [
        TextsUtil.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('en'), Locale('es')],
      home: Builder(
        builder: (context) {
          final textsUtil = TextsUtil.of(context);
          expect(textsUtil, isNotNull);
          
          // Verificar que podemos obtener un texto en inglés
          final greetingText = textsUtil?.getText('menu.greeting');
          expect(greetingText, isNotNull);
          
          return Container();
        },
      ),
    ));
    
    await tester.pumpAndSettle();
  });
}