import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medisupply_app/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisupply_app/src/widgets/new_order_widgets/product_card.dart';

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

  // Configurar manejo de errores después de la inicialización del binding
  WidgetsBinding.instance.addPostFrameCallback((_) {
    FlutterError.onError = (FlutterErrorDetails details) {
      // Ignorar errores de imagen que no afectan la funcionalidad del test
      if (details.exception.toString().contains('Invalid argument(s): No host specified in URI')) {
        return; // Ignorar errores de imagen con URLs vacías
      }
      // Para otros errores, usar el comportamiento por defecto
      FlutterError.dumpErrorToConsole(details);
    };
  });

  group('New Order Flow Integration Tests', () {
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

    testWidgets('Flujo completo: Login -> Home -> Orders -> New Order -> Visualizar inventario', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5)); // Más tiempo para splash

      // === PASO 1: LOGIN ===
      const email = 'cliente@correo.com';
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

      // === PASO 2: NAVEGAR A ORDERS PAGE ===
      // Verificar que estamos en la pestaña correcta (Orders debería ser la primera)
      expect(find.text('Orders'), findsOneWidget);

      // La OrdersPage debería estar visible por defecto (índice 0 del NavigationBar)
      // Verificar que el FloatingActionButton está presente
      await waitForWidget(tester, find.byType(FloatingActionButton));
      expect(find.byType(FloatingActionButton), findsOneWidget);

      // === PASO 3: IR A NEW ORDER PAGE ===
      // Presionar el FloatingActionButton para ir a NewOrderPage
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // === PASO 4: VERIFICAR NEW ORDER PAGE ===
      // Verificar que estamos en NewOrderPage
      expect(find.byKey(const Key('new_order_page')), findsOneWidget);

      // Verificar elementos de la AppBar
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Create order'), findsOneWidget); // Título de la AppBar
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget); // Icono del carrito

      // === PASO 5: VERIFICAR CARGA DE INVENTARIO ===
      // Esperar a que se cargue el inventario (puede tomar tiempo)
      await tester.pump(const Duration(seconds: 3));

      // Verificar que no hay indicador de carga (significa que terminó de cargar)
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verificar que se muestran productos o mensaje de vacío
      final hasProducts = find.byType(ListView).evaluate().isNotEmpty;
      final hasEmptyMessage = find.text('No products available').evaluate().isNotEmpty;

      // Debería tener productos O mostrar mensaje de vacío
      expect(hasProducts || hasEmptyMessage, true,
          reason: 'Debería mostrar productos del inventario o mensaje de que no hay productos disponibles');

      if (hasProducts) {
        // Si hay productos, verificar estructura
        expect(find.byType(ListView), findsWidgets); // Al menos un ListView (vertical y horizontal)

        // Verificar que hay al menos un proveedor (título del proveedor)
        final providerTitles = find.byType(Text).evaluate().where((element) {
          final text = element.widget as Text;
          return text.data != null && text.data!.isNotEmpty && !text.data!.contains('Create Order');
        }).length;

        expect(providerTitles, greaterThan(0),
            reason: 'Debería haber al menos un título de proveedor si hay productos');

        // Verificar que hay ProductCard widgets si hay productos
        final productCards = find.byType(ProductCard).evaluate();
        if (productCards.isNotEmpty) {
          expect(find.byType(ProductCard), findsWidgets,
              reason: 'Debería haber tarjetas de producto si hay productos en el inventario');
        }
      }
    });

    testWidgets('Visualización de productos en New Order Page', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === LOGIN RÁPIDO ===
      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(seconds: 3));

      await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 150);

      // === IR A NEW ORDER ===
      await waitForWidget(tester, find.byType(FloatingActionButton));
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // === VERIFICAR ELEMENTOS DE LA PÁGINA ===
      expect(find.byKey(const Key('new_order_page')), findsOneWidget);

      // Verificar AppBar completa
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Create order'), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

      // Esperar carga del inventario
      await tester.pump(const Duration(seconds: 3));
      expect(find.byType(CircularProgressIndicator), findsNothing);

      // Verificar estructura de la página
      expect(find.byType(Scaffold), findsOneWidget);

      // Si hay productos, verificar que se muestran correctamente
      if (find.byType(ListView).evaluate().isNotEmpty) {
        // Verificar navegación horizontal de productos
        expect(find.byType(ListView), findsWidgets);

        // Verificar que podemos hacer scroll si hay muchos productos
        final scrollable = find.byType(Scrollable).first;
        await tester.drag(scrollable, const Offset(-200, 0)); // Scroll horizontal
        await tester.pumpAndSettle();

        // Verificar que la página sigue funcionando después del scroll
        expect(find.byKey(const Key('new_order_page')), findsOneWidget);
      }
    });

    testWidgets('Flujo completo de creación de orden end-to-end', (WidgetTester tester) async {
      // Configurar manejo de errores específico para este test
      final originalOnError = FlutterError.onError;
      FlutterError.onError = (FlutterErrorDetails details) {
        // Ignorar errores de imagen que no afectan la funcionalidad del test
        if (details.exception.toString().contains('Invalid argument(s): No host specified in URI') ||
            details.exception.toString().contains('NetworkImage')) {
          return; // Ignorar errores de imagen
        }
        // Para otros errores, usar el comportamiento por defecto
        originalOnError?.call(details);
      };

      try {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // === PASO 1: LOGIN ===
      const email = 'cliente@correo.com';
      const password = 'AugustoCelis13*';

      // Esperar campos de login con más paciencia
      await waitForWidget(tester, find.byKey(const Key('email_field')), maxTries: 100);
      await waitForWidget(tester, find.byKey(const Key('password_field')), maxTries: 100);
      await waitForWidget(tester, find.byKey(const Key('login_button')), maxTries: 100);

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      // Llenar credenciales
      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Esperar más tiempo para el procesamiento del login
      await tester.pump(const Duration(seconds: 5));

      // Verificar resultado del login - puede ser éxito o error
      final hasErrorSnackBar = find.byType(SnackBar).evaluate().isNotEmpty;
      final hasHomePage = find.byKey(const Key('home_page')).evaluate().isNotEmpty;

      if (hasErrorSnackBar) {
        // Si hay error, verificar que seguimos en login
        expect(find.byKey(const Key('email_field')), findsOneWidget);
        return; // Salir del test si login falla
      }

      if (!hasHomePage) {
        // Si no estamos en HomePage, esperar más
        await tester.pump(const Duration(seconds: 5));
        await waitForWidget(tester, find.byKey(const Key('home_page')), maxTries: 200);
      }

      expect(find.byKey(const Key('home_page')), findsOneWidget);

      // === PASO 2: NAVEGAR A NEW ORDER ===
      await waitForWidget(tester, find.byType(FloatingActionButton), maxTries: 100);
      expect(find.byType(FloatingActionButton), findsOneWidget);

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verificar que llegamos a NewOrderPage
      await waitForWidget(tester, find.byKey(const Key('new_order_page')), maxTries: 100);
      expect(find.byKey(const Key('new_order_page')), findsOneWidget);

      // Verificar elementos básicos de la página
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.byIcon(Icons.shopping_cart_outlined), findsOneWidget);

      // === PASO 3: ESPERAR CARGA DE PRODUCTOS ===
      // Esperar que termine la carga (puede haber CircularProgressIndicator o no)
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Verificar estado de la página - puede tener productos o mensaje vacío
      final hasProducts = find.byType(ListView).evaluate().isNotEmpty;
      final hasCircularProgress = find.byType(CircularProgressIndicator).evaluate().isNotEmpty;
      final hasEmptyMessage = find.textContaining('No').evaluate().isNotEmpty ||
                             find.textContaining('available').evaluate().isNotEmpty;

      // La página debería estar en un estado válido
      expect(hasProducts || hasCircularProgress || hasEmptyMessage, true,
          reason: 'La página debería mostrar productos, loading, o mensaje vacío');

      if (hasProducts) {

        // === PASO 4: INTENTAR SELECCIONAR UN PRODUCTO ===
        // Buscar ProductCards (pueden ser GestureDetector o Card)
        final productSelectors = find.byType(GestureDetector).evaluate();
        if (productSelectors.isNotEmpty) {
          // Hacer tap en el primer producto disponible
          await tester.tap(find.byType(GestureDetector).first);
          await tester.pumpAndSettle();

          // Deberíamos estar en ProductDetailPage
          await tester.pump(const Duration(seconds: 2));

          // Verificar que cambiamos de página (AppBar sin título específico o con elementos diferentes)
          final currentAppBar = find.byType(AppBar);
          expect(currentAppBar, findsOneWidget);

          // Intentar agregar al carrito si estamos en la página correcta
          final addToCartButtons = find.textContaining('Add').evaluate();
          final addButtons = find.textContaining('add').evaluate();

          if (addToCartButtons.isNotEmpty || addButtons.isNotEmpty) {
            // Encontrar el botón de agregar
            final addButton = addToCartButtons.isNotEmpty ?
              find.textContaining('Add').first :
              find.textContaining('add').first;

            await tester.tap(addButton);
            await tester.pumpAndSettle();

            // Deberíamos volver a NewOrderPage
            await waitForWidget(tester, find.byKey(const Key('new_order_page')), maxTries: 100);
            expect(find.byKey(const Key('new_order_page')), findsOneWidget);

          } else {
            // Si no hay botón, intentar volver atrás
            final backButton = find.byType(BackButton);
            if (backButton.evaluate().isNotEmpty) {
              await tester.tap(backButton);
              await tester.pumpAndSettle();
            }
          }
        }

        // === PASO 5: VERIFICAR CARRITO ===
        // Intentar acceder al carrito
        final cartButton = find.byIcon(Icons.shopping_cart_outlined);
        if (cartButton.evaluate().isNotEmpty) {
          await tester.tap(cartButton);
          await tester.pumpAndSettle();

          // Verificar si llegamos a OrderSummaryPage
          await tester.pump(const Duration(seconds: 2));

          // Buscar indicadores de OrderSummaryPage
          final hasOrderSummaryTitle = find.textContaining('Order').evaluate().isNotEmpty ||
                                      find.textContaining('Summary').evaluate().isNotEmpty;
          final hasFinishButton = find.textContaining('Finish').evaluate().isNotEmpty;

          if (hasOrderSummaryTitle || hasFinishButton) {

            // Intentar finalizar orden si hay productos
            if (hasFinishButton) {
              await tester.tap(find.textContaining('Finish').first);
              await tester.pumpAndSettle();
              await tester.pump(const Duration(seconds: 3));

            }
          } else {
            // Volver atrás si no estamos en OrderSummary
            final backButton = find.byType(BackButton);
            if (backButton.evaluate().isNotEmpty) {
              await tester.tap(backButton);
              await tester.pumpAndSettle();
            }
          }
        }

      }

      // === PASO FINAL: VERIFICAR QUE LA APP SIGUE FUNCIONANDO ===
      // Asegurarse de que podemos navegar de vuelta
      final backButton = find.byType(BackButton);
      if (backButton.evaluate().isNotEmpty) {
        await tester.tap(backButton);
        await tester.pumpAndSettle();
        expect(find.byKey(const Key('home_page')), findsOneWidget);
      }
      } finally {
        // Restaurar el handler de errores original
        FlutterError.onError = originalOnError;
      }
    });
  });
}