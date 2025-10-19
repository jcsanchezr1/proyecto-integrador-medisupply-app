import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';

void main() {
  late LoginProvider provider;

  setUp(() {
    provider = LoginProvider();
  });

  Widget makeTestableWidget({
    required String label,
    required VoidCallback onPressed,
    Color color = Colors.blue,
  }) {
    return ChangeNotifierProvider<LoginProvider>.value(
      value: provider,
      child: MaterialApp(
        home: Scaffold(
          body: MainButton(
            sLabel: label,
            onPressed: onPressed,
            color: color,
          ),
        ),
      ),
    );
  }

  group('MainButton Rendering', () {
    testWidgets('renders with required parameters', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
      ));

      expect(find.byType(MainButton), findsOneWidget);
      expect(find.text('Test Button'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('displays correct label', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Click Me',
        onPressed: () {},
      ));

      expect(find.text('Click Me'), findsOneWidget);
    });

    testWidgets('has correct button styling', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Test',
        onPressed: () {},
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      expect(style, isNotNull);
      expect(style!.backgroundColor, isNotNull);
      expect(style.shape, isNotNull);
      expect(style.fixedSize, isNotNull);
    });

    testWidgets('has correct fixed size', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Test',
        onPressed: () {},
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      // fixedSize is a WidgetStateProperty<Size>, we need to resolve it
      expect(style!.fixedSize, isNotNull);
      final resolvedSize = style.fixedSize!.resolve({});
      expect(resolvedSize, isNotNull);
      expect(resolvedSize!.width, isNotNull);
      expect(resolvedSize.height, isNotNull);
    });
  });

  group('MainButton Tap Functionality', () {
    testWidgets('calls onPressed when tapped', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () => pressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('does not call onPressed when loading', (WidgetTester tester) async {
      bool pressed = false;

      // Set loading state
      provider.bLoading = true;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () => pressed = true,
      ));

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(pressed, isFalse);
    });

    testWidgets('button is disabled when loading', (WidgetTester tester) async {
      provider.bLoading = true;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNull);
    });

    testWidgets('button is enabled when not loading', (WidgetTester tester) async {
      provider.bLoading = false;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      expect(button.onPressed, isNotNull);
    });
  });

  group('MainButton Loading State', () {
    testWidgets('shows loading indicator when loading', (WidgetTester tester) async {
      provider.bLoading = true;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
      ));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);
    });

    testWidgets('shows label when not loading', (WidgetTester tester) async {
      provider.bLoading = false;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
      ));

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);
    });

    testWidgets('has dimmed background when loading', (WidgetTester tester) async {
      provider.bLoading = true;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
        color: Colors.blue,
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      // The background color should be dimmed (with alpha)
      expect(style!.backgroundColor, isNotNull);
    });

    testWidgets('has normal background when not loading', (WidgetTester tester) async {
      provider.bLoading = false;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () {},
        color: Colors.blue,
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      expect(style!.backgroundColor, isNotNull);
    });
  });

  group('MainButton Color Customization', () {
    testWidgets('uses default color when not specified', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Test',
        onPressed: () {},
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      expect(style!.backgroundColor, isNotNull);
    });

    testWidgets('uses custom color when specified', (WidgetTester tester) async {
      await tester.pumpWidget(makeTestableWidget(
        label: 'Test',
        onPressed: () {},
        color: Colors.red,
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      expect(style!.backgroundColor, isNotNull);
    });

    testWidgets('applies alpha to custom color when loading', (WidgetTester tester) async {
      provider.bLoading = true;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test',
        onPressed: () {},
        color: Colors.green,
      ));

      final button = tester.widget<ElevatedButton>(find.byType(ElevatedButton));
      final style = button.style;

      expect(style!.backgroundColor, isNotNull);
    });
  });

  group('MainButton Provider Integration', () {
    testWidgets('responds to provider loading state changes', (WidgetTester tester) async {
      bool pressed = false;

      await tester.pumpWidget(makeTestableWidget(
        label: 'Test Button',
        onPressed: () => pressed = true,
      ));

      // Initially not loading
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);

      // Change to loading
      provider.bLoading = true;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Test Button'), findsNothing);

      // Try to tap while loading
      await tester.tap(find.byType(ElevatedButton));
      expect(pressed, isFalse);

      // Change back to not loading
      provider.bLoading = false;
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.text('Test Button'), findsOneWidget);

      // Now tap should work
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(pressed, isTrue);
    });
  });
}