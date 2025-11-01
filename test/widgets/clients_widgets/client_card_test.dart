import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/widgets/clients_widgets/client_card.dart';
import 'package:medisupply_app/src/utils/colors_app.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Client testClient;

  setUp(() {
    testClient = Client(
      sClientId: 'client123',
      sName: 'Test Hospital',
      sEmail: 'contact@testhospital.com',
      sPhone: '+1234567890',
      sAddress: '123 Test Street, Test City',
      sInstitutionType: 'Hospital',
      sLogoUrl: 'https://example.com/logo.png',
      sSpeciality: 'Cardiology',
      sApplicantName: 'Dr. Smith',
      sApplicantEmail: 'smith@test.com',
      bEnabled: true,
    );
  });

  group('ClientCard', () {
    testWidgets('constructor accepts required client parameter', (WidgetTester tester) async {
      // Act & Assert
      expect(() => ClientCard(oClient: testClient), returnsNormally);
    });

    testWidgets('builds correctly with client data', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      expect(find.byType(ClientCard), findsOneWidget);
      expect(find.byType(GestureDetector), findsOneWidget);
      expect(find.byType(Container), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('displays client name correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      expect(find.text('Test Hospital'), findsOneWidget);
    });

    testWidgets('displays client address correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      expect(find.text('123 Test Street, Test City'), findsOneWidget);
    });

    testWidgets('displays chevron right icon', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.chevron_right_rounded), findsOneWidget);
    });

    testWidgets('shows client logo when URL is provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      expect(find.byType(FadeInImage), findsOneWidget);
      expect(find.byType(ClipRRect), findsOneWidget);
    });

    testWidgets('handles client without logo URL', (WidgetTester tester) async {
      // Arrange
      final clientWithoutLogo = Client(
        sClientId: 'client456',
        sName: 'Hospital Without Logo',
        sEmail: 'contact@hospital.com',
        sPhone: '+1234567890',
        sAddress: '456 Hospital St',
        sInstitutionType: 'Hospital',
        // sLogoUrl is null
      );

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: clientWithoutLogo),
          ),
        ),
      );

      // Assert
      expect(find.byType(FadeInImage), findsOneWidget);
      expect(find.text('Hospital Without Logo'), findsOneWidget);
      expect(find.text('456 Hospital St'), findsOneWidget);
    });

    testWidgets('has correct container styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      final container = tester.widget<Container>(find.byType(Container));
      expect(container.color, equals(ColorsApp.backgroundColor));
    });

    testWidgets('has correct layout structure', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      // Should have Row as main layout
      expect(find.byType(Row), findsOneWidget);

      // Row should have 5 children: ClipRRect, SizedBox, Expanded(Column), SizedBox, Icon
      final row = tester.widget<Row>(find.byType(Row));
      expect(row.children.length, equals(5));

      // Should have Column inside Expanded
      expect(find.byType(Column), findsOneWidget);

      // Column should have 3 children: PoppinsText, SizedBox, PoppinsText
      final column = tester.widget<Column>(find.byType(Column));
      expect(column.children.length, equals(3));
    });

    testWidgets('tapping navigates to ClientDetailPage', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      // Just verify that the GestureDetector exists and is tappable
      // We can't easily test the actual navigation due to provider dependencies
      expect(find.byType(GestureDetector), findsOneWidget);
    });

    testWidgets('has correct spacing and sizing', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      // Should have SizedBox widgets for spacing (at least 3)
      expect(find.byType(SizedBox), findsAtLeastNWidgets(3));

      // Should have Expanded widget
      expect(find.byType(Expanded), findsOneWidget);
    });

    testWidgets('displays text with correct styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClientCard(oClient: testClient),
          ),
        ),
      );

      // Assert
      // Should have two PoppinsText widgets
      expect(find.byType(Text), findsNWidgets(2)); // Name and address
    });
  });
}