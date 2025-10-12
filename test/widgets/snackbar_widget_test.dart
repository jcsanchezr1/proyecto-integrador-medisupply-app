import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/widgets/general_widgets/snackbar_widget.dart';

void main() {
  group('SnackBar Widget Tests', () {
    testWidgets('snackBarWidget crea SnackBar con mensaje de error', (WidgetTester tester) async {
      const testMessage = 'Este es un mensaje de error';
      
      // Crear el SnackBar usando la función
      final snackBar = snackBarWidget(
        bError: true,
        sMessage: testMessage,
      );
      
      // Verificar que es una instancia de SnackBar
      expect(snackBar, isA<SnackBar>());
      
      // Crear un scaffold para mostrar el SnackBar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show SnackBar'),
                );
              },
            ),
          ),
        ),
      );
      
      // Pulsar el botón para mostrar el SnackBar
      await tester.tap(find.text('Show SnackBar'));
      await tester.pump();
      
      // Verificar que el SnackBar aparece con el mensaje correcto
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    testWidgets('snackBarWidget crea SnackBar con mensaje de éxito', (WidgetTester tester) async {
      const testMessage = 'Este es un mensaje de éxito';
      
      // Crear el SnackBar usando la función con bError: false
      final snackBar = snackBarWidget(
        bError: false,
        sMessage: testMessage,
      );
      
      // Verificar que es una instancia de SnackBar
      expect(snackBar, isA<SnackBar>());
      
      // Crear un scaffold para mostrar el SnackBar
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Builder(
              builder: (context) {
                return ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  },
                  child: const Text('Show Success SnackBar'),
                );
              },
            ),
          ),
        ),
      );
      
      // Pulsar el botón para mostrar el SnackBar
      await tester.tap(find.text('Show Success SnackBar'));
      await tester.pump();
      
      // Verificar que el SnackBar aparece con el mensaje correcto
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text(testMessage), findsOneWidget);
    });

    test('snackBarWidget tiene propiedades correctas por defecto', () {
      const testMessage = 'Mensaje de prueba';
      
      final snackBar = snackBarWidget(sMessage: testMessage);
      
      // Verificar que es una instancia de SnackBar
      expect(snackBar, isA<SnackBar>());
      
      // Verificar duración (5 segundos por defecto)
      expect(snackBar.duration, const Duration(seconds: 5));
    });
  });
}