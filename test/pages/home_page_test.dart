import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/home_page.dart';
import 'package:medisupply_app/src/pages/orders_pages/orders_page.dart';
import 'package:medisupply_app/src/pages/clients_pages/clients_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/drawer_menu_widget.dart';

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
      'orders': {'title': 'Home'},
      'tabs': {
        'orders': 'Orders',
        'clients': 'Clients',
        'visits': 'Visits'
      },
      'menu': {
        'greeting': 'Hello',
        'language': 'Language',
        'logout': 'Log out'
      }
    };
  }

  @override
  Future<void> load() async {
    // Mock implementation - do nothing
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    GoogleFonts.config.allowRuntimeFetching = false;
    SharedPreferences.setMockInitialValues({});
    _setupAssetMock();
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
      'flutter/assets',
      null,
    );
  });

  group('HomePage Widget Tests', () {
    testWidgets('HomePage creates successfully', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());

      // Verify HomePage is created
      expect(find.byType(HomePage), findsOneWidget);
    });

    testWidgets('HomePage has correct initial structure', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Find the HomePage widget first
      final homePage = find.byType(HomePage);
      expect(homePage, findsOneWidget);

      // Verify AppBar is present
      expect(find.byType(AppBar), findsOneWidget);

      // Verify NavigationBar is present
      expect(find.byType(NavigationBar), findsOneWidget);

      // Verify OrdersPage is initially displayed (index 0)
      expect(find.byType(OrdersPage), findsOneWidget);
    });

    testWidgets('AppBar has menu button that opens drawer', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Find the menu button (IconButton with menu_rounded icon)
      final menuButton = find.byIcon(Icons.menu_rounded);
      expect(menuButton, findsOneWidget);

      // Tap the menu button
      await tester.tap(menuButton);
      await tester.pumpAndSettle();

      // Verify drawer is opened (DrawerMenuWidget should be visible in the drawer)
      expect(find.byType(DrawerMenuWidget), findsOneWidget);
    });

    testWidgets('AppBar displays title', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // The title should be "Home" from TextsUtil fallback
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('NavigationBar has correct number of destinations', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      final navigationBarWidget = tester.widget<NavigationBar>(navigationBar);

      expect(navigationBarWidget.destinations.length, equals(3));
    });

    testWidgets('NavigationBar destinations have correct icons', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Check for all navigation icons
      expect(find.byIcon(Icons.local_shipping_outlined), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.person_outline), findsAtLeastNWidgets(1));
      expect(find.byIcon(Icons.groups_outlined), findsAtLeastNWidgets(1));
    });

    testWidgets('NavigationBar initially selects first destination', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      final navigationBarWidget = tester.widget<NavigationBar>(navigationBar);

      expect(navigationBarWidget.selectedIndex, equals(0));
    });

    testWidgets('NavigationBar changes selected index when destination is tapped', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Initially selected index should be 0
      NavigationBar navigationBar = tester.widget(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(0));

      // Tap on second destination (index 1)
      await tester.tap(find.byIcon(Icons.person_outline).first);
      await tester.pumpAndSettle();

      // Selected index should now be 1
      navigationBar = tester.widget(find.byType(NavigationBar));
      expect(navigationBar.selectedIndex, equals(1));
    });

    testWidgets('Body changes when navigation index changes', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      // Initially should show OrdersPage
      expect(find.byType(OrdersPage), findsOneWidget);

      // Change to second tab (index 1) - should show ClientsPage
      await tester.tap(find.byIcon(Icons.person_outline).first);
      await tester.pumpAndSettle();

      // OrdersPage should no longer be visible
      expect(find.byType(OrdersPage), findsNothing);

      // Should show ClientsPage
      expect(find.byType(ClientsPage), findsOneWidget);
    });

    testWidgets('HomePage uses correct key', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());

      final homePage = find.byKey(const Key('home_page'));
      expect(homePage, findsOneWidget);
    });

    testWidgets('AppBar has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final appBar = find.byType(AppBar);
      final appBarWidget = tester.widget<AppBar>(appBar);

      expect(appBarWidget.backgroundColor, equals(ColorsApp.backgroundColor));
    });

    testWidgets('AppBar has zero elevation', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final appBar = find.byType(AppBar);
      final appBarWidget = tester.widget<AppBar>(appBar);

      expect(appBarWidget.elevation, equals(0));
    });

    testWidgets('NavigationBar has correct background color', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      final navigationBarWidget = tester.widget<NavigationBar>(navigationBar);

      expect(navigationBarWidget.backgroundColor, equals(ColorsApp.backgroundColor));
    });

    testWidgets('NavigationBar has correct indicator color', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp());
      await tester.pumpAndSettle();

      final navigationBar = find.byType(NavigationBar);
      final navigationBarWidget = tester.widget<NavigationBar>(navigationBar);

      expect(navigationBarWidget.indicatorColor, equals(ColorsApp.secondaryColor));
    });
  });
}

Widget _buildTestApp() {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LoginProvider>(
        create: (context) => LoginProvider()..oUser = User(
          sEmail: 'test@example.com',
          sName: 'Test User',
          sAccessToken: 'test_token',
          sRefreshToken: 'refresh_token',
          sRole: 'user'
        )
      ),
      Provider<TextsUtil>(
        create: (context) => MockTextsUtil(),
      ),
    ],
    child: MaterialApp(
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('es', 'ES'),
      ],
      locale: const Locale('en', 'US'),
      home: const HomePage()
    )
  );
}

void _setupAssetMock() {
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

      // Cualquier .png (logo) -> PNG transparente
      if (key.endsWith('.png')) {
        return ByteData.view(Uint8List.fromList(_kTransparentPng).buffer);
      }

      return null;
    },
  );
}