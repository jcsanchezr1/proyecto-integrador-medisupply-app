import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medisupply_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

  group('Login Flow Integration', () {
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test para evitar auto-login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    tearDown(() async {
      // Limpiar SharedPreferences después de cada test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Login exitoso navega a HomePage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para el splash

      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      // Esperar a que aparezcan los campos de login
      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Llenar campos de login
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);

      // Verificar que el email se ingresó correctamente (el password puede mostrarse en tests)
      expect(find.text(email), findsOneWidget);

      // Hacer tap en el botón de login
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Esperar un poco más para que el login se procese
      await tester.pump(const Duration(seconds: 3));

      // Verificar si hay un SnackBar de error (login fallido)
      final errorSnackBar = find.byType(SnackBar);
      if (errorSnackBar.evaluate().isNotEmpty) {
        fail('Login falló con SnackBar de error: ${find.descendant(of: errorSnackBar, matching: find.byType(Text)).evaluate().first.widget.toString()}');
      }

      // Intentar encontrar la HomePage con más paciencia
      try {
        await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150); // Más intentos
        expect(find.byKey(const Key('home_page')), findsOneWidget);
      } catch (e) {
        // Si no encuentra la HomePage, verificar qué página estamos viendo actualmente
        final currentPageText = find.byType(Text).evaluate();
        final currentWidgets = currentPageText.map((element) => element.widget.toString()).toList();
        fail('No se pudo encontrar HomePage. Widgets de texto visibles: $currentWidgets');
      }

      // Verificar que los elementos de la HomePage están presentes
      expect(find.text('Orders'), findsOneWidget); // Título de la app bar
      expect(find.byType(NavigationBar), findsOneWidget); // Bottom navigation bar
    });

    testWidgets('Login fallido muestra SnackBar de error', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('email_field')), 'test@mail.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpass');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await waitForWidget(tester, find.byType(SnackBar));
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });


}
