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

  group('Order Detail Flow Integration Tests', () {
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

    testWidgets('Flujo completo: Login -> Orders -> Detalle de pedido', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para splash

      // === PASO 1: LOGIN ===
      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      // Esperar campos de login
      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      // Llenar credenciales y hacer login
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      // Verificar que NO hay SnackBar de error
      final errorSnackBar = find.byType(SnackBar);
      if (errorSnackBar.evaluate().isNotEmpty) {
        fail('Login falló con SnackBar de error');
      }

      // Verificar que llegamos a HomePage
      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);
      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // === PASO 2: NAVEGAR A ORDERS PAGE ===
      expect(find.text('Orders'), findsOneWidget);
      await waitForWidget(tester, find.byType(FloatingActionButton));
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // Esperar que se complete la consulta de pedidos
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verificar que ya no hay loading
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // === PASO 3: VERIFICAR QUE HAY PEDIDOS DISPONIBLES ===
      final orderCards = find.byType(GestureDetector); // OrderCard usa GestureDetector
      expect(orderCards, findsWidgets,
          reason: 'Debería haber al menos un pedido disponible para consultar detalle');

      // === PASO 4: NAVEGAR AL DETALLE DEL PRIMER PEDIDO ===
      final firstOrderCard = orderCards.first;
      await tester.tap(firstOrderCard);
      await tester.pumpAndSettle();

      // Verificar que navegamos a OrderDetailPage
      // OrderDetailPage tiene un AppBar con el número de orden
      await waitForWidget(tester, find.byType(AppBar), maxTries: 100);
      expect(find.byType(AppBar), findsOneWidget);

      // Verificar que el AppBar tiene un título (número de orden)
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.title, isNotNull);

      // Verificar que el título contiene un número de orden (ORD-...)
      // El título puede ser Text, PoppinsText, o cualquier otro widget
      final titleWidget = appBar.title!;
      String? titleText;

      if (titleWidget is Text) {
        titleText = titleWidget.data;
      } else {
        // Buscar texto dentro del widget del título
        final titleElement = find.descendant(
          of: find.byWidget(titleWidget),
          matching: find.byType(Text)
        );

        if (titleElement.evaluate().isNotEmpty) {
          titleText = (titleElement.evaluate().first.widget as Text).data;
        }
      }

      expect(titleText, isNotNull);
      expect(titleText!.startsWith('ORD-') || titleText.startsWith('PED-'), true,
          reason: 'El título del AppBar debería contener un número de orden que empiece con ORD- o PED-');

      // === PASO 5: VERIFICAR CONTENIDO DEL DETALLE ===
      // Verificar que se muestra OrderBadge con status
      final richTextWidgets = find.byWidgetPredicate(
        (widget) => widget is RichText,
        description: 'RichText widgets (usados por OrderInfoItem)'
      );
      expect(richTextWidgets, findsWidgets,
          reason: 'Debería haber RichText widgets mostrando información del pedido');

      // Verificar que se muestra información de productos
      expect(find.text('Products'), findsOneWidget,
          reason: 'Debería mostrar la sección de productos');

      // Verificar que hay una lista de productos (ListView)
      expect(find.byType(ListView), findsOneWidget,
          reason: 'Debería haber un ListView mostrando los productos del pedido');

      // === PASO 6: PROBAR NAVEGACIÓN DE VUELTA ===
      // Buscar botón de back en el AppBar
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();

        // Verificar que volvemos a OrdersPage
        expect(find.byType(FloatingActionButton), findsOneWidget,
            reason: 'Deberíamos volver a OrdersPage con el FAB visible');
        expect(find.text('Orders'), findsOneWidget,
            reason: 'Deberíamos estar de vuelta en la pestaña Orders');
      } else {
        // Si no hay BackButton, intentar usar el leading del AppBar
        final appBarWidget = tester.widget<AppBar>(find.byType(AppBar));
        if (appBarWidget.leading != null) {
          final leadingButton = find.byWidget(appBarWidget.leading!);
          await tester.tap(leadingButton);
          await tester.pumpAndSettle();

          // Verificar que volvemos a OrdersPage
          expect(find.byType(FloatingActionButton), findsOneWidget);
          expect(find.text('Orders'), findsOneWidget);
        }
      }
    });

    testWidgets('Consulta de detalle con pedido específico', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === NAVEGAR A ORDERS ===
      await waitForWidget(tester, find.byType(FloatingActionButton));
      await tester.pump(const Duration(seconds: 5));

      // === BUSCAR PEDIDO ESPECÍFICO ===
      final orderCards = find.byType(GestureDetector);

      if (orderCards.evaluate().isNotEmpty) {
        // Buscar un pedido específico si existe
        final orderTexts = find.byWidgetPredicate(
          (widget) => widget is RichText && (widget.text.toPlainText().contains('ORD-') || widget.text.toPlainText().contains('PED-')),
          description: 'Text widgets containing order numbers'
        );

        if (orderTexts.evaluate().isNotEmpty) {
          // Tocar en el primer pedido encontrado
          await tester.tap(orderCards.first);
          await tester.pumpAndSettle();

          // Verificar que se carga el detalle
          await waitForWidget(tester, find.byType(AppBar));
          expect(find.byType(AppBar), findsOneWidget);

          // Verificar elementos específicos del detalle
          expect(find.text('Products'), findsOneWidget);
          expect(find.byType(ListView), findsOneWidget);
        }
      }
    });

    testWidgets('Navegación de vuelta desde detalle de pedido', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === NAVEGAR A ORDERS ===
      await waitForWidget(tester, find.byType(FloatingActionButton));
      await tester.pump(const Duration(seconds: 5));

      final orderCards = find.byType(GestureDetector);

      if (orderCards.evaluate().isNotEmpty) {
        // === IR AL DETALLE ===
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle();

        await waitForWidget(tester, find.byType(AppBar));

        // === PROBAR MÚLTIPLES FORMAS DE VOLVER ===
        // 1. Intentar botón de back del sistema
        final backButton = find.byType(BackButton);
        if (backButton.evaluate().isNotEmpty) {
          await tester.tap(backButton);
          await tester.pumpAndSettle();

          // Verificar que volvemos
          expect(find.byType(FloatingActionButton), findsOneWidget);
        } else {
          // 2. Intentar gesture de swipe back (iOS)
          await tester.pageBack();
          await tester.pumpAndSettle();

          // Verificar que la navegación funciona
          final stillInDetail = find.byType(AppBar).evaluate().isNotEmpty;
          if (stillInDetail) {
            // Si aún estamos en detalle, intentar otra forma
            final appBarWidget = tester.widget<AppBar>(find.byType(AppBar));
            if (appBarWidget.leading != null) {
              final leadingFinder = find.byWidget(appBarWidget.leading!);
              await tester.tap(leadingFinder);
              await tester.pumpAndSettle();
            }
          }

          // Verificar que eventualmente volvemos a Orders
          expect(find.byType(FloatingActionButton), findsOneWidget);
        }
      }
    });

    testWidgets('Manejo de errores al cargar detalle de pedido', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN ===
      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === NAVEGAR A ORDERS ===
      await waitForWidget(tester, find.byType(FloatingActionButton));
      await tester.pump(const Duration(seconds: 5));

      final orderCards = find.byType(GestureDetector);

      if (orderCards.evaluate().isNotEmpty) {
        // === IR AL DETALLE ===
        await tester.tap(orderCards.first);
        await tester.pumpAndSettle();

        // === VERIFICAR QUE LA PÁGINA MANEJA ERRORES ===
        // La página debería cargar correctamente o mostrar mensaje de error apropiado
        await tester.pump(const Duration(seconds: 5));

        // No debería haber indicadores de carga infinitos
        expect(find.byType(CircularProgressIndicator), findsNothing);

        // Debería haber algún contenido (AppBar, productos, o mensaje de error)
        final hasContent = find.byType(AppBar).evaluate().isNotEmpty ||
                          find.text('Products').evaluate().isNotEmpty ||
                          find.byType(SnackBar).evaluate().isNotEmpty;

        expect(hasContent, true,
            reason: 'Debería mostrar contenido del pedido, AppBar, o mensaje de error');
      }
    });
  });
}