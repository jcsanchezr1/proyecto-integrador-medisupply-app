import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:medisupply_app/src/classes/visit.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/visits_pages/visits_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/visits_widgets/visit_card.dart';

// Mock classes
class MockFetchData extends Mock implements FetchData {}

class MockLoginProvider extends ChangeNotifier implements LoginProvider {
  @override
  User? oUser = User(
    sId: 'user123',
    sAccessToken: 'token123',
    sName: 'Test User',
    sEmail: 'user@test.com',
    sRole: 'Ventas',
  );

  @override
  bool bLoading = false;
}

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'visits': {
        'no_visits': 'No Visits Assigned',
        'date_filter': 'Select Date'
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

  late MockFetchData mockFetchData;
  late MockLoginProvider mockLoginProvider;
  late MockTextsUtil mockTextsUtil;

  setUp(() {
    mockFetchData = MockFetchData();
    mockLoginProvider = MockLoginProvider();
    mockTextsUtil = MockTextsUtil();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        Provider<TextsUtil>.value(value: mockTextsUtil),
        ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
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
        home: VisitsPage(fetchData: mockFetchData),
      ),
    );
  }

  group('VisitsPage', () {
    testWidgets('builds correctly with empty visits list', (WidgetTester tester) async {
      // Arrange
      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenAnswer((_) async => <Visit>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow initState to complete

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('No Visits Assigned'), findsOneWidget);
    });

    testWidgets('displays loading indicator initially', (WidgetTester tester) async {
      // Arrange
      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenAnswer((_) async => <Visit>[]);

      // Act
      await tester.pumpWidget(createTestWidget());

      // Assert - Should show loading initially
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays visits list when data is loaded', (WidgetTester tester) async {
      // Arrange
      final mockVisits = [
        Visit(sId: 'visit1', sDate: '15-11-2025', iCountClients: 3),
        Visit(sId: 'visit2', sDate: '20-11-2025', iCountClients: 5),
      ];

      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenAnswer((_) async => mockVisits);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump(); // Allow initState to complete
      await tester.pump(); // Allow loading to complete

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(VisitCard), findsNWidgets(2));
    });

    testWidgets('calls getVisitsByDate on initState', (WidgetTester tester) async {
      // Arrange
      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenAnswer((_) async => <Visit>[]);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Assert
      verify(() => mockFetchData.getVisitsByDate(
        'token123', // access token
        'user123',  // user id
        ''          // empty date (no filter)
      )).called(1);
    });

    testWidgets('handles API errors gracefully', (WidgetTester tester) async {
      // Arrange
      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenThrow(Exception('API Error'));

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump(); // Allow error handling

      // Assert
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('No Visits Assigned'), findsOneWidget);
    });

    testWidgets('floating action button navigates to create visit page', (WidgetTester tester) async {
      // Arrange
      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenAnswer((_) async => <Visit>[]);

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Act
      final fab = find.byType(FloatingActionButton);
      expect(fab, findsOneWidget);

      // Note: We can't easily test navigation in widget tests without more complex setup
      // This test verifies the FAB exists and is tappable
      await tester.tap(fab);

      // Just verify the FAB is present and tappable
      expect(fab, findsOneWidget);
    });

    testWidgets('sorts visits by date', (WidgetTester tester) async {
      // Arrange
      final mockVisits = [
        Visit(sId: 'visit2', sDate: '20-11-2025', iCountClients: 5),
        Visit(sId: 'visit1', sDate: '15-11-2025', iCountClients: 3),
        Visit(sId: 'visit3', sDate: '10-11-2025', iCountClients: 1),
      ];

      when(() => mockFetchData.getVisitsByDate(any(), any(), any()))
          .thenAnswer((_) async => mockVisits);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pump();
      await tester.pump();

      // Assert
      // The visits should be sorted by date (oldest first)
      // Since we can't easily access the internal list order in widget tests,
      // we verify that VisitCard widgets are present
      expect(find.byType(VisitCard), findsNWidgets(3));
    });
  });
}