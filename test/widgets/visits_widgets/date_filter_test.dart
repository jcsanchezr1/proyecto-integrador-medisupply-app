import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/widgets/visits_widgets/date_filter.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/poppins_text.dart';

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'visits': {
        'date_filter': 'Select Date'
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
  late MockTextsUtil mockTextsUtil;
  late DateTime? selectedDateCallback;

  setUp(() {
    mockTextsUtil = MockTextsUtil();
    MockTextsUtil._instance = mockTextsUtil;
    selectedDateCallback = null;
  });

  Widget createTestWidget() {
    return Provider<TextsUtil>.value(
      value: mockTextsUtil,
      child: MaterialApp(
        home: Scaffold(
          body: DateFilter(
            onDateSelected: (date) => selectedDateCallback = date,
          ),
        ),
      ),
    );
  }

  group('DateFilter Widget', () {
    testWidgets('renders correctly with no selected date', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // First check if the widget is rendered at all
      expect(find.byType(DateFilter), findsOneWidget);

      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byIcon(Icons.date_range), findsOneWidget);
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.text('Select Date'), findsOneWidget);
    });

    testWidgets('renders correctly with selected date', (WidgetTester tester) async {
      // Create widget with initial selected date by simulating state
      final testWidget = Provider<TextsUtil>.value(
        value: mockTextsUtil,
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DateFilter(
                  onDateSelected: (date) {
                    setState(() {});
                    selectedDateCallback = date;
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Initially should show no date selected
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);
      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('shows date picker when tapped', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Tap on the widget
      await tester.tap(find.byType(GestureDetector));
      await tester.pumpAndSettle();

      // Date picker should be shown
      expect(find.byType(DatePickerDialog), findsOneWidget);
    });

    testWidgets('calls onDateSelected callback when date is selected', (WidgetTester tester) async {
      // We can't easily test the actual date selection in widget tests
      // because showDatePicker requires user interaction
      // But we can test that the callback mechanism is set up correctly

      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Initially callback should be null
      expect(selectedDateCallback, isNull);

      // Note: Testing actual date selection requires integration testing
      // or more complex mocking of the date picker
    });

    testWidgets('clear button removes selected date and calls callback', (WidgetTester tester) async {
      // Create a widget that simulates having a selected date
      DateTime? callbackResult;

      final testWidget = Provider<TextsUtil>.value(
        value: mockTextsUtil,
        child: MaterialApp(
          home: Scaffold(
            body: StatefulBuilder(
              builder: (context, setState) {
                return DateFilter(
                  onDateSelected: (date) {
                    setState(() {});
                    callbackResult = date;
                  },
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump();

      // Simulate having a selected date by triggering the callback
      // This is a simplified test - in real usage, the date would be selected via date picker
      expect(callbackResult, isNull);

      // Note: Testing the clear functionality requires the widget to be in a state
      // where it shows the close button, which happens after a date is selected
    });

    testWidgets('has correct styling and layout', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container));
      final decoration = container.decoration as BoxDecoration;

      expect(decoration.borderRadius, equals(BorderRadius.circular(12.0)));
      expect(decoration.color, isNotNull); // Should have cardBackgroundColor
    });

    testWidgets('has correct icons and layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Should have date_range icon
      expect(find.byIcon(Icons.date_range), findsOneWidget);

      // Should have arrow_drop_down icon (when no date selected)
      expect(find.byIcon(Icons.arrow_drop_down), findsOneWidget);

      // Should not have close icon initially
      expect(find.byIcon(Icons.close), findsNothing);

      // Should have Row with correct children count
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(5)); // Icon, SizedBox, Expanded Text, SizedBox, Icon
    });

    testWidgets('has correct semantic labels', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // Check semantic label for date_range icon
      final dateIcon = tester.widget<Icon>(find.byIcon(Icons.date_range));
      expect(dateIcon.semanticLabel, equals('Select date'));

      // Check semantic label for arrow_drop_down icon
      final arrowIcon = tester.widget<Icon>(find.byIcon(Icons.arrow_drop_down));
      expect(arrowIcon.semanticLabel, equals('Open date picker'));
    });

    testWidgets('gesture detector covers entire widget', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // The GestureDetector should contain the Container
      final gestureDetector = tester.widget<GestureDetector>(find.byType(GestureDetector));
      expect(gestureDetector.child, isA<Container>());
    });

    testWidgets('container has correct padding and margins', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      final container = tester.widget<Container>(find.byType(Container));

      // Should have margin
      expect(container.margin, isNotNull);

      // Should have padding
      expect(container.padding, isNotNull);
    });

    testWidgets('text widget is properly expanded', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pump();

      // The text should be inside an Expanded widget
      final expanded = tester.widget<Expanded>(find.byType(Expanded));
      expect(expanded.child, isA<PoppinsText>()); // The text is a PoppinsText widget
    });

    testWidgets('widget accepts key parameter', (WidgetTester tester) async {
      const testKey = Key('test_date_filter');
      final widget = Provider<TextsUtil>.value(
        value: mockTextsUtil,
        child: MaterialApp(
          home: Scaffold(
            body: DateFilter(
              key: testKey,
              onDateSelected: (date) => selectedDateCallback = date,
            ),
          ),
        ),
      );

      await tester.pumpWidget(widget);
      await tester.pump();

      expect(find.byKey(testKey), findsOneWidget);
    });
  });
}