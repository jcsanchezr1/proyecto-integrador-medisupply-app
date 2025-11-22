import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/widgets/visits_widgets/create_visit_form.dart';
import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/visits_widgets/info_visit_item.dart';
import 'package:medisupply_app/src/widgets/visits_widgets/findings_text_field.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/widgets/general_widgets/button_file_picker.dart';

class MockFetchData extends Mock implements FetchData {}

class MockLoginProvider extends Mock implements LoginProvider {}

class MockCreateAccountProvider extends Mock implements CreateAccountProvider {}

class MockUser extends Mock implements User {}

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'transversal': {
        'error_file': 'The selected file exceeds the maximum size of 30MB.'
      },
      'visit_detail': {
        'findings_label': 'Findings',
        'findings_hint': 'Enter findings',
        'evidence_label': 'Upload Evidence',
        'register_button': 'Register',
        'error_register': 'Error registering',
        'success_register': 'Success'
      }
    };
  }

  @override
  Future<void> load() async {
    // Mock implementation - do nothing
  }

  static MockTextsUtil? of(BuildContext context) {
    return _instance;
  }

  static MockTextsUtil? _instance;
}

void main() {
  late MockLoginProvider mockLoginProvider;
  late MockCreateAccountProvider mockCreateAccountProvider;
  late MockFetchData mockFetchData;
  late MockTextsUtil mockTextsUtil;
  late Client mockClient;
  late MockUser mockUser;

  setUpAll(() {
    registerFallbackValue(File('dummy.mp4'));
  });

  setUp(() {
    mockLoginProvider = MockLoginProvider();
    mockCreateAccountProvider = MockCreateAccountProvider();
    mockFetchData = MockFetchData();
    mockTextsUtil = MockTextsUtil();
    MockTextsUtil._instance = mockTextsUtil;
    mockUser = MockUser();
    mockClient = Client(
      sClientId: 'client1',
      sName: 'Test Client',
      sAddress: 'Test Address',
      sEmail: 'test@email.com',
      sPhone: '123456789'
    );

    // Setup mock returns
    when(() => mockLoginProvider.oUser).thenReturn(mockUser);
    when(() => mockUser.sAccessToken).thenReturn('test_token');
    when(() => mockUser.sId).thenReturn('user123');
    when(() => mockLoginProvider.bLoading).thenReturn(false);
    when(() => mockCreateAccountProvider.logoFile).thenReturn(null); // Will be set in tests
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        Provider<TextsUtil>.value(value: mockTextsUtil),
        ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
        ChangeNotifierProvider<CreateAccountProvider>.value(value: mockCreateAccountProvider),
        Provider<FetchData>.value(value: mockFetchData),
      ],
      child: MaterialApp(
        home: Scaffold(
          body: SizedBox(
            height: 800, // Ensure enough height for the widget
            child: CreateVisitForm(
              oClient: mockClient,
              sVisitId: 'visit123',
              oFetchData: mockFetchData,
            ),
          ),
        ),
      ),
    );
  }

  group('CreateVisitForm Widget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(CreateVisitForm), findsOneWidget);
      expect(find.byType(InfoVisitItem), findsNWidgets(3)); // Address, email, phone
      expect(find.byType(FindingsTextField), findsOneWidget);
      expect(find.byType(ButtonFilePicker), findsOneWidget);
      expect(find.byType(MainButton), findsOneWidget);
    });

    testWidgets('displays client information correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Test Client'), findsOneWidget);
      expect(find.text('Test Address'), findsOneWidget);
      expect(find.text('test@email.com'), findsOneWidget);
      expect(find.text('123456789'), findsOneWidget);
    });

    testWidgets('close button works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final closeButton = find.byIcon(Icons.close);
      expect(closeButton, findsOneWidget);

      await tester.tap(closeButton);
      await tester.pumpAndSettle();

      // Since it's a pop, we can't easily test navigation in this setup
      // But we can verify the button exists and is tappable
    });

    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(SingleChildScrollView), findsOneWidget);
      // Check for main container
      expect(find.byType(Container), findsWidgets); // At least one container
    });

    testWidgets('register button displays correct text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Register'), findsOneWidget);
    });

    testWidgets('findings text field is present', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(TextFormField), findsOneWidget); // Inside FindingsTextField
    });

    testWidgets('can enter text in findings field', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      const testText = 'Test findings text';
      await tester.enterText(find.byType(TextFormField), testText);
      await tester.pump();

      // Verify text was entered
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller?.text, equals(testText));
    });

    testWidgets('register button has onPressed callback', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final mainButton = tester.widget<MainButton>(find.byType(MainButton));
      expect(mainButton.onPressed, isNotNull);
    });

    testWidgets('handles client with null values', (WidgetTester tester) async {
      final clientWithNulls = Client(
        sClientId: 'client1',
        sName: null,
        sAddress: null,
        sEmail: null,
        sPhone: null
      );

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<TextsUtil>.value(value: mockTextsUtil),
            ChangeNotifierProvider<LoginProvider>.value(value: mockLoginProvider),
            ChangeNotifierProvider<CreateAccountProvider>.value(value: mockCreateAccountProvider),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CreateVisitForm(
                oClient: clientWithNulls,
                sVisitId: 'visit123',
                oFetchData: mockFetchData,
              ),
            ),
          ),
        )
      );

      // Should not crash with null values
      expect(find.byType(CreateVisitForm), findsOneWidget);
      expect(find.byType(InfoVisitItem), findsNWidgets(3)); // Still shows 3 items even with null text
    });

    testWidgets('displays correct number of info items', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have exactly 3 InfoVisitItem widgets (address, email, phone)
      expect(find.byType(InfoVisitItem), findsNWidgets(3));
    });

    testWidgets('has correct spacing elements', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Should have multiple SizedBox widgets for spacing
      expect(find.byType(SizedBox), findsWidgets);
    });

    testWidgets('container has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.color, isNotNull); // Should have background color
      expect(decoration.borderRadius, isNotNull); // Should have border radius
    });

    testWidgets('gesture detector close button works', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // Find the close button specifically by looking for GestureDetector with close icon
      final closeIcon = find.byIcon(Icons.close);
      expect(closeIcon, findsOneWidget);

      final gestureDetector = find.ancestor(
        of: closeIcon,
        matching: find.byType(GestureDetector)
      );
      expect(gestureDetector, findsOneWidget);

      // The gesture detector should exist (navigation testing would require more setup)
      final gestureWidget = tester.widget<GestureDetector>(gestureDetector);
      expect(gestureWidget.onTap, isNotNull);
    });

    testWidgets('controller is properly initialized', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      // The controller should be accessible through the FindingsTextField
      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller, isNotNull);
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('form handles empty findings text', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      // Initially empty
      expect(textField.controller!.text, isEmpty);

      // Can set empty text
      await tester.enterText(find.byType(TextFormField), '');
      expect(textField.controller!.text, isEmpty);
    });

    testWidgets('register button executes registerFindings successfully', (WidgetTester tester) async {
      // Adjust surface size to fit the widget
      await tester.binding.setSurfaceSize(Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Setup successful upload
      when(() => mockFetchData.uploadVisitFindings(
        'test_token', 'user123', 'visit123', 'client1', any(), any()
      )).thenAnswer((_) async => true);

      // Mock file exists
      final mockFile = File('test.mp4');
      when(() => mockCreateAccountProvider.logoFile).thenReturn(mockFile);

      await tester.pumpWidget(createTestWidget());

      // Enter some findings text
      await tester.enterText(find.byType(TextFormField), 'Test findings');
      await tester.pump();

      // Tap register button
      await tester.tap(find.byType(MainButton));
      await tester.pump(); // Allow async operation to start

      // Verify loading state was set
      verify(() => mockLoginProvider.bLoading = true).called(1);

      // Wait for async operation to complete
      await tester.pumpAndSettle();

      // Verify uploadVisitFindings was called
      verify(() => mockFetchData.uploadVisitFindings(
        'test_token', 'user123', 'visit123', 'client1', 'Test findings', mockFile
      )).called(1);

      // Verify loading state was reset
      verify(() => mockLoginProvider.bLoading = false).called(1);
    });

    testWidgets('register button shows error on failed registration', (WidgetTester tester) async {
      // Adjust surface size to fit the widget
      await tester.binding.setSurfaceSize(Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Setup failed upload
      when(() => mockFetchData.uploadVisitFindings(
        'test_token', 'user123', 'visit123', 'client1', any(), any()
      )).thenAnswer((_) async => false);

      // Mock file exists
      final mockFile = File('test.mp4');
      when(() => mockCreateAccountProvider.logoFile).thenReturn(mockFile);

      await tester.pumpWidget(createTestWidget());

      // Enter findings text
      await tester.enterText(find.byType(TextFormField), 'Error findings');
      await tester.pump();

      // Tap register button
      await tester.tap(find.byType(MainButton));
      await tester.pumpAndSettle();

      // Verify error snackbar is shown
      expect(find.text('Error registering'), findsOneWidget);

      // Verify loading states
      verify(() => mockLoginProvider.bLoading = true).called(1);
      verify(() => mockLoginProvider.bLoading = false).called(1);
    });

    testWidgets('register button trims findings text before sending', (WidgetTester tester) async {
      // Adjust surface size to fit the widget
      await tester.binding.setSurfaceSize(Size(800, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));

      // Setup successful upload
      when(() => mockFetchData.uploadVisitFindings(
        'test_token', 'user123', 'visit123', 'client1', 'Test findings with spaces', any()
      )).thenAnswer((_) async => true);

      // Mock file exists
      final mockFile = File('test.mp4');
      when(() => mockCreateAccountProvider.logoFile).thenReturn(mockFile);

      await tester.pumpWidget(createTestWidget());

      // Enter text with leading/trailing whitespace
      await tester.enterText(find.byType(TextFormField), '  Test findings with spaces  ');
      await tester.pump();

      // Tap register button
      await tester.tap(find.byType(MainButton));
      await tester.pumpAndSettle();

      // Verify uploadVisitFindings was called with trimmed text
      verify(() => mockFetchData.uploadVisitFindings(
        'test_token', 'user123', 'visit123', 'client1', 'Test findings with spaces', mockFile
      )).called(1);
    });
  });
}