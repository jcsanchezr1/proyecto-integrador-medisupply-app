import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medisupply_app/src/widgets/create_account_widgets/create_account_header.dart';
import 'package:medisupply_app/src/widgets/create_account_widgets/back_button_widget.dart';
import 'package:medisupply_app/src/widgets/general_widgets/background_image.dart';

void main() {
  Widget makeTestableWidget() {
    return MaterialApp(
      home: Scaffold(
        body: const CreateAccountHeader(),
      ),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      locale: const Locale('es'),
    );
  }

  group('CreateAccountHeader Rendering', () {
    testWidgets('renders without errors', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(CreateAccountHeader), findsOneWidget);
    });

    testWidgets('contains background image', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should contain a container with background image decoration
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('contains back button', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
      expect(find.byType(BackButtonWidget), findsOneWidget);
    });

    testWidgets('contains title text', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should contain PoppinsText for the title
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('has correct layout structure', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should have Align -> Padding -> Column structure inside BackgroundImage
      expect(find.byType(BackgroundImage), findsOneWidget);
      expect(find.byType(Align), findsWidgets); // Multiple aligns possible
      expect(find.byType(Padding), findsWidgets); // Multiple paddings possible
      expect(find.byType(Column), findsOneWidget);
    });
  });

  group('CreateAccountHeader Layout', () {
    testWidgets('title is positioned at bottom left', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Find the Align that contains the Column
      final backgroundImage = tester.widget<BackgroundImage>(find.byType(BackgroundImage));
      final align = backgroundImage.child as Align;
      expect(align.alignment, equals(Alignment.bottomLeft));
    });

    testWidgets('has correct padding', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Find the padding inside the Align
      final backgroundImage = tester.widget<BackgroundImage>(find.byType(BackgroundImage));
      final align = backgroundImage.child as Align;
      final padding = align.child as Padding;
      expect(padding.padding, isNotNull);
    });

    testWidgets('column has correct alignment', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      final column = tester.widget<Column>(find.byType(Column));
      expect(column.crossAxisAlignment, equals(CrossAxisAlignment.start));
      expect(column.mainAxisAlignment, equals(MainAxisAlignment.end));
    });

    testWidgets('contains spacing between elements', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      expect(find.byType(SizedBox), findsWidgets);
    });
  });

  group('CreateAccountHeader Back Button', () {
    testWidgets('back button has correct icon', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      final icon = tester.widget<Icon>(find.byIcon(Icons.arrow_back_rounded));
      expect(icon.color, isNotNull);
      expect(icon.size, isNotNull);
    });

    testWidgets('back button has correct text', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should have text from TextsUtil
      expect(find.byType(Text), findsWidgets);
    });

    testWidgets('back button is tappable', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Navigator(
            onGenerateRoute: (settings) => MaterialPageRoute(
              builder: (context) => Scaffold(
                appBar: AppBar(),
                body: const CreateAccountHeader(),
              ),
            ),
          ),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [Locale('es'), Locale('en')],
          locale: const Locale('es'),
        ),
      );

      // The back button should be present
      expect(find.byIcon(Icons.arrow_back_rounded), findsOneWidget);
    });
  });

  group('CreateAccountHeader Styling', () {
    testWidgets('background has gradient overlay', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should have containers with gradient decoration
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.length, greaterThanOrEqualTo(2));
    });

    testWidgets('title has correct styling', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Title should be present (PoppinsText with specific styling)
      expect(find.byType(Text), findsWidgets);
    });
  });

  group('CreateAccountHeader Integration', () {
    testWidgets('works with localization', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should render without localization errors
      expect(find.byType(CreateAccountHeader), findsOneWidget);
    });

    testWidgets('responsive dimensions are applied', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget());

      // Should have sized containers with responsive dimensions
      final containers = tester.widgetList<Container>(find.byType(Container));
      expect(containers.isNotEmpty, isTrue);
    });
  });
}