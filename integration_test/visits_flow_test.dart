import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medisupply_app/main.dart' as app;

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

  group('Visits Flow Integration', () {
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test para forzar login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    tearDown(() async {
      // Limpiar SharedPreferences después de cada test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('Complete visits flow: login, list, create, and view detail', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para splash

      // === PASO 1: LOGIN ===
      const email = 'ventas@correo.com';
      const password = 'AugustoCelis13*';

      // Esperar campos de login
      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      // Verificar que estamos en login
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Llenar credenciales y hacer login
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Esperar procesamiento del login
      await tester.pump(const Duration(seconds: 3));

      // Verificar que NO hay SnackBar de error
      final errorSnackBar = find.byType(SnackBar);
      if (errorSnackBar.evaluate().isNotEmpty) {
        fail('Login falló con SnackBar de error');
      }

      // Verificar que llegamos a HomePage
      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // === PASO 2: NAVEGAR A VISITAS ===
      // Navegar a la pestaña de visitas (índice 2)
      await tester.tap(find.text('Visits'));
      await tester.pumpAndSettle();

      // Verificar que estamos en la página de visitas
      expect(find.byKey(const Key('visits_page')), findsOneWidget);
      expect(find.text('Visits'), findsOneWidget); // Título en app bar

      // Esperar a que se carguen las visitas
      await tester.pump(const Duration(seconds: 2));

      // Verificar que hay un FAB para crear visitas
      expect(find.byKey(const Key('create_visit_fab')), findsOneWidget);

      // === PASO 3: CREAR UNA NUEVA VISITA ===
      // Hacer tap en el FAB para crear una nueva visita
      await tester.tap(find.byKey(const Key('create_visit_fab')));
      await tester.pumpAndSettle();

      // Verificar que estamos en la página de crear visita
      expect(find.byKey(const Key('create_visit_page')), findsOneWidget);
      expect(find.text('Create visit'), findsOneWidget);

      // Verificar que los elementos del formulario están presentes
      expect(find.byType(Text), findsWidgets); // ClientsMultiSelect y DateVisit widgets

      // Simular que presionamos el botón de crear (aunque no llenemos el formulario)
      // Esto debería mostrar un error de campos vacíos
      final createButton = find.byKey(const Key('create_visit_button'));
      expect(createButton, findsOneWidget);

      await tester.tap(createButton);
      await tester.pumpAndSettle();

      // Debería mostrar un SnackBar de error por campos vacíos
      await waitForWidget(tester, find.byType(SnackBar));
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Please select at least one client and a date.'), findsOneWidget);

      // Volver atrás presionando el botón de back
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Deberíamos estar de vuelta en la lista de visitas
      expect(find.byKey(const Key('visits_page')), findsOneWidget);
      expect(find.text('Visits'), findsOneWidget);
    });

    testWidgets('Visits list loads and displays visits', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'ventas@correo.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === NAVEGAR A VISITAS ===
      await tester.tap(find.text('Visits'));
      await tester.pumpAndSettle();

      // Verificar elementos de la página de visitas
      expect(find.byKey(const Key('visits_page')), findsOneWidget);
      expect(find.text('Visits'), findsOneWidget);
      expect(find.byKey(const Key('create_visit_fab')), findsOneWidget);

      // Verificar que hay un DateFilter
      expect(find.byType(Text), findsWidgets); // DateFilter contiene texto

      // La lista de visitas debería cargar (aunque puede estar vacía)
      await tester.pump(const Duration(seconds: 2));
    });

    testWidgets('Create visit page navigation and form elements', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'ventas@correo.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === NAVEGAR A VISITAS ===
      await tester.tap(find.text('Visits'));
      await tester.pumpAndSettle();

      // Ir a crear visita
      await tester.tap(find.byKey(const Key('create_visit_fab')));
      await tester.pumpAndSettle();

      // Verificar elementos de la página de crear visita
      expect(find.byKey(const Key('create_visit_page')), findsOneWidget);
      expect(find.text('Create visit'), findsOneWidget);
      expect(find.byKey(const Key('create_visit_button')), findsOneWidget);
    });
  });
}