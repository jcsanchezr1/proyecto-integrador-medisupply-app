import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:medisupply_app/src/classes/order.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/orders_pages/orders_page.dart';
import 'package:medisupply_app/src/pages/orders_pages/new_order_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/order_provider.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/oder_widgets/order_card.dart';

import '../../helpers/orders_page_test.mocks.dart';

@GenerateMocks([
  FetchData,
  LoginProvider,
])
class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockTextsUtilDelegate extends TextsUtil {
  MockTextsUtilDelegate() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'orders': {
        'no_orders': 'You have not placed any orders yet.',
        'title': 'Orders'
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
  late MockTextsUtilDelegate mockTextsUtil;
  late User testUser;

  setUp(() {
    mockFetchData = MockFetchData();
    mockLoginProvider = MockLoginProvider();
    mockTextsUtil = MockTextsUtilDelegate();

    testUser = User(
      sId: 'test_user_id',
      sEmail: 'test@example.com',
      sName: 'Test User',
      sAccessToken: 'test_token',
      sRefreshToken: 'refresh_token',
      sRole: 'user'
    );

    // Setup default mocks
    when(mockLoginProvider.oUser).thenReturn(testUser);
    // Default stub for getOrders - returns empty list
    when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);
  });

  tearDown(() {
    reset(mockFetchData);
    reset(mockLoginProvider);
  });

  group('OrdersPage Widget Tests', () {
    testWidgets('OrdersPage creates successfully', (WidgetTester tester) async {
      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));

      expect(find.byType(OrdersPage), findsOneWidget);
    });

    testWidgets('OrdersPage shows loading indicator initially', (WidgetTester tester) async {
      // Mock empty orders list (will be called after initState)
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('OrdersPage calls getOrdersByRol on initState', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pump(); // Allow initState to run

      verify(mockFetchData.getOrders(
        testUser.sAccessToken!,
        testUser.sId!,
        testUser.sRole!
      )).called(1);
    });

    testWidgets('OrdersPage shows empty message when no orders', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pump(); // initState
      await tester.pump(); // setState after fetch

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('You have not placed any orders yet.'), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
    });

