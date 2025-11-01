import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/clients_pages/clients_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';

// Mock classes
class MockFetchData extends Mock implements FetchData {}
class MockLoginProvider extends Mock implements LoginProvider {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late MockLoginProvider mockLoginProvider;

  setUp(() {
    mockLoginProvider = MockLoginProvider();
    SharedPreferences.setMockInitialValues({});
  });

  group('ClientsPage', () {
    testWidgets('builds correctly', (WidgetTester tester) async {
      // Arrange
      when(mockLoginProvider.oUser).thenReturn(
        User(
          sId: 'user123',
          sAccessToken: 'token123',
          sName: 'Test User',
          sEmail: 'user@test.com',
          sRole: 'Vendor',
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LoginProvider>.value(
            value: mockLoginProvider,
            child: const ClientsPage(),
          ),
        ),
      );

      // Assert - Widget should be built without errors
      expect(find.byType(ClientsPage), findsOneWidget);
    });

    testWidgets('accepts custom fetchData parameter', (WidgetTester tester) async {
      // Arrange
      final customFetchData = MockFetchData();
      when(mockLoginProvider.oUser).thenReturn(
        User(
          sId: 'user123',
          sAccessToken: 'token123',
          sName: 'Test User',
          sEmail: 'user@test.com',
          sRole: 'Vendor',
        ),
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: ChangeNotifierProvider<LoginProvider>.value(
            value: mockLoginProvider,
            child: ClientsPage(fetchData: customFetchData),
          ),
        ),
      );

      // Assert
      expect(find.byType(ClientsPage), findsOneWidget);
    });
  });
}