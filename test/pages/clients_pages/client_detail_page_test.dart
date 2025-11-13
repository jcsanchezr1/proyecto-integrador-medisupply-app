import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/clients_pages/client_detail_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';

// Mock classes
class MockLoginProvider extends ChangeNotifier implements LoginProvider {
  @override
  User? oUser = User(
    sId: 'user123',
    sAccessToken: 'token123',
    sName: 'Test User',
    sEmail: 'user@test.com',
    sRole: 'Cliente',
  );

  @override
  bool bLoading = false;
}

class MockTextsUtil implements TextsUtil {
  @override
  final Locale locale = const Locale('en', 'US');

  @override
  late Map<String, dynamic> mLocalizedStrings;

  MockTextsUtil() {
    mLocalizedStrings = {
      'new_order': {'title': 'Create order'},
    };
  }

  @override
  Future<void> load() async {
    // Mock implementation - do nothing
  }

  @override
  dynamic getText(String sKey) {
    List<String> lKeys = sKey.split('.');
    dynamic value = mLocalizedStrings;
    for (var k in lKeys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value;
  }

  @override
  String formatLocalizedDate(BuildContext context, String isoDateString) {
    return isoDateString; // Simple mock implementation
  }

  @override
  Color getStatusColor(String sStatus) {
    return Colors.blue; // Simple mock implementation
  }

  @override
  String formatNumber(double dNumber) {
    return dNumber.toString(); // Simple mock implementation
  }

  @override
  String largeFormatLocalizedDate(BuildContext context, String sDateString) {
    return sDateString; // Simple mock implementation
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Client testClient;

  setUp(() {
    testClient = Client(
      sClientId: 'client123',
      sName: 'Test Hospital',
      sEmail: 'contact@testhospital.com',
      sPhone: '+1234567890',
      sAddress: '123 Test Street, Test City',
      sInstitutionType: 'Hospital',
      sLogoUrl: 'https://example.com/logo.png',
      sSpeciality: 'Cardiology',
      sApplicantName: 'Dr. Smith',
      sApplicantEmail: 'smith@test.com',
      bEnabled: true,
    );

  });

  group('ClientDetailPage', () {
    testWidgets('builds correctly with client data', (WidgetTester tester) async {
      // Arrange
      final mockTextsUtil = MockTextsUtil();
      final mockLoginProvider = MockLoginProvider();

      // Act
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)), // Larger viewport to prevent overflow
          child: MultiProvider(
            providers: [
              Provider<TextsUtil>.value(value: mockTextsUtil),
              ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
            ],
            child: MaterialApp(
              home: ClientDetailPage(oClient: testClient),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Test Hospital'), findsOneWidget);
    });

    testWidgets('displays client information correctly', (WidgetTester tester) async {
      // Arrange
      final mockTextsUtil = MockTextsUtil();
      final mockLoginProvider = MockLoginProvider();

      // Act
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: MultiProvider(
            providers: [
              Provider<TextsUtil>.value(value: mockTextsUtil),
              ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
            ],
            child: MaterialApp(
              home: ClientDetailPage(oClient: testClient),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Hospital'), findsOneWidget);
      expect(find.text('Hospital'), findsOneWidget); // Institution type
      expect(find.text('123 Test Street, Test City'), findsOneWidget); // Address
      expect(find.text('contact@testhospital.com'), findsOneWidget); // Email
      expect(find.text('+1234567890'), findsOneWidget); // Phone
    });

    testWidgets('displays main button', (WidgetTester tester) async {
      // Arrange
      final mockTextsUtil = MockTextsUtil();
      final mockLoginProvider = MockLoginProvider();

      // Act
      await tester.pumpWidget(
        MediaQuery(
          data: const MediaQueryData(size: Size(800, 1200)),
          child: MultiProvider(
            providers: [
              Provider<TextsUtil>.value(value: mockTextsUtil),
              ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
            ],
            child: MaterialApp(
              home: ClientDetailPage(oClient: testClient),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(MainButton), findsOneWidget);
      expect(find.text('Create order'), findsOneWidget);
    });
  });
}