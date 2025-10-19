import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

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
      //expect(fetchData.baseUrl, equals('http://192.168.18.23:8082'));
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

  test(
    'FetchData.getCoordinates devuelve coordenadas válidas cuando el servidor responde 200', () async {
      final mockResponse = {
        'results': [
          {
            'geometry': {
              'location': {
                'lat': -12.0464,
                'lng': -77.0428
              }
            },
            'formatted_address': 'Lima, Peru'
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('maps.googleapis.com'), true);
          expect(request.method, 'GET');
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final coordinates = await fetchData.getCoordinates('Lima, Peru');

      expect(coordinates, isA<Map<String, dynamic>>());
      expect(coordinates['lat'], equals(-12.0464));
      expect(coordinates['lng'], equals(-77.0428));
    }
  );

  test(
    'FetchData.getCoordinates devuelve error cuando el servidor responde con error', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Not Found', 404)
      );

      final fetchData = FetchData.withClient(mockClient);

      final coordinates = await fetchData.getCoordinates('Invalid Address');
      expect(coordinates, isEmpty);
    }
  );

  test(
    'FetchData.getCoordinates maneja respuesta vacía de la API', () async {
      final mockResponse = {'results': []};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      final coordinates = await fetchData.getCoordinates('Unknown Address');
      expect(coordinates, isEmpty);
    }
  );

  test(
    'FetchData.createAccount devuelve true cuando el servidor responde 201', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/auth/user'), true);
          expect(request.method, 'POST');
          expect(request.headers['Content-Type'], contains('multipart/form-data'));
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_logo.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.createAccount(
        sName: 'Test User',
        sTaxId: '123456789',
        sEmail: 'test@example.com',
        sAddress: 'Test Address',
        sPhone: '1234567890',
        sInstitutionType: 'Hospital',
        logoFile: testFile,
        sSpecialty: 'Cardiology',
        sApplicatName: 'Applicant Name',
        sApplicatEmail: 'applicant@example.com',
        dLatitude: -12.0464,
        dLongitude: -77.0428,
        sPassword: 'password123',
        sPasswordConfirmation: 'password123',
      );

      // Clean up
      await testFile.delete();
      expect(result, isTrue);
    }
  );

  test(
    'FetchData.createAccount devuelve false cuando el servidor responde con error', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Bad Request', 400)
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_logo.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.createAccount(
        sName: 'Test User',
        sTaxId: '123456789',
        sEmail: 'test@example.com',
        sAddress: 'Test Address',
        sPhone: '1234567890',
        sInstitutionType: 'Hospital',
        logoFile: testFile,
        sSpecialty: 'Cardiology',
        sApplicatName: 'Applicant Name',
        sApplicatEmail: 'applicant@example.com',
        dLatitude: -12.0464,
        dLongitude: -77.0428,
        sPassword: 'password123',
        sPasswordConfirmation: 'password123',
      );

      // Clean up
      await testFile.delete();
      expect(result, isFalse);
    }
  );

  test(
    'FetchData.createAccount maneja diferentes códigos de estado de error', () async {
      final testCases = [400, 401, 403, 409, 500];
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_logo.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      for (final statusCode in testCases) {
        final mockClient = MockClient(
          ( request ) async => http.Response('Error', statusCode)
        );

        final fetchData = FetchData.withClient(mockClient);
        final result = await fetchData.createAccount(
          sName: 'Test User',
          sTaxId: '123456789',
          sEmail: 'test@example.com',
          sAddress: 'Test Address',
          sPhone: '1234567890',
          sInstitutionType: 'Hospital',
          logoFile: testFile,
          sSpecialty: 'Cardiology',
          sApplicatName: 'Applicant Name',
          sApplicatEmail: 'applicant@example.com',
          dLatitude: -12.0464,
          dLongitude: -77.0428,
          sPassword: 'password123',
          sPasswordConfirmation: 'password123',
        );

        expect(result, isFalse, reason: 'Should return false for status code $statusCode');
      }

      // Clean up
      await testFile.delete();
    }
  );

  test(
    'FetchData.createAccount incluye archivo de logo correctamente', () async {
      final mockClient = MockClient(
        ( request ) async {
          // Verificar que la request es multipart
          expect(request.headers['Content-Type'], contains('multipart/form-data'));
          // Verificar que contiene el archivo
          expect(request.body, contains('logo'));
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_logo.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.createAccount(
        sName: 'Test User',
        sTaxId: '123456789',
        sEmail: 'test@example.com',
        sAddress: 'Test Address',
        sPhone: '1234567890',
        sInstitutionType: 'Hospital',
        logoFile: testFile,
        sSpecialty: 'Cardiology',
        sApplicatName: 'Applicant Name',
        sApplicatEmail: 'applicant@example.com',
        dLatitude: -12.0464,
        dLongitude: -77.0428,
        sPassword: 'password123',
        sPasswordConfirmation: 'password123',
      );

      // Clean up
      await testFile.delete();
      expect(result, isTrue);
    }
  );

  test(
    'FetchData.getProductsbyProvider devuelve lista de ProductsGroup cuando la API responde 200', () async {
      final mockResponse = {
        'data': {
          'groups': [
            {
              'provider': 'Provider 1',
              'products': [
                {
                  'name': 'Product 1',
                  'photo_url': 'https://example.com/image1.jpg',
                  'quantity': 10,
                  'price': 15.99,
                },
                {
                  'name': 'Product 2',
                  'photo_url': 'https://example.com/image2.jpg',
                  'quantity': 5,
                  'price': 25.50,
                },
              ],
            },
            {
              'provider': 'Provider 2',
              'products': [
                {
                  'name': 'Product 3',
                  'photo_url': 'https://example.com/image3.jpg',
                  'quantity': 20,
                  'price': 30.00,
                },
              ],
            },
          ],
        },
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/inventory/providers/products'), true);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getProductsbyProvider('test_access_token');

      expect(result, isA<List>());
      expect(result.length, equals(2));

      final group1 = result[0];
      expect(group1.sProviderName, equals('Provider 1'));
      expect(group1.lProducts, isNotNull);
      expect(group1.lProducts!.length, equals(2));

      final product1 = group1.lProducts![0];
      expect(product1.sName, equals('Product 1'));
      expect(product1.sImage, equals('https://example.com/image1.jpg'));
      expect(product1.dQuantity, equals(10.0));
      expect(product1.dPrice, equals(15.99));

      final group2 = result[1];
      expect(group2.sProviderName, equals('Provider 2'));
      expect(group2.lProducts, isNotNull);
      expect(group2.lProducts!.length, equals(1));
    }
  );

  test(
    'FetchData.getProductsbyProvider devuelve lista vacía cuando la API devuelve grupos vacíos', () async {
      final mockResponse = {
        'data': {
          'groups': [],
        },
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getProductsbyProvider('test_access_token');

      expect(result, isA<List>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getProductsbyProvider devuelve lista vacía cuando la API falla', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Unauthorized', 401)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getProductsbyProvider('invalid_token');

      expect(result, isA<List>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getProductsbyProvider devuelve lista vacía cuando status != 200', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Internal Server Error', 500)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getProductsbyProvider('test_access_token');

      expect(result, isA<List>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getProductsbyProvider maneja JSON malformado', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Invalid JSON', 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getProductsbyProvider('test_access_token'),
        throwsA(isA<FormatException>()),
      );
    }
  );

  test(
    'FetchData.getProductsbyProvider maneja respuesta sin campo data', () async {
      final mockResponse = {'status': 'success'};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getProductsbyProvider('test_access_token'),
        throwsA(isA<NoSuchMethodError>()),
      );
    }
  );

  test(
    'FetchData.getProductsbyProvider maneja respuesta sin campo groups', () async {
      final mockResponse = {
        'data': {'status': 'success'}
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getProductsbyProvider('test_access_token'),
        throwsA(isA<TypeError>()),
      );
    }
  );
}