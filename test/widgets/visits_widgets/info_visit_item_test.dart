import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/widgets/visits_widgets/info_visit_item.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/widgets/general_widgets/poppins_text.dart';

class MockTextsUtil extends TextsUtil {
  MockTextsUtil() : super(const Locale('en', 'US'));

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

  setUp(() {
    mockTextsUtil = MockTextsUtil();
    MockTextsUtil._instance = mockTextsUtil;
  });

  Widget createTestWidget(IconData icon, String text) {
    return Provider<TextsUtil>.value(
      value: mockTextsUtil,
      child: MaterialApp(
        home: Scaffold(
          body: InfoVisitItem(icon: icon, sText: text),
        ),
      ),
    );
  }

  group('InfoVisitItem Widget', () {
    testWidgets('renders correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(Icons.location_on, 'Test Address'));

      expect(find.byType(InfoVisitItem), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
      expect(find.byType(Icon), findsOneWidget);
      expect(find.byType(PoppinsText), findsOneWidget);
    });

    testWidgets('displays correct icon', (WidgetTester tester) async {
      const testIcon = Icons.location_on;
      await tester.pumpWidget(createTestWidget(testIcon, 'Test Address'));

      final icon = tester.widget<Icon>(find.byType(Icon));
      expect(icon.icon, equals(testIcon));
      expect(icon.color, isNotNull); // Should have primaryColor
    });

    testWidgets('displays correct text', (WidgetTester tester) async {
      const testText = 'Test Address';
      await tester.pumpWidget(createTestWidget(Icons.location_on, testText));

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(createTestWidget(Icons.location_on, 'Test'));

      // Check that Row contains Icon and Expanded with PoppinsText
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(3)); // Icon, SizedBox, Expanded
      expect(row.crossAxisAlignment, equals(CrossAxisAlignment.start));
    });

    testWidgets('handles different icons correctly', (WidgetTester tester) async {
      const icons = [Icons.location_on, Icons.email, Icons.phone];

      for (final icon in icons) {
        await tester.pumpWidget(createTestWidget(icon, 'Test'));
        final iconWidget = tester.widget<Icon>(find.byType(Icon));
        expect(iconWidget.icon, equals(icon));
        await tester.pumpWidget(Container()); // Clear
      }
    });
  });
}