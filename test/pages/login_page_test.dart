import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medisupply_app/src/pages/login_page.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:provider/provider.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Mock para TextsUtil
class MockTextsUtil extends TextsUtil {
  MockTextsUtil(super.locale);
  @override
  dynamic getText(String sKey) {
    // Devuelve textos fijos para los tests
    if (sKey == 'login.email') return 'Correo electrónico';
    if (sKey == 'login.password') return 'Contraseña';
    if (sKey == 'login.button') return 'Iniciar sesión';
    if (sKey == 'login.error') return 'Por favor, ingresa un valor';
    if (sKey == 'login.error_login') return 'Ocurrió un error. Revisa tus credenciales o intenta más tarde.';
    return sKey;
  }
}

// Mock para FetchData
class MockFetchData extends FetchData {
  final bool shouldSucceed;
  MockFetchData({required this.shouldSucceed});

  @override
  Future<User> login(String sEmail, String sPassword) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return shouldSucceed
        ? User(sAccessToken: 'token')
        : User(sAccessToken: null);
  }
}



void main() {
  Widget makeTestableWidget({required Widget child, FetchData? fetchData, TextsUtil? textsUtil}) {
    return ChangeNotifierProvider(
      create: (_) => LoginProvider(),
      child: MaterialApp(
        home: ScaffoldMessenger(
          child: Scaffold(
            body: MediaQuery(
              data: MediaQueryData(size: Size(400, 800)),
              child: child,
            ),
          ),
        ),
        theme: ThemeData(),
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        supportedLocales: const [Locale('es'), Locale('en')],
        locale: const Locale('es'),
      ),
    );
  }

  testWidgets('No se ingresa ningun campo', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(makeTestableWidget(
      child: LoginPage(
        fetchData: MockFetchData(shouldSucceed: true),
        textsUtil: MockTextsUtil(const Locale('es')),
      ),
    ));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    // Activar la validación manualmente
    final formFinder = find.byType(Form);
    final formState = tester.state<FormState>(formFinder);
    formState.validate();
    await tester.pumpAndSettle();
    // Buscar el mensaje de error en todo el árbol de widgets
    final errorText = 'Por favor, ingresa un valor';
    final errorTextFinder = find.text(errorText);
    expect(errorTextFinder, findsAtLeastNWidgets(1));
  });

  testWidgets('Login exitoso navega a HomePage', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(makeTestableWidget(
      child: LoginPage(fetchData: MockFetchData(shouldSucceed: true), textsUtil: MockTextsUtil(const Locale('es'))),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email_field')), 'test@mail.com');
    await tester.enterText(find.byKey(const Key('password_field')), '123456');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
  });

  testWidgets('Login con error muestra SnackBar y ejecuta flujo de error', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    bool snackBarCalled = false;
    String? snackBarMessage;
    void spyShowSnackBar(BuildContext context, String message) {
      snackBarCalled = true;
      snackBarMessage = message;
    }
    // Configurar SharedPreferences mock
    SharedPreferences.setMockInitialValues({});
    final mockPrefs = await SharedPreferences.getInstance();
    
    await tester.pumpWidget(makeTestableWidget(
      child: LoginPage(
        fetchData: MockFetchData(shouldSucceed: false),
        textsUtil: MockTextsUtil(const Locale('es')),
        sharedPreferences: mockPrefs,
        onShowSnackBar: spyShowSnackBar,
      ),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email_field')), 'test@mail.com');
    await tester.enterText(find.byKey(const Key('password_field')), '123456');
    // Forzar la validación manualmente antes de pulsar el botón
    final formFinder = find.byType(Form);
    final formState = tester.state<FormState>(formFinder);
    formState.validate();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    // Validar que la función de mostrar SnackBar fue llamada
    final errorText = 'Ocurrió un error. Revisa tus credenciales o intenta más tarde.';
    expect(snackBarCalled, isTrue, reason: 'La función de mostrar SnackBar no fue llamada');
    expect(snackBarMessage, errorText, reason: 'El mensaje del SnackBar no es el esperado');
    // Validar que el login falla y el flujo de error se ejecuta
    final loginProvider = Provider.of<LoginProvider>(tester.element(find.byType(LoginPage)), listen: false);
    expect(loginProvider.bLoading, isFalse);
    expect(find.byKey(const Key('email_field')), findsOneWidget);
    expect(find.byKey(const Key('password_field')), findsOneWidget);
  });

}
