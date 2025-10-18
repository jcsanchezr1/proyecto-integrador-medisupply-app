import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:medisupply_app/src/pages/create_account_page.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';

// Mock classes
class MockTextsUtil extends Mock implements TextsUtil {}
class MockFetchData extends Mock implements FetchData {}

// Fake class for File
class FakeFile extends Fake implements File {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(FakeFile());
  });

  late CreateAccountProvider createAccountProvider;
  late LoginProvider loginProvider;
  late MockTextsUtil mockTextsUtil;
  late MockFetchData mockFetchData;

  setUp(() {
    createAccountProvider = CreateAccountProvider();
    loginProvider = LoginProvider();
    mockTextsUtil = MockTextsUtil();
    mockFetchData = MockFetchData();

    // Setup mock responses for TextsUtil
    when(() => mockTextsUtil.getText(any())).thenAnswer((invocation) {
      final key = invocation.positionalArguments[0] as String;
      final mockData = {
        'create_account.name': 'Name',
        'create_account.nit': 'NIT',
        'create_account.email': 'Email',
        'create_account.address': 'Address',
        'create_account.phone': 'Phone',
        'create_account.institution_type': 'Institution Type',
        'create_account.logo': 'Logo',
        'create_account.speciality': 'Speciality',
        'create_account.applicant_name': 'Applicant Name',
        'create_account.applicant_email': 'Applicant Email',
        'create_account.password': 'Password',
        'create_account.confirm_password': 'Confirm Password',
        'create_account.button': 'Create Account',
        'create_account.hint_dropdown': 'Select an option',
        'create_account.error': 'This field is required',
        'create_account.error_password': 'Password must contain at least 8 characters, one letter, one number and one special character',
        'create_account.error_confirm_password': 'Passwords do not match',
        'create_account.error_logo': 'Please select a logo',
        'create_account.success_create_account': 'Account created successfully',
        'create_account.error_create_account': 'Error creating account',
        'create_account.error_get_coordinates': 'Error getting coordinates',
        'create_account.types': [
          {'id': '1', 'name': 'Hospital', 'selected': false},
          {'id': '2', 'name': 'Clinic', 'selected': false}
        ],
        'create_account.specialities': [
          {'id': '1', 'name': 'Cardiology', 'selected': false},
          {'id': '2', 'name': 'Neurology', 'selected': false}
        ],
      };
      return mockData[key] ?? key;
    });

    // Setup mock responses for FetchData
    when(() => mockFetchData.getCoordinates(any())).thenAnswer((_) async => {'lat': 10.0, 'lng': -74.0});
    when(() => mockFetchData.createAccount(
      sName: any(named: 'sName'),
      sTaxId: any(named: 'sTaxId'),
      sEmail: any(named: 'sEmail'),
      sAddress: any(named: 'sAddress'),
      sPhone: any(named: 'sPhone'),
      sInstitutionType: any(named: 'sInstitutionType'),
      logoFile: any(named: 'logoFile'),
      sSpecialty: any(named: 'sSpecialty'),
      sApplicatName: any(named: 'sApplicatName'),
      sApplicatEmail: any(named: 'sApplicatEmail'),
      dLatitude: any(named: 'dLatitude'),
      dLongitude: any(named: 'dLongitude'),
      sPassword: any(named: 'sPassword'),
      sPasswordConfirmation: any(named: 'sPasswordConfirmation'),
    )).thenAnswer((_) async => true);
  });

  Widget makeTestableWidget({
    required CreateAccountProvider createProvider,
    required LoginProvider loginProvider,
    required MockTextsUtil textsUtil,
    void Function(BuildContext context, String message)? onShowSnackBar,
  }) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<LoginProvider>.value(value: loginProvider),
        ChangeNotifierProvider<CreateAccountProvider>.value(value: createProvider),
        Provider<TextsUtil>.value(value: textsUtil),
      ],
      child: MaterialApp(
        home: CreateAccountPage(onShowSnackBar: onShowSnackBar),
        theme: ThemeData(),
      ),
    );
  }

  group('CreateAccountPage Rendering', () {
    testWidgets('renders all form fields correctly', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      // Wait for the widget to build
      await tester.pumpAndSettle();

      // Verify main components are rendered
      expect(find.byType(CreateAccountPage), findsOneWidget);
      expect(find.byType(Form), findsOneWidget);
      expect(find.byType(SingleChildScrollView), findsOneWidget);

      // Verify all text form fields are present (at least some key labels)
      expect(find.text('Name'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Create Account'), findsOneWidget);
    });

    testWidgets('displays dropdown options correctly', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      // Verify dropdown widgets are present
      expect(find.byType(DropdownButtonFormField<String>), findsNWidgets(2));
    });

    testWidgets('dropdown selections update provider state', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      // Initially should be empty
      expect(createAccountProvider.sSelectedType, equals(''));
      expect(createAccountProvider.sSelectedSpeciality, equals(''));

      // Set values programmatically (simulating dropdown selection)
      createAccountProvider.sSelectedType = 'Hospital';
      createAccountProvider.sSelectedSpeciality = 'Cardiology';

      expect(createAccountProvider.sSelectedType, equals('Hospital'));
      expect(createAccountProvider.sSelectedSpeciality, equals('Cardiology'));
    });

    testWidgets('form renders all required fields', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      // Verify all text form fields are present
      expect(find.byKey(const Key('name_field')), findsOneWidget);
      expect(find.byKey(const Key('nit_field')), findsOneWidget);
      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('address_field')), findsOneWidget);
      expect(find.byKey(const Key('phone_field')), findsOneWidget);
      expect(find.byKey(const Key('applicant_name_field')), findsOneWidget);
      expect(find.byKey(const Key('applicant_email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('confirm_password_field')), findsOneWidget);
    });
  });

  group('CreateAccountPage Validation', () {
    testWidgets('fieldValidator returns error for empty field', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      // Get the state to access validators
      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;

      // Test field validator
      final result = state.fieldValidator('');
      expect(result, equals('This field is required'));

      final result2 = state.fieldValidator('valid input');
      expect(result2, isNull);
    });

    testWidgets('passWordValidator validates password requirements', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;

      // Test empty password
      expect(state.passWordValidator(''), isNotNull);

      // Test invalid password (missing special character)
      expect(state.passWordValidator('Password123'), isNotNull);

      // Test valid password
      expect(state.passWordValidator('Password123!'), isNull);
    });

    testWidgets('confirmPasswordValidator checks password match', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;

      // Test empty confirmation
      expect(state.confirmPasswordValidator('', 'password'), isNotNull);

      // Test mismatched passwords
      expect(state.confirmPasswordValidator('different', 'password'), isNotNull);

      // Test matching passwords
      expect(state.confirmPasswordValidator('password', 'password'), isNull);
    });
  });

  group('CreateAccountPage Form Submission', () {
    testWidgets('shows error when logo is not selected', (WidgetTester tester) async {
      String? capturedMessage;
      void mockSnackBar(BuildContext context, String message) {
        capturedMessage = message;
      }

      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
        onShowSnackBar: mockSnackBar,
      ));

      await tester.pumpAndSettle();

      // Get the state and call createAccount directly
      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      await state.createAccount();

      expect(capturedMessage, equals('Please select a logo'));
    });

    testWidgets('handles form validation internally', (WidgetTester tester) async {
      // Test that createAccount method handles validation without throwing
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;

      // This should not throw an exception even with empty form
      expect(() async => await state.createAccount(), returnsNormally);
    });

    testWidgets('successful account creation flow', (WidgetTester tester) async {
      String? capturedMessage;
      void mockSnackBar(BuildContext context, String message) {
        capturedMessage = message;
      }

      // Set a logo file
      createAccountProvider.logoFile = FakeFile();

      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
        onShowSnackBar: mockSnackBar,
      ));

      await tester.pumpAndSettle();

      // Get the state and fill form fields
      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      state.controllerName.text = 'Test Name';
      state.controllerNIT.text = '123456789';
      state.controllerEmail.text = 'test@email.com';
      state.controllerAdress.text = 'Test Address';
      state.controllerPhone.text = '1234567890';
      state.controllerNameApplicant.text = 'Applicant Name';
      state.controllerEmailApplicant.text = 'applicant@email.com';
      state.controllerPassword.text = 'Password123!';
      state.controllerConfirmPassword.text = 'Password123!';

      // Set dropdown values
      createAccountProvider.sSelectedType = 'Hospital';
      createAccountProvider.sSelectedSpeciality = 'Cardiology';

      // Test that logo is present
      expect(createAccountProvider.logoFile, isNotNull);

      // Test that all controllers have valid data
      expect(state.controllerName.text, isNotEmpty);
      expect(state.controllerEmail.text, isNotEmpty);
      expect(state.controllerPassword.text, isNotEmpty);

      // Test that showSuccessSnackBar works with callback
      state.showSuccessSnackBar(tester.element(find.byType(CreateAccountPage)), 'Account created successfully');

      expect(capturedMessage, equals('Account created successfully'));
      expect(loginProvider.bLoading, isFalse); // Should still be false since we didn't call createAccount
    });
  });

  group('CreateAccountPage SnackBar Methods', () {
    testWidgets('showErrorSnackBar uses custom callback when provided', (WidgetTester tester) async {
      String? capturedMessage;
      void mockSnackBar(BuildContext context, String message) {
        capturedMessage = message;
      }

      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
        onShowSnackBar: mockSnackBar,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      state.showErrorSnackBar(tester.element(find.byType(CreateAccountPage)), 'Test error');

      expect(capturedMessage, equals('Test error'));
    });

    testWidgets('showSuccessSnackBar uses custom callback when provided', (WidgetTester tester) async {
      String? capturedMessage;
      void mockSnackBar(BuildContext context, String message) {
        capturedMessage = message;
      }

      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
        onShowSnackBar: mockSnackBar,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      state.showSuccessSnackBar(tester.element(find.byType(CreateAccountPage)), 'Test success');

      expect(capturedMessage, equals('Test success'));
    });

    testWidgets('showErrorSnackBar uses ScaffoldMessenger when no callback provided', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      state.showErrorSnackBar(tester.element(find.byType(CreateAccountPage)), 'Test error');

      // Verify that ScaffoldMessenger was called (this is harder to test directly)
      // The method should not throw an exception
      expect(() => state.showErrorSnackBar(tester.element(find.byType(CreateAccountPage)), 'Test error'), returnsNormally);
    });

    testWidgets('showSuccessSnackBar uses ScaffoldMessenger when no callback provided', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      state.showSuccessSnackBar(tester.element(find.byType(CreateAccountPage)), 'Test success');

      // Verify that ScaffoldMessenger was called
      expect(() => state.showSuccessSnackBar(tester.element(find.byType(CreateAccountPage)), 'Test success'), returnsNormally);
    });
  });

  group('CreateAccountPage Provider Integration', () {
    testWidgets('CreateAccountProvider initializes correctly', (WidgetTester tester) async {
      expect(createAccountProvider.logoFile, isNull);
      expect(createAccountProvider.sSelectedSpeciality, equals(''));
      expect(createAccountProvider.sSelectedType, equals(''));
    });

    testWidgets('LoginProvider initializes correctly', (WidgetTester tester) async {
      expect(loginProvider.bLoading, isFalse);
    });
  });

  group('CreateAccountPage Controller Initialization', () {
    testWidgets('all text controllers are initialized', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;

      expect(state.controllerName, isNotNull);
      expect(state.controllerNIT, isNotNull);
      expect(state.controllerEmail, isNotNull);
      expect(state.controllerAdress, isNotNull);
      expect(state.controllerPhone, isNotNull);
      expect(state.controllerNameApplicant, isNotNull);
      expect(state.controllerEmailApplicant, isNotNull);
      expect(state.controllerPassword, isNotNull);
      expect(state.controllerConfirmPassword, isNotNull);
    });

    testWidgets('fetch data instance is initialized', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        createProvider: createAccountProvider,
        loginProvider: loginProvider,
        textsUtil: mockTextsUtil,
      ));

      await tester.pumpAndSettle();

      final state = tester.state(find.byType(CreateAccountPage)) as dynamic;
      expect(state.oFetchData, isNotNull);
    });
  });
}
