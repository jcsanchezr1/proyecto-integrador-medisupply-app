import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medisupply_app/src/classes/product.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/orders_pages/order_summary_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/order_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/new_order_widgets/oder_product_card.dart';
import 'package:medisupply_app/src/widgets/new_order_widgets/footer_order_summary.dart';

/// PNG de 1x1 transparente para simular assets en tests.
const List<int> _kTransparentPng = <int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
  0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
  0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
  0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0xDA, 0x63, 0xF8, 0x0F, 0x00, 0x01,
  0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xE1, 0x00, 0x00, 0x00, 0x00, 0x49,
  0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82,
];

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'order_summary': {
        'title': 'Order Summary',
        'total': 'Total',
        'delivery_time': 'Delivery Time',
        'days': 'days',
        'finish_button': 'Finish Order',
        'unit': 'unit',
        'units': 'units'
      }
    };
  }

  @override
  Future<void> load() async {
    // Mock implementation - do nothing
  }

  @override
  String formatNumber(double dNumber) {
    return dNumber.toStringAsFixed(2);
  }
}

void _setupAssetMock() {
  TestWidgetsFlutterBinding.ensureInitialized();

  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) async {
      final String key = utf8.decode(message!.buffer.asUint8List());

      // Mock del AssetManifest.bin (google_fonts lo lee en tests)
      if (key == 'AssetManifest.bin') {
        final ByteData? data = const StandardMessageCodec().encodeMessage(<String, Object?>{});
        return data;
      }

      // Compatibilidad: algunos entornos consultan también el JSON
      if (key == 'AssetManifest.json') {
        final bytes = utf8.encode('{}');
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }

      // Cualquier .png -> PNG transparente
      if (key.endsWith('.png')) {
        return ByteData.view(Uint8List.fromList(_kTransparentPng).buffer);
      }

      return null;
    },
  );
}

Widget _buildTestApp({
  required List<Product> orderProducts,
  required User testUser,
}) {
  final loginProvider = LoginProvider();
  loginProvider.oUser = testUser;

  final orderProvider = OrderProvider();
  // Add products to the order provider
  for (final product in orderProducts) {
    orderProvider.addProduct(product);
  }

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
      ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
      Provider<TextsUtil>(
        create: (context) => MockTextsUtil(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      locale: const Locale('en', 'US'),
      home: const OrderSummaryPage(),
    ),
  );
}

