import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medisupply_app/src/classes/product.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/new_order_widgets/product_card.dart';

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
        'availabe': 'available',
        'availabes': 'available'
      }
    };
  }

  @override
  Future<void> load() async {
    // Mock implementation - do nothing
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

Widget _buildTestApp(Product product) {
  return Provider<TextsUtil>(
    create: (context) => MockTextsUtil(),
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
      home: Scaffold(
        body: ProductCard(oProduct: product),
      ),
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

  group('ProductCard Widget Tests', () {
    testWidgets('ProductCard displays product information correctly', (WidgetTester tester) async {
      final product = Product(
        sName: 'Test Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 5.0,
        dPrice: 29.99
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Check product name
      expect(find.text('Test Product'), findsOneWidget);

      // Check price (formatted as integer)
      expect(find.text('\$29'), findsOneWidget);

      // Check quantity text
      expect(find.text('5 available'), findsOneWidget);
    });

    testWidgets('ProductCard handles single quantity correctly', (WidgetTester tester) async {
      final product = Product(
        sName: 'Single Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 1.0,
        dPrice: 15.50
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Check quantity text uses singular form
      expect(find.text('1 available'), findsOneWidget);
    });

    testWidgets('ProductCard displays image container', (WidgetTester tester) async {
      final product = Product(
        sName: 'Image Product',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 3.0,
        dPrice: 20.00
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Check that image container exists
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(FadeInImage), findsOneWidget);
    });

    testWidgets('ProductCard handles null image gracefully', (WidgetTester tester) async {
      final product = Product(
        sName: 'No Image Product',
        sImage: null,
        dQuantity: 2.0,
        dPrice: 10.00
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should still display correctly even with null image
      expect(find.text('No Image Product'), findsOneWidget);
      expect(find.text('\$10'), findsOneWidget);
      expect(find.text('2 available'), findsOneWidget);
    });

    testWidgets('ProductCard handles long product names', (WidgetTester tester) async {
      final product = Product(
        sName: 'This is a very long product name that should be displayed with max lines',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 1.0,
        dPrice: 99.99
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Should display the long name (truncated if needed)
      expect(find.textContaining('This is a very long product name'), findsOneWidget);
    });

    testWidgets('ProductCard has correct layout structure', (WidgetTester tester) async {
      final product = Product(
        sName: 'Layout Test',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 4.0,
        dPrice: 25.00
      );

      await tester.pumpWidget(_buildTestApp(product));
      await tester.pumpAndSettle();

      // Check that we have a Column with children
      final columnFinder = find.byType(Column);
      expect(columnFinder, findsOneWidget);

      // Check that the column has the expected number of children
      final column = tester.widget<Column>(columnFinder);
      expect(column.children.length, 7); // Image container + 3 SizedBox + 3 PoppinsText widgets
    });

    testWidgets('ProductCard constructor works correctly', (WidgetTester tester) async {
      final product = Product(
        sName: 'Constructor Test',
        sImage: 'https://example.com/image.jpg',
        dQuantity: 1.0,
        dPrice: 5.00
      );

      final productCard = ProductCard(oProduct: product);

      expect(productCard.oProduct, equals(product));
      expect(productCard.runtimeType, equals(ProductCard));
    });
  });
}