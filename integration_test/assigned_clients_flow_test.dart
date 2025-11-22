import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medisupply_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisupply_app/src/widgets/clients_widgets/client_card.dart';

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

  group('Assigned Clients Flow Integration Tests', () {
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

    testWidgets('Flujo completo: Login como Ventas -> Home -> Consulta de clientes asignados -> Ver detalle de cliente', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para splash

      // === PASO 1: LOGIN COMO USUARIO DE VENTAS ===
      const email = 'sergio.celis@gmail.com';
      const password = 'AugustoCelis13*';

      // Esperar campos de login
      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      // Verificar que estamos en login
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Llenar credenciales de usuario de ventas y hacer login
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Esperar procesamiento del login
      await tester.pump(const Duration(seconds: 3));

      // Verificar que NO hay SnackBar de error
      final errorSnackBar = find.byType(SnackBar);
      if (errorSnackBar.evaluate().isNotEmpty) {
        fail('Login falló con SnackBar de error: ${find.descendant(of: errorSnackBar, matching: find.byType(Text)).evaluate().first.widget.toString()}');
      }

      // Verificar que llegamos a HomePage
      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // === PASO 2: NAVEGAR A LA PESTAÑA DE CLIENTES ===
      // Verificar que estamos en la pestaña Orders por defecto
      expect(find.text('My orders'), findsOneWidget);

      // Navegar a la pestaña de Clients (índice 1)
      final clientsTab = find.byIcon(Icons.person_outline);
      expect(clientsTab, findsOneWidget);

      await tester.tap(clientsTab);
      await tester.pumpAndSettle();

      // Verificar que cambiamos a la pestaña de Clients
      expect(find.text('Clients'), findsOneWidget);

      // === PASO 3: VERIFICAR CONSULTA DE CLIENTES ASIGNADOS ===
      // Verificar que hay un indicador de carga inicialmente
      final initialLoading = find.byType(CircularProgressIndicator);
      if (initialLoading.evaluate().isNotEmpty) {
        // Si hay loading inicial, esperar que termine
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(CircularProgressIndicator), findsNothing);
      }

      // Esperar que se complete la carga de clientes
      await tester.pumpAndSettle();

      // Verificar que se muestra lista de clientes O mensaje de vacío
      final hasClients = find.byType(ClientCard).evaluate().isNotEmpty;
      final hasEmptyMessage = find.textContaining('No tienes clientes asignados').evaluate().isNotEmpty;

      expect(hasClients || hasEmptyMessage, isTrue,
        reason: 'Debería mostrar clientes asignados o mensaje de que no hay clientes asignados');

      if (hasClients) {
        // === PASO 4: HACER CLIC EN UN CLIENTE PARA VER DETALLE ===
        final clientCards = find.byType(ClientCard);
        expect(clientCards, findsWidgets);

        // Obtener el primer cliente de la lista
        final firstClientCard = clientCards.first;

        // Hacer clic en el primer cliente
        await tester.tap(firstClientCard);
        await tester.pumpAndSettle();

        // Verificar que navegamos a ClientDetailPage
        // La página de detalle debería contener información del cliente
        // Verificar que ya no estamos en la lista de clientes (no hay ClientCard visible)
        expect(find.byType(ClientCard), findsNothing);

        // Verificar que hay elementos típicos de una página de detalle
        // (puede variar según la implementación específica)
        final textWidgets = find.byType(Text);
        expect(textWidgets, findsWidgets,
          reason: 'La página de detalle debería contener texto con información del cliente');

        // Verificar que podemos volver atrás (hay un botón de back o similar)
        final backButton = find.byIcon(Icons.arrow_back);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();

          // Verificar que volvemos a la lista de clientes
          expect(find.byType(ClientCard), findsWidgets);
          expect(find.text('Clients'), findsOneWidget);
        }
      } else {
        // Si no hay clientes asignados, verificar el mensaje
        expect(find.textContaining('No Clients Assigned'), findsOneWidget);
      }
    });

    testWidgets('Usuario de Ventas puede acceder a pestaña de Clientes', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Login como usuario de ventas
      const email = 'medisupply05@gmail.com';
      const password = 'Admin123456';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Verificar login exitoso
      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // Verificar que el NavigationBar está presente (solo usuarios no-Cliente lo tienen)
      final navigationBar = find.byType(NavigationBar);
      expect(navigationBar, findsOneWidget);

      // Verificar que hay 3 destinos en el NavigationBar
      final destinations = find.descendant(of: navigationBar, matching: find.byType(NavigationDestination));
      expect(destinations, findsNWidgets(3));

      // Verificar que la pestaña de Clients está disponible
      expect(find.text('Clients'), findsOneWidget);
    });
  });
}