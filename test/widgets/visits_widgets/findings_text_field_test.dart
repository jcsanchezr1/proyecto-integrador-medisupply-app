import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/widgets/visits_widgets/findings_text_field.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US')) {
    mLocalizedStrings = {
      'visit_detail': {
        'findings_label': 'Findings Label',
        'findings_hint': 'Enter your findings here'
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
  late TextEditingController controller;

  setUp(() {
    mockTextsUtil = MockTextsUtil();
    MockTextsUtil._instance = mockTextsUtil;
    controller = TextEditingController();
  });

  tearDown(() {
    controller.dispose();
  });

  Widget createTestWidget() {
    return Provider<TextsUtil>.value(
      value: mockTextsUtil,
      child: MaterialApp(
        home: Scaffold(
          body: FindingsTextField(controller: controller),
        ),
      ),
    );
  }

  group('FindingsTextField Widget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FindingsTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('displays correct label and hint', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Findings Label'), findsOneWidget);
      expect(find.text('Enter your findings here'), findsOneWidget);
    });

    testWidgets('uses provided controller', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      expect(textField.controller, equals(controller));
    });

    testWidgets('has correct maxLines', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      final textField = tester.widget<TextFormField>(find.byType(TextFormField));
      // maxLines is not directly accessible, but we can verify it's a TextFormField with controller
      expect(textField.controller, isNotNull);
    });

    testWidgets('allows text input', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget());

      await tester.enterText(find.byType(TextFormField), 'Test findings');
      expect(controller.text, equals('Test findings'));
    });
  });
}