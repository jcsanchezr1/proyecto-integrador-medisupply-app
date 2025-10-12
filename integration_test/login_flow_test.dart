import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:medisupply_app/main.dart' as app;
import 'package:flutter/material.dart';

Future<void> waitForWidget(WidgetTester tester, Finder finder, {int maxTries = 20}) async {
  int tries = 0;
  while (finder.evaluate().isEmpty && tries < maxTries) {
    await tester.pump(const Duration(milliseconds: 100));
    tries++;
  }
  if (finder.evaluate().isEmpty) {
    throw Exception('Widget not found: $finder');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Login Flow Integration', () {
    testWidgets('Login exitoso navega a HomePage', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      const email = 'clinica.merced@medisupply.com';
      const password = 'AugustoCelis13*';

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('email_field')), email);
      await tester.enterText(find.byKey(const Key('password_field')), password);
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await waitForWidget(tester, find.byKey(const Key('home_page')));
      expect(find.byKey(const Key('home_page')), findsOneWidget);
    });

    testWidgets('Login fallido muestra SnackBar de error', (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      await waitForWidget(tester, find.byKey(const Key('email_field')));
      await waitForWidget(tester, find.byKey(const Key('password_field')));
      await waitForWidget(tester, find.byKey(const Key('login_button')));

      expect(find.byKey(const Key('email_field')), findsOneWidget);
      expect(find.byKey(const Key('password_field')), findsOneWidget);
      expect(find.byKey(const Key('login_button')), findsOneWidget);

      await tester.enterText(find.byKey(const Key('email_field')), 'test@mail.com');
      await tester.enterText(find.byKey(const Key('password_field')), 'wrongpass');
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle(const Duration(seconds: 5));

      await waitForWidget(tester, find.byType(SnackBar));
      expect(find.byType(SnackBar), findsOneWidget);
    });
  });
}
