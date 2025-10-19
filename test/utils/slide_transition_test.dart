import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/utils/slide_transition.dart';

class DummyPage extends StatelessWidget {
  const DummyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('Dummy'));
  }
}

void main() {
  testWidgets('SlidePageRoute transitions from right by default', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(SlidePageRoute(page: DummyPage()));
          },
          child: const Text('Go'),
        ),
      ),
    ));
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.text('Dummy'), findsOneWidget);
  });

  testWidgets('SlidePageRoute transitions from left when fromRight is false', (WidgetTester tester) async {
    await tester.pumpWidget(MaterialApp(
      home: Builder(
        builder: (context) => ElevatedButton(
          onPressed: () {
            Navigator.of(context).push(SlidePageRoute(page: DummyPage(), fromRight: false));
          },
          child: const Text('Go'),
        ),
      ),
    ));
    await tester.tap(find.text('Go'));
    await tester.pumpAndSettle();
    expect(find.text('Dummy'), findsOneWidget);
  });
}
