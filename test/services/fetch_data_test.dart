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
}