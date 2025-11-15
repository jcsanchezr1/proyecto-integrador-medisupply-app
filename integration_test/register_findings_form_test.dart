import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'package:medisupply_app/src/widgets/visits_widgets/create_visit_form.dart';
import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/utils/colors_app.dart';
import 'package:medisupply_app/src/utils/responsive_app.dart';
import 'package:medisupply_app/src/classes/user.dart';

Future<void> waitForWidget(WidgetTester tester, Finder finder, {int maxTries = 50}) async {
  int tries = 0;
  while (finder.evaluate().isEmpty && tries < maxTries) {
    await tester.pump(const Duration(milliseconds: 200));
    tries++;
  }
  if (finder.evaluate().isEmpty) {
    throw Exception('Widget not found: $finder');
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Create Visit Form Widget Test', () {
    setUp(() async {
      // Limpiar SharedPreferences antes de cada test para forzar login
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    tearDown(() async {
      // Limpiar SharedPreferences después de cada test
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
    });

    testWidgets('CreateVisitForm renders correctly and handles user input', (WidgetTester tester) async {
      // Crear un cliente de prueba
      final testClient = Client(
        sClientId: 'test-client-id',
        sName: 'Test Client',
        dLatitude: 4.7110,
        dLongitude: -74.0721,
      );

      // Crear providers necesarios
      final loginProvider = LoginProvider();
      final createAccountProvider = CreateAccountProvider();
      final textsUtil = TextsUtil(const Locale('en'));

      // Inicializar TextsUtil cargando los archivos de idioma
      await textsUtil.load();

      // Configurar providers con datos de prueba
      final testUser = User(
        sId: 'test-user-id',
        sAccessToken: 'test-token',
        sEmail: 'test@example.com'
      );
      loginProvider.oUser = testUser;

      // Crear un archivo temporal para el logo
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]);
      createAccountProvider.logoFile = testFile;

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider.value(value: loginProvider),
            ChangeNotifierProvider.value(value: createAccountProvider),
            Provider.value(value: textsUtil),
            Provider.value(value: ColorsApp()),
            Provider.value(value: ResponsiveApp()),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: CreateVisitForm(
                oClient: testClient,
                sVisitId: 'test-visit-id'
              ),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 2));

      // === PASO 1: VERIFICAR QUE EL FORMULARIO SE RENDERIZA CORRECTAMENTE ===
      final findingsField = find.byKey(const Key('findings_text_field'));
      expect(findingsField, findsOneWidget, reason: 'El campo de texto de hallazgos debería estar presente');

      // Verificar que el nombre del cliente se muestra
      expect(find.text('Test Client'), findsOneWidget, reason: 'El nombre del cliente debería mostrarse');

      // === PASO 2: LLENAR EL CAMPO DE HALLAZGOS ===
      await tester.enterText(findingsField, 'Test findings for widget test');
      await tester.pumpAndSettle();

      // Verificar que el texto se escribió correctamente
      expect(find.text('Test findings for widget test'), findsOneWidget);

      // === PASO 3: VERIFICAR QUE LOS BOTONES ESTÁN PRESENTES ===
      // Buscar botones por texto aproximado
      final uploadButton = find.textContaining('Upload');
      final registerButton = find.textContaining('Register');

      expect(uploadButton, findsOneWidget, reason: 'Debe haber un botón de upload');
      expect(registerButton, findsOneWidget, reason: 'Debe haber un botón de registrar');

      // === PASO 4: PRESIONAR EL BOTÓN DE REGISTRAR ===
      await tester.tap(registerButton.first);
      await tester.pumpAndSettle();

      // === PASO 5: VERIFICAR EL RESULTADO ===
      // Esperar el procesamiento
      await tester.pump(const Duration(seconds: 3));

      // Verificar que aparece un SnackBar (éxito o error)
      final snackbar = find.byType(SnackBar);
      expect(snackbar, findsOneWidget, reason: 'Debe aparecer un SnackBar con el resultado');

      // === PASO 6: VERIFICAR QUE EL FORMULARIO SIGUE VISIBLE ===
      // El formulario debería seguir visible ya que no hay navegación
      expect(findingsField, findsOneWidget, reason: 'El formulario debería seguir visible');

      // Limpiar archivo temporal
      if (await testFile.exists()) {
        await testFile.delete();
      }
    });
  });
}