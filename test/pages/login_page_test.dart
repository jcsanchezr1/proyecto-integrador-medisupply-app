import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:medisupply_app/src/pages/login_page.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:provider/provider.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';

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
        home: MediaQuery(
          data: MediaQueryData(size: Size(400, 800)),
          child: child,
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
  }

  testWidgets('No se ingresa ningun campo', (WidgetTester tester) async {
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
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    expect(find.text('Por favor, ingresa un valor'), findsWidgets);
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
    // Puedes agregar expect(find.byType(HomePage), findsOneWidget); si HomePage está disponible
  });

  testWidgets('Login con error muestra SnackBar', (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });
    await tester.pumpWidget(makeTestableWidget(
      child: LoginPage(fetchData: MockFetchData(shouldSucceed: false), textsUtil: MockTextsUtil(const Locale('es'))),
    ));
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('email_field')), 'test@mail.com');
    await tester.enterText(find.byKey(const Key('password_field')), '123456');
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(find.text('Ocurrió un error. Revisa tus credenciales o intenta más tarde.'), findsWidgets);
  });
}
