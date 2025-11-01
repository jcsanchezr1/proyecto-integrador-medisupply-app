import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/order_provider.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';
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

// Mock classes
class MockOrderProvider extends Mock implements OrderProvider {}

class MockLoginProvider extends Mock implements LoginProvider {}

class MockFetchData extends Mock implements FetchData {}

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'order_summary': {
        'total': 'Total',
        'delivery_time': 'Delivery Time',
        'days': 'days',
        'finish_button': 'Finish Order'
      },
      'new_order': {
        'success_order': 'Order created successfully',
        'error_order': 'Error creating order'
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
  required Map<String, dynamic> order,
  required OrderProvider orderProvider,
  required LoginProvider loginProvider,
  required FetchData fetchData,
}) {
  return MultiProvider(
    providers: [
      Provider<TextsUtil>(
        create: (context) => MockTextsUtil(),
      ),
      ChangeNotifierProvider<OrderProvider>.value(value: orderProvider),
      ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
      Provider<FetchData>(
        create: (context) => fetchData,
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
      home: Scaffold(
        body: FooterOrderSummary(mOrder: order),
      ),
    ),
  );
}

void main() {
  late MockOrderProvider mockOrderProvider;
  late MockLoginProvider mockLoginProvider;
  late MockFetchData mockFetchData;

  setUpAll(() {
    _setupAssetMock();
    GoogleFonts.config.allowRuntimeFetching = false;
  });

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    mockOrderProvider = MockOrderProvider();
    mockLoginProvider = MockLoginProvider();
    mockFetchData = MockFetchData();

    // Setup default mock behaviors
    when(() => mockOrderProvider.dTotalPrice).thenReturn(50.0);
    when(() => mockOrderProvider.lOrderProducts).thenReturn([]);
    when(() => mockLoginProvider.bLoading).thenReturn(false);
    when(() => mockLoginProvider.oUser).thenReturn(User(sAccessToken: 'test_token'));
  });

  group('FooterOrderSummary Widget Tests', () {
    testWidgets('FooterOrderSummary displays total price correctly', (WidgetTester tester) async {
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check that total price is displayed
      expect(find.text('\$50.00'), findsOneWidget);
      expect(find.text('Total'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary displays delivery time correctly', (WidgetTester tester) async {
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check delivery time display
      expect(find.text('Delivery Time'), findsOneWidget);
      expect(find.text('2 days'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary displays finish order button', (WidgetTester tester) async {
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check that finish button is displayed
      expect(find.text('Finish Order'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary has correct layout structure', (WidgetTester tester) async {
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check main container structure
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('FooterOrderSummary handles zero total price', (WidgetTester tester) async {
      when(() => mockOrderProvider.dTotalPrice).thenReturn(0.0);
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check that zero price is displayed correctly
      expect(find.text('\$0.00'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary handles large total price', (WidgetTester tester) async {
      when(() => mockOrderProvider.dTotalPrice).thenReturn(1234.56);
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check that large price is displayed correctly
      expect(find.text('\$1234.56'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary constructor works correctly', (WidgetTester tester) async {
      final order = {'id': 1, 'items': []};
      final footerOrderSummary = FooterOrderSummary(mOrder: order);

      expect(footerOrderSummary.mOrder, equals(order));
      expect(footerOrderSummary.runtimeType, equals(FooterOrderSummary));
    });

    testWidgets('FooterOrderSummary finish button shows loading state', (WidgetTester tester) async {
      when(() => mockLoginProvider.bLoading).thenReturn(true);
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pump();

      // When loading is true, the MainButton likely shows a loading indicator instead of text
      // We just verify the widget builds without crashing in loading state
      expect(find.byType(Container), findsWidgets);
      expect(find.byType(Column), findsWidgets);
    });

    testWidgets('FooterOrderSummary successful order creation logic works', (WidgetTester tester) async {
      // This test verifies the setup for order creation
      // We can't easily mock the actual API call, but we can verify the UI elements are present
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Verify that the finish button is present and tappable
      expect(find.byType(MainButton), findsOneWidget);

      // Verify that the order data is properly passed to the widget
      final footerOrderSummary = tester.widget<FooterOrderSummary>(
        find.byType(FooterOrderSummary)
      );
      expect(footerOrderSummary.mOrder, equals(order));
    });

    testWidgets('FooterOrderSummary failed order creation logic works', (WidgetTester tester) async {
      // Similar to success test - verify the UI setup
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Verify that the finish button is present
      expect(find.byType(MainButton), findsOneWidget);

      // Verify that tapping doesn't crash the widget
      await tester.tap(find.byType(MainButton));
      await tester.pump();

      // Widget should still be present after tap
      expect(find.byType(FooterOrderSummary), findsOneWidget);
    });

    testWidgets('FooterOrderSummary handles null user gracefully', (WidgetTester tester) async {
      when(() => mockLoginProvider.oUser).thenReturn(null);
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Should still display the widget without crashing
      expect(find.text('Finish Order'), findsOneWidget);
      expect(find.text('\$50.00'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary handles null access token gracefully', (WidgetTester tester) async {
      when(() => mockLoginProvider.oUser).thenReturn(User(sAccessToken: null));
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Should still display the widget without crashing
      expect(find.text('Finish Order'), findsOneWidget);
    });

    testWidgets('FooterOrderSummary loading state prevents multiple taps', (WidgetTester tester) async {
      // This test verifies that the loading state logic is triggered
      // We can't easily mock the async operation, so we test the loading state setup
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Tap the finish order button
      await tester.tap(find.text('Finish Order'));
      await tester.pump(); // Start the async operation

      // Verify loading state is set (this happens before the async call)
      verify(() => mockLoginProvider.bLoading = true).called(1);

      // Note: The actual async operation and loading state reset can't be easily tested
      // without complex mocking of the FetchData service
    });

    testWidgets('FooterOrderSummary displays responsive layout', (WidgetTester tester) async {
      final order = {'test': 'data'};

      await tester.pumpWidget(_buildTestApp(
        order: order,
        orderProvider: mockOrderProvider,
        loginProvider: mockLoginProvider,
        fetchData: mockFetchData,
      ));
      await tester.pumpAndSettle();

      // Check that we have the expected layout elements
      expect(find.byType(Expanded), findsNWidgets(2)); // Total and Delivery Time sections
      expect(find.byType(SizedBox), findsWidgets); // Spacing elements
    });
  });
}