import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/pages/orders_pages/order_detail_page.dart';
import 'package:medisupply_app/src/classes/order.dart';
import 'package:medisupply_app/src/classes/product.dart';
import 'package:medisupply_app/src/providers/order_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

// Mock classes
class MockTextsUtil extends Mock implements TextsUtil {
  @override
  String? getText(String key) {
    switch (key) {
      case 'orders.delivery':
        return 'Scheduled delivery: ';
      case 'orders.truck':
        return 'Assigned truck: ';
      case 'orders.products':
        return 'Products';
      case 'order_summary.units':
        return 'units';
      case 'order_summary.unit':
        return 'unit';
      default:
        return key;
    }
  }

  @override
  String formatLocalizedDate(BuildContext context, String date) {
    return 'Formatted: $date';
  }

  @override
  Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'completed':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Locale get locale => const Locale('en');
}

class MockOrderProvider extends Mock implements OrderProvider {}

void main() {
  late Order testOrder;
  late List<Product> testProducts;
  late MockTextsUtil mockTextsUtil;
  late MockOrderProvider mockOrderProvider;

  setUp(() {
    testProducts = [
      Product(
        iId: 1,
        sName: 'Test Product 1',
        sImage: 'https://example.com/image1.jpg',
        dQuantity: 2.0,
        dPrice: 10.99,
      ),
      Product(
        iId: 2,
        sName: 'Test Product 2',
        sImage: 'https://example.com/image2.jpg',
        dQuantity: 1.0,
        dPrice: 25.50,
      ),
    ];

    testOrder = Order(
      iId: 123,
      sOrderNumber: 'ORD-001',
      sClientId: 'client123',
      sVendorId: 'vendor456',
      sStatus: 'pending',
      dTotalAmount: 47.48,
      sDeliveryDate: '2024-01-15',
      sAssignedTruck: 'TRUCK-001',
      sCreatedAt: '2024-01-10T10:00:00Z',
      sUpdatedAt: '2024-01-10T10:00:00Z',
      lProducts: testProducts,
    );

    mockTextsUtil = MockTextsUtil();
    mockOrderProvider = MockOrderProvider();
  });

  group('OrderDetailPage', () {
    testWidgets('should render with complete order data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // Wait for widgets to settle
      await tester.pumpAndSettle();

      // Verify AppBar title shows order number
      expect(find.text('ORD-001'), findsOneWidget);

      // Verify OrderBadge is present
      expect(find.byType(Container), findsWidgets); // OrderBadge renders as Container

      // Verify delivery date info - check for formatted date value in RichText
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Formatted: 2024-01-15'),
        ),
        findsOneWidget,
      );

      // Verify assigned truck info - check for truck value in RichText
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('TRUCK-001'),
        ),
        findsOneWidget,
      );

      // Verify products section title
      expect(find.text('Products'), findsOneWidget);

      // Verify products are displayed
      expect(find.text('Test Product 1'), findsOneWidget);
      expect(find.text('Test Product 2'), findsOneWidget);
    });

    testWidgets('should render AppBar with correct title', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // Verify AppBar exists
      expect(find.byType(AppBar), findsOneWidget);

      // Verify order number in AppBar title
      expect(find.descendant(of: find.byType(AppBar), matching: find.text('ORD-001')), findsOneWidget);
    });

    testWidgets('should render OrderBadge with correct status', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // OrderBadge should be rendered (we verify by checking for text content)
      expect(find.text('pending'), findsOneWidget);
    });

    testWidgets('should render order information items', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // Verify delivery date information
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('Formatted: 2024-01-15'),
        ),
        findsOneWidget,
      );

      // Verify truck information
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('TRUCK-001'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should render products list correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // Verify products section title
      expect(find.text('Products'), findsOneWidget);

      // Verify ListView is present
      expect(find.byType(ListView), findsOneWidget);

      // Verify product names are displayed
      expect(find.text('Test Product 1'), findsOneWidget);
      expect(find.text('Test Product 2'), findsOneWidget);

      // Verify quantities are displayed
      expect(find.textContaining('2 units'), findsOneWidget);
      expect(find.textContaining('1 unit'), findsOneWidget);
    });

    testWidgets('should handle order with empty products list', (WidgetTester tester) async {
      final orderWithEmptyProducts = Order(
        iId: 123,
        sOrderNumber: 'ORD-001',
        sStatus: 'pending',
        sDeliveryDate: '2024-01-15',
        sAssignedTruck: 'TRUCK-001',
        lProducts: [], // Empty list
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: orderWithEmptyProducts),
          ),
        ),
      );

      // Verify basic structure still renders
      expect(find.text('ORD-001'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);

      // ListView should be present but empty
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should handle order with null products list', (WidgetTester tester) async {
      final orderWithNullProducts = Order(
        iId: 123,
        sOrderNumber: 'ORD-001',
        sStatus: 'pending',
        sDeliveryDate: '2024-01-15',
        sAssignedTruck: 'TRUCK-001',
        lProducts: null, // Null list
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: orderWithNullProducts),
          ),
        ),
      );

      // Verify basic structure still renders
      expect(find.text('ORD-001'), findsOneWidget);
      expect(find.text('Products'), findsOneWidget);

      // ListView should be present but empty
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('should handle products with null names', (WidgetTester tester) async {
      final productsWithNullNames = [
        Product(
          iId: 1,
          sName: null, // Null name
          sImage: 'https://example.com/image.jpg',
          dQuantity: 1.0,
        ),
      ];

      final orderWithNullProductNames = Order(
        iId: 123,
        sOrderNumber: 'ORD-001',
        sStatus: 'pending',
        sDeliveryDate: '2024-01-15',
        sAssignedTruck: 'TRUCK-001',
        lProducts: productsWithNullNames,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: orderWithNullProductNames),
          ),
        ),
      );

      // Should show fallback text for null product name
      expect(find.text('Unknown Product'), findsOneWidget);
    });

    testWidgets('should handle products with null quantities', (WidgetTester tester) async {
      final productsWithNullQuantities = [
        Product(
          iId: 1,
          sName: 'Test Product',
          sImage: 'https://example.com/image.jpg',
          dQuantity: null, // Null quantity
        ),
      ];

      final orderWithNullQuantities = Order(
        iId: 123,
        sOrderNumber: 'ORD-001',
        sStatus: 'pending',
        sDeliveryDate: '2024-01-15',
        sAssignedTruck: 'TRUCK-001',
        lProducts: productsWithNullQuantities,
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: orderWithNullQuantities),
          ),
        ),
      );

      // Wait for widgets to settle
      await tester.pumpAndSettle();

      // Should show 0 unit for null quantity (singular form)
      expect(
        find.byWidgetPredicate(
          (widget) => widget is RichText && widget.text.toPlainText().contains('0 unit'),
        ),
        findsOneWidget,
      );
    });

    testWidgets('should render OrderProductCard with bDelete=false and bCompact=false', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // Verify that OrderProductCard widgets are rendered
      // We can't easily check the internal bDelete and bCompact flags,
      // but we can verify the cards are present and don't show delete buttons
      expect(find.byIcon(Icons.delete_rounded), findsNothing); // No delete buttons should be shown
    });

    testWidgets('should handle different order statuses', (WidgetTester tester) async {
      final statuses = ['pending', 'completed', 'cancelled', 'in_progress'];

      for (final status in statuses) {
        final orderWithStatus = Order(
          iId: 123,
          sOrderNumber: 'ORD-001',
          sStatus: status,
          sDeliveryDate: '2024-01-15',
          sAssignedTruck: 'TRUCK-001',
          lProducts: testProducts,
        );

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<TextsUtil>.value(value: mockTextsUtil),
              ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
            ],
            child: MaterialApp(
              home: OrderDetailPage(oOrder: orderWithStatus),
            ),
          ),
        );

        // Verify status is displayed
        expect(find.text(status), findsOneWidget);

        // Clean up for next iteration
        await tester.pumpWidget(Container());
      }
    });

    testWidgets('should have correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<OrderProvider>.value(value: mockOrderProvider),
          ],
          child: MaterialApp(
            home: OrderDetailPage(oOrder: testOrder),
          ),
        ),
      );

      // Wait for widgets to settle
      await tester.pumpAndSettle();

      // Verify Scaffold structure
      expect(find.byType(Scaffold), findsOneWidget);

      // Verify Column layout exists (there may be multiple in the widget tree)
      expect(find.byType(Column), findsWidgets);

      // Verify Expanded widget exists for products list (may be multiple in widget tree)
      expect(find.byType(Expanded), findsWidgets);

      // Verify Padding around content
      expect(find.byType(Padding), findsWidgets);
    });
  });
}
