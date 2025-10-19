import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medisupply_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisupply_app/src/widgets/oder_widgets/order_card.dart';

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

  group('Orders Flow Integration Tests', () {
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

    testWidgets('Flujo completo: Login -> Home -> Consulta de pedidos en OrdersPage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para splash

      // === PASO 1: LOGIN ===
      const email = 'ventas@correo.com';
      const password = 'Password123.';

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

      // === PASO 2: VERIFICAR ORDERS PAGE ===
      // Verificar que estamos en la pestaña Orders (debería ser la primera por defecto)
      expect(find.text('Orders'), findsOneWidget);

      // Verificar que el FloatingActionButton está presente (indica que estamos en OrdersPage)
      await waitForWidget(tester, find.byType(FloatingActionButton));
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Verificar que el FAB tiene el ícono de agregar
      final fab = tester.widget<FloatingActionButton>(find.byType(FloatingActionButton));
      expect(fab.child, isA<Icon>());
      final icon = fab.child as Icon;
      expect(icon.icon, equals(Icons.add_rounded));

      // === PASO 3: VERIFICAR CONSULTA DE PEDIDOS ===
      // La consulta puede ser rápida, verificar estado inicial o loading
      final initialLoading = find.byType(CircularProgressIndicator);

      if (initialLoading.evaluate().isNotEmpty) {
        // Si hay loading inicial, esperar que termine
        await tester.pump(const Duration(seconds: 5));
        expect(find.byType(CircularProgressIndicator), findsNothing);
      }

      // Verificar que ya no hay loading después de la consulta
      await tester.pumpAndSettle();

      // Verificar que se muestra lista de pedidos O mensaje de vacío
      final hasOrders = find.byType(OrderCard).evaluate().isNotEmpty;
      final hasEmptyMessage = find.textContaining('No Products Available').evaluate().isNotEmpty ||
                             find.textContaining('No orders').evaluate().isNotEmpty;

      // Debería tener pedidos O mostrar mensaje de vacío
      expect(hasOrders || hasEmptyMessage, true,
          reason: 'Debería mostrar pedidos o mensaje indicando que no hay pedidos disponibles');

      if (hasOrders) {
        // Si hay pedidos, verificar estructura
        expect(find.byType(ListView), findsOneWidget);
        expect(find.byType(OrderCard), findsWidgets,
            reason: 'Debería haber al menos una OrderCard si hay pedidos');

        // Verificar que podemos hacer scroll si hay muchos pedidos
        final scrollable = find.byType(Scrollable);
        if (scrollable.evaluate().isNotEmpty) {
          await tester.drag(scrollable.first, const Offset(0, -200)); // Scroll vertical
          await tester.pumpAndSettle();

          // Verificar que la página sigue funcionando después del scroll
          expect(find.byType(FloatingActionButton), findsOneWidget);
        }
      } else {
        // Si no hay pedidos, verificar mensaje de vacío
        expect(find.byType(ListView), findsNothing,
            reason: 'No debería haber ListView si no hay pedidos');
      }
    });

    testWidgets('Consulta de pedidos con usuario cliente', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN CON USUARIO CLIENTE ===
      const email = 'hospital.universitario@gmail.com'; // Usuario cliente
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Verificar login exitoso
      final errorSnackBar = find.byType(SnackBar);
      if (errorSnackBar.evaluate().isNotEmpty) {
        fail('Login falló con SnackBar de error');
      }

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // === VERIFICAR CONSULTA DE PEDIDOS PARA CLIENTE ===
      expect(find.text('Orders'), findsOneWidget);
      await waitForWidget(tester, find.byType(FloatingActionButton));
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Esperar que se complete la consulta de pedidos (puede haber loading o no)
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verificar que ya no hay loading (si lo había)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verificar resultados para cliente - debería mostrar pedidos o mensaje vacío
      final hasOrders = find.byType(OrderCard).evaluate().isNotEmpty;
      final hasEmptyMessage = find.textContaining('No Products Available').evaluate().isNotEmpty ||
                             find.textContaining('No orders').evaluate().isNotEmpty;

      expect(hasOrders || hasEmptyMessage, true,
          reason: 'Cliente debería ver sus pedidos o mensaje de vacío');

      // Verificar que la página sigue siendo funcional
      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('Navegación y interacción en OrdersPage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'ventas@correo.com';
      const password = 'Password123.';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === VERIFICAR FUNCIONALIDAD DEL FAB ===
      await waitForWidget(tester, find.byType(FloatingActionButton));
      final fab = find.byType(FloatingActionButton);

      // El FAB debería navegar a NewOrderPage
      await tester.tap(fab);
      await tester.pumpAndSettle();

      // Verificar que navegamos a NewOrderPage
      expect(find.byKey(const Key('new_order_page')), findsOneWidget);

      // Volver atrás
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Deberíamos volver a OrdersPage
        expect(find.byType(FloatingActionButton), findsOneWidget);
      }
    });

    testWidgets('Manejo de errores en consulta de pedidos', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'ventas@correo.com';
      const password = 'Password123.';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === VERIFICAR QUE LA PÁGINA MANEJA ERRORES GRACEFULMENTE ===
      // Si hay un error en la consulta, debería mostrar mensaje vacío en lugar de crashear
      await waitForWidget(tester, find.byType(FloatingActionButton));

      // Esperar que termine la consulta (éxito o error)
      await tester.pump(const Duration(seconds: 5));

      // La página debería seguir funcional incluso si hay error
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // No debería haber indicadores de carga infinitos
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });
  });
}