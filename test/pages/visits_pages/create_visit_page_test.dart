import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/pages/visits_pages/create_visit_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/create_visit_provider.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';
import 'package:medisupply_app/src/widgets/create_visit_widgets/clients_multi_select.dart';
import 'package:medisupply_app/src/widgets/create_visit_widgets/date_visit.dart';

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

class MockCreateVisitProvider extends ChangeNotifier implements CreateVisitProvider {
  @override
  List<Client> get lClients => _lClients;
  List<Client> _lClients = [];

  @override
  List<MultiSelectItem<Client>> get lItems => _lItems;
  List<MultiSelectItem<Client>> _lItems = [];

  @override
  List<Client> get lSelectedClients => _lSelectedClients;
  List<Client> _lSelectedClients = [];

  @override
  DateTime? get selectedDate => _selectedDate;
  DateTime? _selectedDate;

  @override
  void setClients(List<Client> lClients) {
    _lClients = lClients;
    notifyListeners();
  }

  @override
  void setItems(List<MultiSelectItem<Client>> lItems) {
    _lItems = lItems;
    notifyListeners();
  }

  @override
  void setSelectedClients(List<Client> lSelectedClients) {
    _lSelectedClients = lSelectedClients;
    notifyListeners();
  }

  @override
  void removeClientSelected(Client oClient) {
    _lSelectedClients.remove(oClient);
    notifyListeners();
  }

  @override
  void setSelectedDate(DateTime? selectedDate) {
    _selectedDate = selectedDate;
    notifyListeners();
  }
}

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'new_visit': {
        'title': 'Create Visit',
        'create_button': 'Create Visit',
        'success_visit': 'Visit created successfully',
        'error_visit': 'Error creating visit',
        'empty_fields': 'Please fill all fields',
        'select_clients': 'Select Clients',
        'clients': 'Clients',
        'cancel': 'Cancel',
        'confirm': 'Confirm',
        'search': 'Search'
      },
      'visits': {
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
  late MockCreateVisitProvider mockCreateVisitProvider;
  late MockTextsUtil mockTextsUtil;

  setUp(() {
    mockFetchData = MockFetchData();
    mockLoginProvider = MockLoginProvider();
    mockCreateVisitProvider = MockCreateVisitProvider();
    mockTextsUtil = MockTextsUtil();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        Provider<TextsUtil>.value(value: mockTextsUtil),
        ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
        ChangeNotifierProvider<CreateVisitProvider>.value(value: mockCreateVisitProvider),
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
        home: CreateVisitPage(oFetchData: mockFetchData),
      ),
    );
  }

  group('CreateVisitPage', () {
    testWidgets('builds correctly', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
        Client(sClientId: 'client2', sName: 'Client 2'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Create Visit'), findsNWidgets(2)); // Title and button
      expect(find.byType(MainButton), findsOneWidget);
    });

    testWidgets('loads clients on init', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Verify clients were loaded into provider
      expect(mockCreateVisitProvider.lClients.length, 1);
      expect(mockCreateVisitProvider.lClients[0].sName, 'Client 1');
      expect(mockCreateVisitProvider.lItems.length, 1);
    });

    testWidgets('sets clients in provider after loading', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
        Client(sClientId: 'client2', sName: 'Client 2'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Verify clients and items are set in provider
      expect(mockCreateVisitProvider.lClients.length, 2);
      expect(mockCreateVisitProvider.lItems.length, 2);
      expect(mockCreateVisitProvider.lItems[0].value.sName, 'Client 1');
      expect(mockCreateVisitProvider.lItems[1].value.sName, 'Client 2');

      // Verify the page structure
      expect(find.byType(ClientsMultiSelect), findsOneWidget);
      expect(find.byType(DateVisit), findsOneWidget);
    });

    testWidgets('createVisit shows error when no date selected', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Set selected clients but no date
      mockCreateVisitProvider.setSelectedClients(mockClients);

      // Act
      final button = find.byType(MainButton);
      await tester.tap(button);
      await tester.pump();

      // Assert - Should show error message
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('createVisit shows error when no clients selected', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Set selected date but no clients
      mockCreateVisitProvider.setSelectedDate(DateTime.now());

      // Act
      final button = find.byType(MainButton);
      await tester.tap(button);
      await tester.pump();

      // Assert - Should show error message
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('createVisit succeeds and shows success message', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);
      when(() => mockFetchData.createVisit(any(), any(), any()))
          .thenAnswer((_) async => true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Set both date and clients
      mockCreateVisitProvider.setSelectedClients(mockClients);
      mockCreateVisitProvider.setSelectedDate(DateTime.now());

      // Act
      final button = find.byType(MainButton);
      await tester.tap(button);
      await tester.pump();

      // Assert - Should show success message
      expect(find.text('Visit created successfully'), findsOneWidget);
    });

    testWidgets('createVisit fails and shows error message', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);
      when(() => mockFetchData.createVisit(any(), any(), any()))
          .thenAnswer((_) async => false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Set both date and clients
      mockCreateVisitProvider.setSelectedClients(mockClients);
      mockCreateVisitProvider.setSelectedDate(DateTime.now());

      // Act
      final button = find.byType(MainButton);
      await tester.tap(button);
      await tester.pump();

      // Assert - Should show error message
      expect(find.text('Error creating visit'), findsOneWidget);
    });

    testWidgets('shows empty fields error when neither date nor clients selected', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Don't set any data

      // Act
      final button = find.byType(MainButton);
      await tester.tap(button);
      await tester.pump();

      // Assert - Should show empty fields error
      expect(find.text('Please fill all fields'), findsOneWidget);
    });

    testWidgets('calls getAssignedClients with correct parameters', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(
        mockLoginProvider.oUser!.sAccessToken!,
        mockLoginProvider.oUser!.sId!
      )).thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      verify(() => mockFetchData.getAssignedClients(
        'token123',
        'user123'
      )).called(1);
    });

    testWidgets('sets clients and items in provider after loading', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
        Client(sClientId: 'client2', sName: 'Client 2'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Provider should have clients and items set
      expect(mockCreateVisitProvider.lClients.length, 2);
      expect(mockCreateVisitProvider.lItems.length, 2);
      expect(mockCreateVisitProvider.lItems[0].value.sName, 'Client 1');
      expect(mockCreateVisitProvider.lItems[1].value.sName, 'Client 2');
    });

    testWidgets('handles empty client list gracefully', (WidgetTester tester) async {
      // Arrange
      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => []);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      expect(mockCreateVisitProvider.lClients.length, 0);
      expect(mockCreateVisitProvider.lItems.length, 0);
      // Page should still render without crashing
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('page has correct layout structure', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert - Check that key widgets exist
      expect(find.byType(ClientsMultiSelect), findsOneWidget);
      expect(find.byType(DateVisit), findsOneWidget);
      expect(find.byType(MainButton), findsOneWidget);

      // Check that the main button contains the correct text
      expect(find.text('Create Visit'), findsNWidgets(2)); // Title and button
    });

    testWidgets('app bar has correct title and styling', (WidgetTester tester) async {
      // Arrange
      final mockClients = [
        Client(sClientId: 'client1', sName: 'Client 1'),
      ];

      when(() => mockFetchData.getAssignedClients(any(), any()))
          .thenAnswer((_) async => mockClients);

      // Act
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Assert
      final appBar = tester.widget<AppBar>(find.byType(AppBar));
      expect(appBar.backgroundColor, ColorsApp.backgroundColor);
      expect(appBar.scrolledUnderElevation, 0.0);
      expect(find.text('Create Visit'), findsNWidgets(2)); // Title in app bar
    });
  });
}