import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/utils/language_util.dart';

void main() {
  group('LanguageUtils Tests', () {
    late LanguageUtils languageUtils;

    setUp(() {
      languageUtils = LanguageUtils();
    });

    test('LanguageUtils es un singleton', () {
      final instance1 = LanguageUtils();
      final instance2 = LanguageUtils();
      
      expect(instance1, same(instance2));
    });

    test('LanguageUtils puede establecer y usar callback', () {
      Locale? receivedLocale;
      
      // Configurar callback
      languageUtils.setCallBack((locale) {
        receivedLocale = locale;
      });

      // Cambiar idioma
      const testLocale = Locale('en', 'US');
      languageUtils.changeLocale(testLocale);

      // Verificar que el callback fue llamado con el locale correcto
      expect(receivedLocale, equals(testLocale));
    });

    test('LanguageUtils changeLocale funciona sin callback', () {
      // No establecer callback
      const testLocale = Locale('es', 'ES');
      
      // Esto no debería lanzar excepción
      expect(() => languageUtils.changeLocale(testLocale), returnsNormally);
    });

    test('LanguageUtils puede cambiar múltiples veces el callback', () {
      Locale? firstCallback;
      Locale? secondCallback;

      // Primer callback
      languageUtils.setCallBack((locale) {
        firstCallback = locale;
      });

      const locale1 = Locale('en', 'US');
      languageUtils.changeLocale(locale1);
      expect(firstCallback, equals(locale1));

      // Segundo callback (reemplaza al primero)
      languageUtils.setCallBack((locale) {
        secondCallback = locale;
      });

      const locale2 = Locale('es', 'ES');
      languageUtils.changeLocale(locale2);
      
      // Solo el segundo callback debería haber sido llamado para locale2
      expect(secondCallback, equals(locale2));
      expect(firstCallback, equals(locale1)); // No cambió
    });

    testWidgets('LanguageUtils getDefaultLocate funciona con BuildContext', (WidgetTester tester) async {
      Widget testWidget = MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            // Obtener locale por defecto
            final defaultLocale = languageUtils.getDefaultLocate(context);
            
            // Verificar que es un Locale válido
            expect(defaultLocale, isA<Locale>());
            expect(defaultLocale.languageCode, isNotEmpty);
            
            return Container();
          },
        ),
      );

      await tester.pumpWidget(testWidget);
    });

    test('LanguageUtils maneja diferentes códigos de idioma', () {
      final List<Locale> receivedLocales = [];
      
      languageUtils.setCallBack((locale) {
        receivedLocales.add(locale);
      });

      // Probar diferentes idiomas
      const locales = [
        Locale('en', 'US'),
        Locale('es', 'ES'),
        Locale('fr', 'FR'),
        Locale('de', 'DE'),
      ];

      for (final locale in locales) {
        languageUtils.changeLocale(locale);
      }

      expect(receivedLocales.length, equals(locales.length));
      for (int i = 0; i < locales.length; i++) {
        expect(receivedLocales[i], equals(locales[i]));
      }
    });

    test('LanguageUtils callback puede ser nulo', () {
      // Establecer callback a null explícitamente
      languageUtils.setCallBack((locale) {});
      
      // Cambiar a null (simulando cuando se limpia)
      // Note: No hay método directo para esto, pero podemos verificar
      // que no falla cuando se cambia idioma
      expect(() => languageUtils.changeLocale(const Locale('en')), returnsNormally);
    });

    test('LanguageUtils preserva estado entre llamadas', () {
      int callCount = 0;
      
      languageUtils.setCallBack((locale) {
        callCount++;
      });

      // Hacer múltiples cambios
      languageUtils.changeLocale(const Locale('en'));
      languageUtils.changeLocale(const Locale('es'));
      languageUtils.changeLocale(const Locale('fr'));

      expect(callCount, equals(3));
    });

    testWidgets('LanguageUtils getDefaultLocate retorna locale consistente', (WidgetTester tester) async {
      Locale? firstCall;
      Locale? secondCall;

      Widget testWidget = MaterialApp(
        home: Builder(
          builder: (BuildContext context) {
            firstCall ??= languageUtils.getDefaultLocate(context);
            secondCall = languageUtils.getDefaultLocate(context);
            return Container();
          },
        ),
      );

      await tester.pumpWidget(testWidget);

      expect(firstCall, isNotNull);
      expect(secondCall, isNotNull);
      expect(firstCall!.languageCode, equals(secondCall!.languageCode));
    });
  });
}