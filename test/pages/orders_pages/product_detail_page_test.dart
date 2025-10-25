import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medisupply_app/src/classes/product.dart';
import 'package:medisupply_app/src/pages/orders_pages/product_detail_page.dart';
import 'package:medisupply_app/src/providers/order_provider.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';
import 'package:medisupply_app/src/widgets/new_order_widgets/quantity_product.dart';

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
      'new_order': {
        'expiry': 'Expiry Date',
        'add_button': 'Add to Cart'
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

  @override
  String formatLocalizedDate(BuildContext context, String sDate) {
    return '01/01/2024'; // Mock date
  }
}

class MockLoginProvider extends LoginProvider {}

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

Widget _buildTestApp(Product product) {
  final orderProvider = OrderProvider();
  final loginProvider = MockLoginProvider();

  return MultiProvider(
    providers: [
      ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
      ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
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
      home: ProductDetailPage(oProduct: product),
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

  group('ProductDetailPage Widget Tests', () {
    testWidgets('ProductDetailPage creates successfully', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
        sDescription: 'Test description',
        sExpirationDate: '2024-12-31',
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      expect(find.byType(ProductDetailPage), findsOneWidget);
    });

    testWidgets('ProductDetailPage has correct AppBar structure', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Check AppBar exists
      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('ProductDetailPage displays product image', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should have FadeInImage for product image
      expect(find.byType(FadeInImage), findsOneWidget);

      // Should have Container with decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('ProductDetailPage displays product price correctly', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display formatted price
      expect(find.text('\$25.99'), findsOneWidget);
    });

    testWidgets('ProductDetailPage displays product name', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display product name
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('ProductDetailPage displays expiry date', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
        sExpirationDate: '2024-12-31',
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display expiry date text
      expect(find.textContaining('Expiry Date'), findsOneWidget);
      expect(find.textContaining('01/01/2024'), findsOneWidget);
    });

    testWidgets('ProductDetailPage displays product description', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
        sDescription: 'This is a test product description',
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display product description
      expect(find.text('This is a test product description'), findsOneWidget);
    });

    testWidgets('ProductDetailPage has QuantityProduct widget', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should have QuantityProduct widget
      expect(find.byType(QuantityProduct), findsOneWidget);
    });

    testWidgets('ProductDetailPage has Add to Cart button', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should have MainButton
      expect(find.byType(MainButton), findsOneWidget);

      // Should display button text
      expect(find.text('Add to Cart'), findsOneWidget);
    });

    testWidgets('ProductDetailPage handles null product name', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: null,
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display default name for null product name
      expect(find.text('Unknown Product'), findsOneWidget);
    });

    testWidgets('ProductDetailPage handles null price', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: null,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display formatted price with 0.0
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('ProductDetailPage handles null expiry date', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
        sExpirationDate: null,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display N/A for null expiry date
      expect(find.textContaining('N/A'), findsOneWidget);
    });

    testWidgets('ProductDetailPage handles null description', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
        sDescription: null,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display empty string for null description
      expect(find.text(''), findsWidgets);
    });

    testWidgets('ProductDetailPage handles null image', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: null,
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should still have FadeInImage widget
      expect(find.byType(FadeInImage), findsOneWidget);
    });

    testWidgets('ProductDetailPage has correct Scaffold structure', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should have Scaffold as root
      expect(find.byType(Scaffold), findsOneWidget);

      // Should have AppBar
      expect(find.byType(AppBar), findsOneWidget);

      // Should have Column as body
      expect(find.byType(Column), findsWidgets);

      // Should have ListView
      expect(find.byType(ListView), findsOneWidget);

      // Should have Padding for footer
      expect(find.byType(Padding), findsWidgets);
    });

    testWidgets('ProductDetailPage Add to Cart button calls orderProvider.addProduct', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Get the OrderProvider before tapping
      final orderProvider = Provider.of<OrderProvider>(
        tester.element(find.byType(ProductDetailPage)),
        listen: false,
      );

      // Initially should have no products
      expect(orderProvider.lOrderProducts.length, equals(0));

      // Tap the Add to Cart button
      await tester.tap(find.byType(MainButton));
      await tester.pump();

      // Should have added product to order
      expect(orderProvider.lOrderProducts.length, equals(1));
      expect(orderProvider.lOrderProducts[0].iId, equals(1));
      expect(orderProvider.lOrderProducts[0].sName, equals('Test Product'));
    });

    testWidgets('ProductDetailPage constructor works correctly', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      final productDetailPage = ProductDetailPage(oProduct: product);

      expect(productDetailPage.oProduct, equals(product));
      expect(productDetailPage, isA<ProductDetailPage>());
    });

    testWidgets('ProductDetailPage displays long product names with max lines', (WidgetTester tester) async {
      final product = Product(
        iId: 1,
        sName: 'This is a very long product name that should be displayed with max lines to prevent overflow',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display the long name (truncated if needed due to maxLines: 5)
      expect(find.textContaining('This is a very long product name'), findsOneWidget);
    });

    testWidgets('ProductDetailPage displays long descriptions with max lines', (WidgetTester tester) async {
      final longDescription = 'This is a very long product description that contains a lot of text to test the max lines functionality. It should be able to handle very long descriptions without causing layout issues. The description can be quite lengthy and should still display properly within the constraints of the UI.' * 3;

      final product = Product(
        iId: 1,
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 25.99,
        sDescription: longDescription,
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display the long description (truncated if needed due to maxLines: 100)
      expect(find.textContaining('This is a very long product description'), findsOneWidget);
    });
  });
}