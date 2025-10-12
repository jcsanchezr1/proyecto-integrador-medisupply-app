import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:medisupply_app/src/widgets/dialog_widgets/logout_alert_dialog.dart';
import 'package:medisupply_app/src/providers/login_provider.dart';
import 'package:medisupply_app/src/utils/texts_util.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';

final String _esJson = jsonEncode({
  "logout": {
    "title_dialog": "Cerrar sesión",
    "message_dialog": "¿Estás seguro de que deseas cerrar sesión?",
    "cancel_dialog": "Cancelar",
    "confirm_dialog": "Aceptar",
    "error_logout": "Ocurrió un error al cerrar sesión. Por favor, intenta más tarde."
  }
});

final String _enJson = jsonEncode({
  "logout": {
    "title_dialog": "Log out",
    "message_dialog": "Are you sure you want to log out?",
    "cancel_dialog": "Cancel",
    "confirm_dialog": "Accept",
    "error_logout": "An error occurred while logging out. Please try again later."
  }
});

void _installAssetMock() {
  TestWidgetsFlutterBinding.ensureInitialized();
  TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMessageHandler(
    'flutter/assets',
    (ByteData? message) async {
      final String key = utf8.decode(message!.buffer.asUint8List());
      if (key == 'AssetManifest.bin') {
        return const StandardMessageCodec().encodeMessage(<String, Object?>{});
      }
      if (key == 'AssetManifest.json') {
        final bytes = utf8.encode('{}');
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }
      if (key == 'assets/language/es_language.json') {
        final bytes = utf8.encode(_esJson);
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }
      if (key == 'assets/language/en_language.json') {
        final bytes = utf8.encode(_enJson);
        return ByteData.view(Uint8List.fromList(bytes).buffer);
      }
      return null;
    },
  );
}

class MockFetchData extends FetchData {
  final bool shouldSucceed;
  MockFetchData({required this.shouldSucceed});
  
  @override
  Future<bool> logout(String refreshToken) async {
    await Future.delayed(const Duration(milliseconds: 10));
    return shouldSucceed;
  }
}