    testWidgets('OrdersPage shows orders list when orders exist', (WidgetTester tester) async {
      final testOrders = [
        Order(
          iId: 1,
          sOrderNumber: 'ORD-001',
          sClientId: 'client1',
          sVendorId: 'vendor1',
          sStatus: 'pending',
          sDeliveryDate: '2024-01-01',
          sAssignedTruck: 'truck1',
          sCreatedAt: '2024-01-01T00:00:00Z',
          sUpdatedAt: '2024-01-01T00:00:00Z'
        ),
        Order(
          iId: 2,
          sOrderNumber: 'ORD-002',
          sClientId: 'client2',
          sVendorId: 'vendor2',
          sStatus: 'completed',
          sDeliveryDate: '2024-01-02',
          sAssignedTruck: 'truck2',
          sCreatedAt: '2024-01-02T00:00:00Z',
          sUpdatedAt: '2024-01-02T00:00:00Z'
        )
      ];

      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => testOrders);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pump(); // initState
      await tester.pump(); // setState after fetch

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(OrderCard), findsNWidgets(2));
      expect(find.text('You have not placed any orders yet.'), findsNothing);
    });

    testWidgets('OrdersPage has FloatingActionButton', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.byIcon(Icons.add_rounded), findsOneWidget);
    });

    testWidgets('FloatingActionButton has correct properties', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pumpAndSettle();

      final fab = find.byType(FloatingActionButton);
      final fabWidget = tester.widget<FloatingActionButton>(fab);

      expect(fabWidget.backgroundColor, equals(ColorsApp.backgroundColor));
      expect(fabWidget.child, isA<Icon>());
      expect((fabWidget.child as Icon).color, equals(ColorsApp.primaryColor));
      expect((fabWidget.child as Icon).icon, equals(Icons.add_rounded));
    });

    testWidgets('FloatingActionButton navigates to NewOrderPage on tap', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      final mockObserver = MockNavigatorObserver();

      await tester.pumpWidget(_buildTestApp(
        mockFetchData,
        mockLoginProvider,
        mockTextsUtil,
        navigatorObservers: [mockObserver]
      ));
      await tester.pumpAndSettle();

      // Tap the FAB
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      // Verify navigation occurred (check that didPush was called)
      // Verify navigation occurred by checking that NewOrderPage is in the widget tree
      // The mockObserver verification is complex due to type issues, so we rely on the widget tree check

      // Check that NewOrderPage is now in the widget tree
      expect(find.byType(NewOrderPage), findsOneWidget);
    });

    testWidgets('OrdersPage handles fetch error gracefully', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenThrow(Exception('Network error'));

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pump(); // initState
      await tester.pump(); // setState after fetch

      // Should show empty state when fetch fails
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('You have not placed any orders yet.'), findsOneWidget);
    });

    testWidgets('OrdersPage rebuilds when orders change', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pump(); // initState
      await tester.pump(); // setState after fetch

      // Initially empty
      expect(find.byType(OrderCard), findsNothing);

      // Simulate orders being added (this would happen in real app through state management)
      final state = tester.state(find.byType(OrdersPage));
      final testOrders = [
        Order(
          iId: 1,
          sOrderNumber: 'ORD-001',
          sClientId: 'client1',
          sVendorId: 'vendor1',
          sStatus: 'pending',
          sDeliveryDate: '2024-01-01',
          sAssignedTruck: 'truck1',
          sCreatedAt: '2024-01-01T00:00:00Z',
          sUpdatedAt: '2024-01-01T00:00:00Z'
        )
      ];

      // Manually set orders (simulating what would happen with real data)
      (state as dynamic).setState(() {
        (state as dynamic).lOrders = testOrders;
        (state as dynamic).bIsLoading = false;
      });

      await tester.pump();

      expect(find.byType(OrderCard), findsOneWidget);
    });

    testWidgets('OrdersPage uses Scaffold as root widget', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pumpAndSettle();

      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('OrdersPage body changes based on loading state', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));

      // Initially loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      await tester.pump(); // initState completes
      await tester.pump(); // setState after fetch

      // After loading completes
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('You have not placed any orders yet.'), findsOneWidget);
    });
  });

  group('OrdersPage State Management', () {
    testWidgets('OrdersPage starts in loading state', (WidgetTester tester) async {
      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => []);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));

      // Initially should show loading
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.byType(ListView), findsNothing);
      expect(find.text('You have not placed any orders yet.'), findsNothing);
    });

    testWidgets('OrdersPage shows data after loading', (WidgetTester tester) async {
      final testOrders = [
        Order(
          iId: 1,
          sOrderNumber: 'ORD-001',
          sClientId: 'client1',
          sVendorId: 'vendor1',
          sStatus: 'pending',
          sDeliveryDate: '2024-01-01',
          sAssignedTruck: 'truck1',
          sCreatedAt: '2024-01-01T00:00:00Z',
          sUpdatedAt: '2024-01-01T00:00:00Z'
        )
      ];

      when(mockFetchData.getOrders(any, any, any)).thenAnswer((_) async => testOrders);

      await tester.pumpWidget(_buildTestApp(mockFetchData, mockLoginProvider, mockTextsUtil));
      await tester.pump(); // initState
      await tester.pump(); // setState after fetch

      // After loading, should show orders
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.byType(ListView), findsOneWidget);
      expect(find.byType(OrderCard), findsOneWidget);
    });
  });
}

Widget _buildTestApp(
  MockFetchData mockFetchData,
  MockLoginProvider mockLoginProvider,
  MockTextsUtilDelegate mockTextsUtil, {
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return MultiProvider(
    providers: [
      ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
      ChangeNotifierProvider<OrderProvider>(
        create: (context) => OrderProvider(),
      ),
      Provider<TextsUtil>.value(value: mockTextsUtil),
      Provider<FetchData>.value(value: mockFetchData),
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
      navigatorObservers: navigatorObservers,
      home: OrdersPage(fetchData: mockFetchData)
    )
  );
}