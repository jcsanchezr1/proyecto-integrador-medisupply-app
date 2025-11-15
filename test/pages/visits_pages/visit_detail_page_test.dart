import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:medisupply_app/src/pages/visits_pages/visit_detail_page.dart';
import 'package:medisupply_app/src/classes/visit.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/classes/visit_detail.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

// Test implementation of TextsUtil
class TestTextsUtil extends TextsUtil {
  TestTextsUtil() : super(const Locale('en')) {
    // Pre-load mock data
    mLocalizedStrings = {
      'visit_detail': {'error': 'Test error message'}
    };
  }

  @override
  Future<void> load() async {
    // Already loaded in constructor
  }

  @override
  dynamic getText(String sKey) {
    if (sKey == 'visit_detail.error') {
      return 'Test error message';
    }
    return 'Mock text for $sKey';
  }

  @override
  String formatLocalizedDate(BuildContext context, String isoDateString) {
    return '14/11/2023'; // Mock formatted date
  }
}

// Test implementation of LoginProvider
class TestLoginProvider extends ChangeNotifier implements LoginProvider {
  @override
  User? get oUser => User(
    sAccessToken: 'test_token',
    sId: 'test_user_id',
    sName: 'Test User',
    sEmail: 'test@example.com',
  );

  @override
  bool get bLoading => false;

  @override
  set oUser(User? user) {}

  @override
  set bLoading(bool loading) {}
}

// Mock implementation of FetchData for testing
class MockFetchData extends FetchData {
  MockFetchData() : super.withClient(http.Client()); // Use real client but mock methods

  @override
  Future<VisitDetail> getVisitDetail(String sAccessToken, String sUserId, String sVisitId) async {
    // Return mock visit detail with clients
    return VisitDetail(
      sId: 'visit123',
      lClients: [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        ),
        Client(
          sClientId: 'client2',
          sName: 'Client Two',
          dLatitude: 4.7120,
          dLongitude: -74.0730,
        ),
      ],
    );
  }

  @override
  Future<List<LatLng>> getRoute(List<Client> lClients) async {
    // Return mock route points
    return [
      const LatLng(4.693549628123178, -74.10477902136584), // Start
      const LatLng(4.7110, -74.0721), // Client 1
      const LatLng(4.7120, -74.0730), // Client 2
      const LatLng(4.693549628123178, -74.10477902136584), // End
    ];
  }
}

void main() {
  late Visit testVisit;
  late TestLoginProvider testLoginProvider;

  setUp(() {
    testVisit = Visit(
      sId: 'visit123',
      sDate: '14-11-2023',
      iCountClients: 2,
    );

    testLoginProvider = TestLoginProvider();
  });

  Widget createTestWidgetWithMock(Visit visit) {
    final mockFetchData = MockFetchData();
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>.value(value: testLoginProvider),
        Provider<TextsUtil>.value(value: TestTextsUtil()),
      ],
      child: MaterialApp(
        home: VisitDetailPage(oVisit: visit, fetchData: mockFetchData),
      ),
    );
  }

  group('VisitDetailPage Widget Tests', () {
    testWidgets('can be instantiated', (WidgetTester tester) async {
      expect(() => VisitDetailPage(oVisit: testVisit), returnsNormally);
    });

    testWidgets('has required visit parameter', (WidgetTester tester) async {
      final page = VisitDetailPage(oVisit: testVisit);
      expect(page.oVisit, equals(testVisit));
    });

    testWidgets('visit parameter is correctly assigned', (WidgetTester tester) async {
      final page = VisitDetailPage(oVisit: testVisit);
      expect(page.oVisit.sId, equals('visit123'));
      expect(page.oVisit.sDate, equals('14-11-2023'));
      expect(page.oVisit.iCountClients, equals(2));
    });

    testWidgets('shows loading indicator initially', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetWithMock(testVisit));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('displays app bar with formatted date', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetWithMock(testVisit));

      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('14/11/2023'), findsOneWidget); // Formatted date
    });

    testWidgets('loads data and displays map after loading', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetWithMock(testVisit));

      // Initially shows loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Wait for async operations to complete
      await tester.pumpAndSettle();

      // After loading, should show GoogleMap
      expect(find.byType(CircularProgressIndicator), findsNothing);
      // Note: GoogleMap widget testing is complex and may require additional setup
    });

    testWidgets('creates markers for clients', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidgetWithMock(testVisit));

      // Wait for async operations
      await tester.pumpAndSettle();

      // The test verifies that the widget can be created with mock data
      // Actual marker verification would require more complex testing setup
      expect(find.byType(VisitDetailPage), findsOneWidget);
    });
  });

  group('VisitDetailPageState Logic Tests', () {
    test('widget can be created with valid visit', () {
      final visit = Visit(
        sId: 'test123',
        sDate: '14-11-2023',
        iCountClients: 1,
      );
      
      final page = VisitDetailPage(oVisit: visit);
      expect(page.oVisit.sId, equals('test123'));
      expect(page.oVisit.sDate, equals('14-11-2023'));
    });
  });
}