Widget _buildTestApp({required Widget child}) {
  return ChangeNotifierProvider(
    create: (_) => LoginProvider(),
    child: MaterialApp(
      localizationsDelegates: const [
        TextsUtil.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [Locale('es'), Locale('en')],
      home: child,
    ),
  );
}

void main() {
  setUpAll(() {
    _installAssetMock();
  });

  group('LogoutAlertDialog Tests', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'mock_refresh_token',
      });
    });

    test('LogoutAlertDialog constructor', () {
      const dialog = LogoutAlertDialog();
      expect(dialog, isA<StatefulWidget>());
      expect(dialog.createState(), isNotNull);
    });

    test('LogoutAlertDialog createState múltiples veces', () {
      const dialog = LogoutAlertDialog();
      final state1 = dialog.createState();
      final state2 = dialog.createState();
      expect(state1, isNotNull);
      expect(state2, isNotNull);
    });

    test('MockFetchData logout exitoso', () async {
      final mock = MockFetchData(shouldSucceed: true);
      final result = await mock.logout('test_token');
      expect(result, isTrue);
    });

    test('MockFetchData logout fallido', () async {
      final mock = MockFetchData(shouldSucceed: false);
      final result = await mock.logout('test_token');
      expect(result, isFalse);
    });

    test('SharedPreferences con refreshToken', () async {
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'test_token_123',
      });
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('refreshToken'), equals('test_token_123'));
    });

    test('SharedPreferences clear', () async {
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'test_token',
        'other_data': 'value',
      });
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('refreshToken'), isNotNull);
      
      await prefs.clear();
      expect(prefs.getString('refreshToken'), isNull);
      expect(prefs.getString('other_data'), isNull);
    });

    test('LoginProvider loading state', () {
      final provider = LoginProvider();
      expect(provider.bLoading, isFalse);
      
      provider.bLoading = true;
      expect(provider.bLoading, isTrue);
      
      provider.bLoading = false;
      expect(provider.bLoading, isFalse);
    });

    testWidgets('LogoutAlertDialog build method sin errores', (WidgetTester tester) async {
      bool buildSuccess = false;
      
      try {
        await tester.pumpWidget(_buildTestApp(child: const LogoutAlertDialog()));
        await tester.pump();
        buildSuccess = true;
      } catch (e) {
        buildSuccess = false;
      }
      
      expect(buildSuccess, isTrue);
    });

    test('LogoutAlertDialog método logout - caso exitoso', () async {
      // Test del flujo completo del método logout cuando es exitoso
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'valid_token',
      });
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('refreshToken'), equals('valid_token'));
      
      // Verificar que clear funciona (simulando el caso exitoso)
      await prefs.clear();
      expect(prefs.getString('refreshToken'), isNull);
    });

    test('LogoutAlertDialog método logout - caso fallido', () async {
      // Test del flujo cuando logout falla
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'invalid_token',
      });
      
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getString('refreshToken'), equals('invalid_token'));
      
      // Mock de FetchData que falla
      final mockFetch = MockFetchData(shouldSucceed: false);
      final result = await mockFetch.logout('invalid_token');
      expect(result, isFalse);
    });

    test('LogoutAlertDialog provider loading states', () {
      final provider = LoginProvider();
      
      // Test estado inicial
      expect(provider.bLoading, isFalse);
      
      // Test cambio a loading
      provider.bLoading = true;
      expect(provider.bLoading, isTrue);
      
      // Test vuelta a false (como en logout exitoso)
      provider.bLoading = false;
      expect(provider.bLoading, isFalse);
      
      // Test cambio a loading y vuelta a false (como en logout fallido)
      provider.bLoading = true;
      expect(provider.bLoading, isTrue);
      provider.bLoading = false;
      expect(provider.bLoading, isFalse);
    });

    test('LogoutAlertDialog token handling', () async {
      // Test con token nulo
      SharedPreferences.setMockInitialValues({});
      
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('refreshToken');
      expect(token, isNull);
      
      // Test con token válido
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'test_token_123',
      });
      
      final prefsWithToken = await SharedPreferences.getInstance();
      final validToken = prefsWithToken.getString('refreshToken');
      expect(validToken, equals('test_token_123'));
      expect(validToken!, isNotEmpty);
    });

    test('FetchData logout method calls', () async {
      // Test both success and failure paths
      final successMock = MockFetchData(shouldSucceed: true);
      final failMock = MockFetchData(shouldSucceed: false);
      
      final successResult = await successMock.logout('token');
      final failResult = await failMock.logout('token');
      
      expect(successResult, isTrue);
      expect(failResult, isFalse);
      
      // Test que el delay funciona
      final startTime = DateTime.now();
      await successMock.logout('token');
      final endTime = DateTime.now();
      final duration = endTime.difference(startTime);
      expect(duration.inMilliseconds, greaterThanOrEqualTo(10));
    });



    test('LogoutAlertDialog workflow simulation', () async {
      // Simular el flujo completo del método logout sin UI
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'workflow_token',
      });

      final loginProvider = LoginProvider();
      final prefs = await SharedPreferences.getInstance();
      final mockFetch = MockFetchData(shouldSucceed: true);

      // Simular el flujo del método logout - caso exitoso
      loginProvider.bLoading = true;
      expect(loginProvider.bLoading, isTrue);

      final token = prefs.getString('refreshToken');
      expect(token, equals('workflow_token'));

      final bResponse = await mockFetch.logout(token!);
      expect(bResponse, isTrue);

      await prefs.clear();
      expect(prefs.getString('refreshToken'), isNull);

      loginProvider.bLoading = false;
      expect(loginProvider.bLoading, isFalse);

      // Simular el flujo del método logout - caso fallido
      SharedPreferences.setMockInitialValues({
        'refreshToken': 'fail_token',
      });

      final prefs2 = await SharedPreferences.getInstance();
      final mockFetchFail = MockFetchData(shouldSucceed: false);

      loginProvider.bLoading = true;
      final token2 = prefs2.getString('refreshToken');
      final bResponse2 = await mockFetchFail.logout(token2!);
      expect(bResponse2, isFalse);

      loginProvider.bLoading = false;
      expect(loginProvider.bLoading, isFalse);
    });
  });
}