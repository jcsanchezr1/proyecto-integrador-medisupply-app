import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/widgets/general_widgets/poppins_text.dart';

void main() {
  group('PoppinsText Rendering', () {
    testWidgets('renders with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test Text',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      expect(find.byType(PoppinsText), findsOneWidget);
      expect(find.text('Test Text'), findsOneWidget);
    });

    testWidgets('displays correct text', (WidgetTester tester) async {
      const testText = 'Hello World';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: testText,
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text(testText), findsOneWidget);
    });

    testWidgets('uses Text widget internally', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      expect(find.byType(Text), findsOneWidget);
    });
  });

  group('PoppinsText Styling', () {
    testWidgets('applies correct font size', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 24.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.fontSize, equals(24.0));
    });

    testWidgets('applies correct color', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.red,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.color, equals(Colors.red));
    });

    testWidgets('applies correct font weight', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.fontWeight, equals(FontWeight.bold));
    });

    testWidgets('applies correct font style', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.fontStyle, equals(FontStyle.italic));
    });

    testWidgets('uses Poppins font family', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      // The font family should be set by GoogleFonts.poppins
      expect(text.style!.fontFamily, isNotNull);
    });
  });

  group('PoppinsText Text Properties', () {
    testWidgets('applies max lines', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
              iMaxLines: 2,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.maxLines, equals(2));
    });

    testWidgets('applies text align', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
              textAlign: TextAlign.center,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, equals(TextAlign.center));
    });

    testWidgets('applies text overflow', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
              textOverflow: TextOverflow.ellipsis,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.overflow, equals(TextOverflow.ellipsis));
    });
  });

  group('PoppinsText Default Values', () {
    testWidgets('uses default font weight when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.fontWeight, equals(FontWeight.normal));
    });

    testWidgets('uses default font style when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.style!.fontStyle, equals(FontStyle.normal));
    });

    testWidgets('uses default text align when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.textAlign, equals(TextAlign.start));
    });

    testWidgets('uses default text overflow when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: 'Test',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      final text = tester.widget<Text>(find.byType(Text));
      expect(text.overflow, equals(TextOverflow.ellipsis));
    });
  });

  group('PoppinsText Edge Cases', () {
    testWidgets('handles empty text', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: '',
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text(''), findsOneWidget);
    });

    testWidgets('handles very long text', (WidgetTester tester) async {
      final longText = 'A' * 1000;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: longText,
              dFontSize: 16.0,
              colorText: Colors.black,
              iMaxLines: 1,
            ),
          ),
        ),
      );

      expect(find.text(longText), findsOneWidget);
    });

    testWidgets('handles special characters', (WidgetTester tester) async {
      final specialText = 'Hello 世界 🌍 @#\$%^&*()';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: PoppinsText(
              sText: specialText,
              dFontSize: 16.0,
              colorText: Colors.black,
            ),
          ),
        ),
      );

      expect(find.text(specialText), findsOneWidget);
    });
  });
}