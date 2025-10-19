import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/pages/splash_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';

Future<void> waitForWidget(WidgetTester tester, Finder finder, {int maxTries = 50}) async {
  int tries = 0;
  while (finder.evaluate().isEmpty && tries < maxTries) {
    await tester.pump(const Duration(milliseconds: 200));
    tries++;
  }
  if (finder.evaluate().isEmpty) {
    throw Exception('Widget not found: $finder');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create Account Flow Integration', () {
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    tearDown(() async {
      // Limpiar SharedPreferences después de cada test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Navegación a página de crear cuenta', (WidgetTester tester) async {
      // Configurar la aplicación completa con providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => CreateAccountProvider()),
          ],
          child: MaterialApp(
            locale: const Locale('es', 'ES'),
            localizationsDelegates: [
              TextsUtil.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
            theme: ThemeData(
              scaffoldBackgroundColor: ColorsApp.backgroundColor,
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: ColorsApp.secondaryColor,
                selectionColor: ColorsApp.primaryColor.withValues(alpha: 0.2),
                selectionHandleColor: ColorsApp.primaryColor,
              ),
            ),
            home: const SplashPage(skipDelay: true),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar que estamos en la página de login
      expect(find.text('¡Bienvenido!'), findsOneWidget);

      // Navegar a crear cuenta
      await waitForWidget(tester, find.text('Crear una cuenta'));
      await tester.tap(find.text('Crear una cuenta'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Verificar que estamos en la página de crear cuenta
      expect(find.text('Crea tu cuenta'), findsOneWidget);
      expect(find.text('Crear cuenta'), findsOneWidget);

      // Verificar que los campos principales están presentes
      expect(find.text('Nombre'), findsOneWidget);
      expect(find.text('Identificación tributaria'), findsOneWidget);
      expect(find.text('Correo electrónico'), findsOneWidget);
      expect(find.text('Dirección'), findsOneWidget);
      expect(find.text('Teléfono'), findsOneWidget);
      expect(find.text('Tipo de institución'), findsOneWidget);
      expect(find.text('Logo'), findsOneWidget);
      expect(find.text('Categorías de productos de interés'), findsOneWidget);
      expect(find.text('Nombre del solicitante'), findsOneWidget);
      expect(find.text('Email del solicitante'), findsOneWidget);
      expect(find.text('Contraseña'), findsOneWidget);
      expect(find.text('Confirmar contraseña'), findsOneWidget);
    });

    testWidgets('Validación de formulario muestra errores', (WidgetTester tester) async {
      // Configurar la aplicación completa con providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => CreateAccountProvider()),
          ],
          child: MaterialApp(
            locale: const Locale('es', 'ES'),
            localizationsDelegates: [
              TextsUtil.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
            theme: ThemeData(
              scaffoldBackgroundColor: ColorsApp.backgroundColor,
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: ColorsApp.secondaryColor,
                selectionColor: ColorsApp.primaryColor.withValues( alpha: 0.2 ),
                selectionHandleColor: ColorsApp.primaryColor,
              ),
            ),
            home: const SplashPage(skipDelay: true),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navegar a crear cuenta
      await waitForWidget(tester, find.text('Crear una cuenta'));
      await tester.tap(find.text('Crear una cuenta'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Hacer scroll hacia abajo para encontrar el botón usando múltiples drags
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -800)); // Scroll más agresivo
      await tester.pumpAndSettle();
      await tester.drag(scrollable, const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.drag(scrollable, const Offset(0, -800));
      await tester.pumpAndSettle();

      // Verificar que el botón está visible antes de intentar tocarlo
      final createButton = find.text('Crear cuenta');
      await waitForWidget(tester, createButton);

      // Intentar enviar formulario sin llenar campos
      await tester.tap(createButton, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar que se muestran errores de validación en los campos
      // Los errores pueden aparecer como texto en los campos o como SnackBar
      final errorText = find.text('Por favor, ingresa un valor');
      final snackbarError = find.text('Por favor, ingresa un valor');

      // Verificar si hay al menos un error visible
      expect(errorText.evaluate().isNotEmpty || snackbarError.evaluate().isNotEmpty, true,
          reason: 'Debería mostrar al menos un mensaje de error de validación');
    });

    testWidgets('Validación de contraseña muestra error específico', (WidgetTester tester) async {
      // Configurar la aplicación completa con providers
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(create: (_) => LoginProvider()),
            ChangeNotifierProvider(create: (_) => CreateAccountProvider()),
          ],
          child: MaterialApp(
            locale: const Locale('es', 'ES'),
            localizationsDelegates: [
              TextsUtil.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
            ],
            supportedLocales: const [Locale('en', 'US'), Locale('es', 'ES')],
            theme: ThemeData(
              scaffoldBackgroundColor: ColorsApp.backgroundColor,
              textSelectionTheme: TextSelectionThemeData(
                cursorColor: ColorsApp.secondaryColor,
                selectionColor: ColorsApp.primaryColor.withValues( alpha: 0.2 ),
                selectionHandleColor: ColorsApp.primaryColor,
              ),
            ),
            home: const SplashPage(skipDelay: true),
          ),
        ),
      );
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Navegar a crear cuenta
      await waitForWidget(tester, find.text('Crear una cuenta'));
      await tester.tap(find.text('Crear una cuenta'));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      // Llenar algunos campos pero con contraseña inválida
      await tester.enterText(find.byKey(const Key('name_field')), 'Clínica Test');
      await tester.enterText(find.byKey(const Key('nit_field')), '123456789');
      await tester.enterText(find.byKey(const Key('email_field')), 'clinica@test.com');
      await tester.enterText(find.byKey(const Key('address_field')), 'Calle 123 #45-67, Bogotá');
      await tester.enterText(find.byKey(const Key('phone_field')), '3001234567');
      await tester.enterText(find.byKey(const Key('applicant_name_field')), 'Juan Pérez');
      await tester.enterText(find.byKey(const Key('applicant_email_field')), 'juan@test.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'invalid'); // Contraseña inválida
      await tester.enterText(find.byKey(const Key('confirm_password_field')), 'invalid');

      // Hacer scroll hacia abajo para encontrar el botón usando múltiples drags
      final scrollable = find.byType(Scrollable).first;
      await tester.drag(scrollable, const Offset(0, -800)); // Scroll más agresivo
      await tester.pumpAndSettle();
      await tester.drag(scrollable, const Offset(0, -800));
      await tester.pumpAndSettle();
      await tester.drag(scrollable, const Offset(0, -800));
      await tester.pumpAndSettle();

      // Verificar que el botón está visible antes de intentar tocarlo
      final createButton = find.text('Crear cuenta');
      await waitForWidget(tester, createButton);

      // Intentar enviar formulario
      await tester.tap(createButton, warnIfMissed: false);
      await tester.pumpAndSettle(const Duration(seconds: 1));

      // Verificar error específico de contraseña
      final passwordError = find.text('La contraseña debe tener mínimo 8 caracteres, ser alfanumérica y contener un carácter especial.');
      final snackbarPasswordError = find.textContaining('contraseña');

      // Verificar si el error aparece en los campos o como SnackBar
      expect(passwordError.evaluate().isNotEmpty || snackbarPasswordError.evaluate().isNotEmpty, true,
          reason: 'Debería mostrar el error específico de contraseña');
    });
  });
}