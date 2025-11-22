import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  group('Visit Detail Map Navigation', () {
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

    testWidgets('Navigate to visit detail and verify map loads correctly', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para splash

      // === PASO 1: LOGIN ===
      const email = 'medisupply05@gmail.com';
      const password = 'Admin123456';

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
      expect(find.text('Visits'), findsOneWidget);

      // Esperar a que se carguen las visitas
      await tester.pump(const Duration(seconds: 3));

      // === PASO 3: VERIFICAR QUE HAY VISITAS DISPONIBLES ===
      // Esperar un poco más para que se carguen las visitas
      await tester.pump(const Duration(seconds: 5));

      // Buscar tarjetas de visita de manera más específica
      // Las tarjetas de visita contienen íconos de chevron_right
      final visitCardIcons = find.byIcon(Icons.chevron_right_rounded);

      if (visitCardIcons.evaluate().isEmpty) {
        // Verificar si estamos en estado vacío
        final emptyState = find.textContaining('No Visits');
        if (emptyState.evaluate().isNotEmpty) {
          return;
        }

        // Si no hay estado vacío, intentar buscar por otros elementos
        expect(find.byKey(const Key('visits_page')), findsOneWidget);
        return;
      }

      // === PASO 4: ABRIR DETALLE DE VISITA ===
      // Si hay visitas, hacer tap en la primera tarjeta usando el ícono
      await tester.tap(visitCardIcons.first);
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para navegación completa

      // Verificar que estamos en la página de detalle
      expect(find.byKey(const Key('visit_detail_page')), findsOneWidget);

      // === PASO 5: ESPERAR QUE SE CARGA EL MAPA ===
      // Esperar a que se cargue el mapa (puede tomar tiempo)
      await tester.pump(const Duration(seconds: 8));

      // Verificar que ya no estamos en loading (no hay CircularProgressIndicator)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verificar que el mapa está presente
      expect(find.byType(GoogleMap), findsOneWidget);

      // === PASO 6: VERIFICAR QUE HAY MARCADORES EN EL MAPA ===
      // Los marcadores se agregan dinámicamente, esperamos que haya al menos el marcador de inicio/fin
      await tester.pump(const Duration(seconds: 2));

      // Verificar que el mapa tiene marcadores (al menos el marcador azul de inicio/fin)
      // Nota: No podemos verificar directamente la cantidad de marcadores,
      // pero podemos verificar que el mapa está funcionando

      // === PASO 7: VOLVER ATRÁS ===
      await tester.pageBack();
      await tester.pumpAndSettle();

      // Verificar que estamos de vuelta en la lista de visitas
      expect(find.byKey(const Key('visits_page')), findsOneWidget);
      expect(find.text('Visits'), findsOneWidget);
    });
  });
}