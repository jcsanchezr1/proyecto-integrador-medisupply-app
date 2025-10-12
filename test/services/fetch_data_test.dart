import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';

void main() {
  test(
    'FetchData.login devuelve un usuario válido cuando el servidor responde 200', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/auth/token'), true);
          expect(request.method, 'POST');
          return http.Response(jsonEncode({'access_token': '12345'}), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);

      final user = await fetchData.login('test@correo.com', '123456');

      expect(user, isA<User>());
      expect(user.sAccessToken, equals('12345'));

    }
  );

  test(
    'FetchData.login devuelve usuario vacío cuando status != 200', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Unauthorized', 401)
      );

      final fetchData = FetchData.withClient(mockClient);
      final user = await fetchData.login('wrong@correo.com', 'badpassword');

      expect(user.sAccessToken, isNull);
      
    }
  );

  test(
    'FetchData constructor básico funciona correctamente', () {
      final fetchData = FetchData();
      expect(fetchData, isA<FetchData>());
      expect(fetchData.client, isNotNull);
      expect(fetchData.baseUrl, equals('https://medisupply-gateway-gw-d7fde8rj.uc.gateway.dev'));
    }
  );

  test(
    'FetchData.logout devuelve true cuando el servidor responde 204', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/auth/logout'), true);
          expect(request.method, 'POST');
          expect(request.body, contains('refresh_token=test_token'));
          return http.Response('', 204);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.logout('test_token');

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.logout devuelve false cuando status != 204', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/auth/logout'), true);
          expect(request.method, 'POST');
          return http.Response('Bad Request', 400);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.logout('invalid_token');

      expect(result, isFalse);
    }
  );

  test(
    'FetchData.logout maneja diferentes códigos de estado', () async {
      // Test con múltiples códigos de error
      final testCases = [401, 403, 500, 503];
      
      for (final statusCode in testCases) {
        final mockClient = MockClient(
          ( request ) async => http.Response('Error', statusCode)
        );

        final fetchData = FetchData.withClient(mockClient);
        final result = await fetchData.logout('test_token');

        expect(result, isFalse, reason: 'Should return false for status code $statusCode');
      }
    }
  );
}