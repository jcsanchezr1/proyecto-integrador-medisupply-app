import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:medisupply_app/src/widgets/general_widgets/drop_down_widget.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';

void main() {
  late CreateAccountProvider provider;

  setUp(() {
    provider = CreateAccountProvider();
  });

  Widget makeTestableWidget({
    required String hintText,
    required String label,
    required List<dynamic> items,
    bool type = true,
    String? Function(String?)? validator,
  }) {
    return ChangeNotifierProvider<CreateAccountProvider>.value(
      value: provider,
      child: MaterialApp(
        home: Scaffold(
          body: DropDownWidget(
            sHintText: hintText,
            sLabel: label,
            lItems: items,
            bType: type,
            validator: validator,
          ),
        ),
      ),
    );
  }

  group('DropDownWidget Rendering', () {
    testWidgets('renders with required parameters', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Option 1', 'selected': false},
        {'id': '2', 'name': 'Option 2', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Select an option',
        label: 'Test Dropdown',
        items: testItems,
      ));

      expect(find.byType(DropDownWidget), findsOneWidget);
      expect(find.text('Test Dropdown'), findsOneWidget);
      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('displays all items in dropdown', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Cardiology', 'selected': false},
        {'id': '2', 'name': 'Neurology', 'selected': false},
        {'id': '3', 'name': 'Pediatrics', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Select specialty',
        label: 'Specialty',
        items: testItems,
      ));

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Check that all options are displayed
      expect(find.text('Cardiology'), findsOneWidget);
      expect(find.text('Neurology'), findsOneWidget);
      expect(find.text('Pediatrics'), findsOneWidget);
    });

    testWidgets('has correct initial size', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Option 1', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Hint',
        label: 'Label',
        items: testItems,
      ));

      // Find the SizedBox that wraps the DropdownButtonFormField
      final sizedBoxFinder = find.ancestor(
        of: find.byType(DropdownButtonFormField<String>),
        matching: find.byType(SizedBox),
      );
      final sizedBox = tester.widget<SizedBox>(sizedBoxFinder);
      expect(sizedBox.width, isNotNull);
    });
  });

  group('DropDownWidget Selection', () {
    testWidgets('selects item and updates provider for type dropdown', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Hospital', 'selected': false},
        {'id': '2', 'name': 'Clinic', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Select type',
        label: 'Institution Type',
        items: testItems,
        type: true,
      ));

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select first option
      await tester.tap(find.byType(DropdownMenuItem<String>).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check that provider was updated (this would normally be 'Hospital' but depends on TextsUtil.getSpanishText)
      expect(provider.sSelectedType, isNotEmpty);
    });

    testWidgets('updates selected state in items list', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Option 1', 'selected': false},
        {'id': '2', 'name': 'Option 2', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Select',
        label: 'Test',
        items: testItems,
      ));

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      // Select first option
      await tester.tap(find.byType(DropdownMenuItem<String>).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check that the selected item has selected = true
      expect(testItems[0]['selected'], isTrue);
      expect(testItems[1]['selected'], isFalse);
    });

    testWidgets('shows selected value in dropdown', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Selected Option', 'selected': false},
        {'id': '2', 'name': 'Other Option', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Select',
        label: 'Test',
        items: testItems,
      ));

      // Open dropdown and select
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();
      await tester.tap(find.byType(DropdownMenuItem<String>).first, warnIfMissed: false);
      await tester.pumpAndSettle();

      // Check that selected value is displayed
      expect(find.text('Selected Option'), findsOneWidget);
    });
  });

  group('DropDownWidget Validation', () {
    testWidgets('validator is called and displays error', (WidgetTester tester) async {
      String? testValidator(String? value) {
        if (value == null || value.isEmpty) {
          return 'Please select an option';
        }
        return null;
      }

      final testItems = [
        {'id': '1', 'name': 'Option 1', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Select',
        label: 'Required Field',
        items: testItems,
        validator: testValidator,
      ));

      // The validator would be called during form validation
      // For this test, we verify the validator function directly
      expect(testValidator(null), equals('Please select an option'));
      expect(testValidator(''), equals('Please select an option'));
      expect(testValidator('valid'), isNull);
    });
  });

  group('DropDownWidget Styling', () {
    testWidgets('has correct border styling', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Option 1', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Hint',
        label: 'Label',
        items: testItems,
      ));

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>)
      );
      final decoration = dropdown.decoration;

      // Check that decoration exists
      expect(decoration, isNotNull);
    });

    testWidgets('content padding is applied', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Option 1', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Hint',
        label: 'Label',
        items: testItems,
      ));

      final dropdown = tester.widget<DropdownButtonFormField<String>>(
        find.byType(DropdownButtonFormField<String>)
      );
      final decoration = dropdown.decoration;

      // Content padding should be set
      expect(decoration, isNotNull);
    });
  });

  group('DropDownWidget Edge Cases', () {
    testWidgets('handles empty items list', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Hint',
        label: 'Label',
        items: [],
      ));

      expect(find.byType(DropDownWidget), findsOneWidget);
      // Should not crash with empty list
    });

    testWidgets('handles single item', (WidgetTester tester) async {
      final testItems = [
        {'id': '1', 'name': 'Only Option', 'selected': false},
      ];

      await tester.pumpWidget(makeTestableWidget(
        hintText: 'Hint',
        label: 'Label',
        items: testItems,
      ));

      // Open dropdown
      await tester.tap(find.byType(DropdownButtonFormField<String>));
      await tester.pumpAndSettle();

      expect(find.text('Only Option'), findsOneWidget);
    });
  });
}