void main() {
  setUpAll(() {
    _setupAssetMock();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('OrderSummaryPage Widget Tests', () {
    testWidgets('OrderSummaryPage creates successfully', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      await tester.pumpWidget(_buildTestApp(
        orderProducts: [],
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(OrderSummaryPage), findsOneWidget);
    });

    testWidgets('OrderSummaryPage has correct AppBar structure', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      await tester.pumpWidget(_buildTestApp(
        orderProducts: [],
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Check AppBar exists
      expect(find.byType(AppBar), findsOneWidget);

      // Check title
      expect(find.text('Order Summary'), findsOneWidget);
    });

    testWidgets('OrderSummaryPage displays empty list when no products', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      await tester.pumpWidget(_buildTestApp(
        orderProducts: [],
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Should have ListView but empty
      expect(find.byType(ListView), findsOneWidget);

      // Should not have any OrderProductCard widgets
      expect(find.byType(OrderProductCard), findsNothing);

      // Should have FooterOrderSummary
      expect(find.byType(FooterOrderSummary), findsOneWidget);
    });

    testWidgets('OrderSummaryPage displays products correctly', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      final testProducts = [
        Product(
          iId: 1,
          sName: 'Product 1',
          sImage: 'image1.jpg',
          dQuantity: 2.0,
          dPrice: 10.99,
        ),
        Product(
          iId: 2,
          sName: 'Product 2',
          sImage: 'image2.jpg',
          dQuantity: 1.0,
          dPrice: 15.50,
        ),
      ];

      await tester.pumpWidget(_buildTestApp(
        orderProducts: testProducts,
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Should have ListView
      expect(find.byType(ListView), findsOneWidget);

      // Should have 2 OrderProductCard widgets
      expect(find.byType(OrderProductCard), findsNWidgets(2));

      // Should have FooterOrderSummary
      expect(find.byType(FooterOrderSummary), findsOneWidget);
    });

    testWidgets('OrderSummaryPage passes correct order data to FooterOrderSummary', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      final testProducts = [
        Product(
          iId: 1,
          sName: 'Product 1',
          sImage: 'image1.jpg',
          dQuantity: 2.0,
          dPrice: 10.99,
        ),
      ];

      await tester.pumpWidget(_buildTestApp(
        orderProducts: testProducts,
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Find FooterOrderSummary widget
      final footerFinder = find.byType(FooterOrderSummary);
      expect(footerFinder, findsOneWidget);

      // Get the widget
      final footerWidget = tester.widget<FooterOrderSummary>(footerFinder);

      // Verify the order data structure
      expect(footerWidget.mOrder['client_id'], equals('test_user_id'));
      expect(footerWidget.mOrder['total_amount'], isA<double>());
      expect(footerWidget.mOrder['scheduled_delivery_date'], isA<String>());
      expect(footerWidget.mOrder['items'], isA<List>());

      // Verify items structure
      final items = footerWidget.mOrder['items'] as List;
      expect(items.length, equals(1));
      expect(items[0]['product_id'], equals(1));
      expect(items[0]['quantity'], equals(1.0)); // The quantity from OrderProvider, not from original product
    });

    testWidgets('OrderSummaryPage handles single product order', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      final testProducts = [
        Product(
          iId: 1,
          sName: 'Single Product',
          sImage: 'single.jpg',
          dQuantity: 1.0,
          dPrice: 25.00,
        ),
      ];

      await tester.pumpWidget(_buildTestApp(
        orderProducts: testProducts,
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Should have 1 OrderProductCard
      expect(find.byType(OrderProductCard), findsOneWidget);

      // Should display product name
      expect(find.text('Single Product'), findsOneWidget);
    });

    testWidgets('OrderSummaryPage handles multiple products order', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      final testProducts = [
        Product(
          iId: 1,
          sName: 'Product A',
          sImage: 'a.jpg',
          dQuantity: 2.0,
          dPrice: 10.00,
        ),
        Product(
          iId: 2,
          sName: 'Product B',
          sImage: 'b.jpg',
          dQuantity: 3.0,
          dPrice: 15.00,
        ),
        Product(
          iId: 3,
          sName: 'Product C',
          sImage: 'c.jpg',
          dQuantity: 1.0,
          dPrice: 20.00,
        ),
      ];

      await tester.pumpWidget(_buildTestApp(
        orderProducts: testProducts,
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Should have 3 OrderProductCard widgets
      expect(find.byType(OrderProductCard), findsNWidgets(3));

      // Should display all product names
      expect(find.text('Product A'), findsOneWidget);
      expect(find.text('Product B'), findsOneWidget);
      expect(find.text('Product C'), findsOneWidget);
    });

    testWidgets('OrderSummaryPage has correct Scaffold structure', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      await tester.pumpWidget(_buildTestApp(
        orderProducts: [],
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Should have Scaffold as root
      expect(find.byType(Scaffold), findsOneWidget);

      // Should have AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have ListView for products
      expect(find.byType(ListView), findsOneWidget);

      // Should have FooterOrderSummary
      expect(find.byType(FooterOrderSummary), findsOneWidget);
    });

    testWidgets('OrderSummaryPage ListView is scrollable', (WidgetTester tester) async {
      final testUser = User(
        sId: 'test_user_id',
        sEmail: 'test@example.com',
        sName: 'Test User',
        sAccessToken: 'test_token',
        sRefreshToken: 'refresh_token',
        sRole: 'user'
      );

      // Create many products to test scrolling capability
      final testProducts = List.generate(
        10,
        (index) => Product(
          iId: index + 1,
          sName: 'Product ${index + 1}',
          sImage: 'image${index + 1}.jpg',
          dQuantity: 1.0,
          dPrice: 10.00,
        ),
      );

      await tester.pumpWidget(_buildTestApp(
        orderProducts: testProducts,
        testUser: testUser,
      ));
      await tester.pumpAndSettle();

      // Should have ListView
      expect(find.byType(ListView), findsOneWidget);

      // Should have at least one OrderProductCard (Flutter only renders visible items)
      expect(find.byType(OrderProductCard), findsWidgets);

      // Verify that we have multiple products in the order
      final orderProvider = Provider.of<OrderProvider>(
        tester.element(find.byType(OrderSummaryPage)),
        listen: false,
      );
      expect(orderProvider.lOrderProducts.length, equals(10));
    });

    testWidgets('OrderSummaryPage constructor works correctly', (WidgetTester tester) async {
      const orderSummaryPage = OrderSummaryPage();

      expect(orderSummaryPage, isA<OrderSummaryPage>());
      expect(orderSummaryPage.key, isNull);
    });
  });
}