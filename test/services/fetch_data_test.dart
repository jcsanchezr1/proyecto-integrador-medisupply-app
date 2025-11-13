import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import 'package:medisupply_app/src/classes/user.dart';
import 'package:medisupply_app/src/classes/order.dart';
import 'package:medisupply_app/src/services/fetch_data.dart';
import 'package:medisupply_app/src/classes/visit.dart';
import 'package:medisupply_app/src/classes/client.dart';

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
      final result = await fetchData.getProductsbyProvider('test_access_token', 'test_user_id');

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
      final result = await fetchData.getProductsbyProvider('test_access_token', 'test_user_id');

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
      final result = await fetchData.getProductsbyProvider('invalid_token', 'test_user_id');

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
      final result = await fetchData.getProductsbyProvider('test_access_token', 'test_user_id');

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
        () => fetchData.getProductsbyProvider('test_access_token', 'test_user_id'),
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
        () => fetchData.getProductsbyProvider('test_access_token', 'test_user_id'),
        throwsA(isA<NoSuchMethodError>()),
      );
    }
  );

  test(
    'FetchData.withClient constructor funciona correctamente', () {
      final mockClient = MockClient((request) async => http.Response('', 200));
      final fetchData = FetchData.withClient(mockClient);
      expect(fetchData, isA<FetchData>());
      expect(fetchData.client, equals(mockClient));
      expect(fetchData.baseUrl, equals('https://medisupply-gateway-gw-d7fde8rj.uc.gateway.dev'));
    }
  );

  test(
    'FetchData.getCoordinates filtra dirección de Bogota Colombia', () async {
      final mockResponse = {
        'results': [
          {
            'geometry': {
              'location': {
                'lat': 4.7110,
                'lng': -74.0721
              }
            },
            'formatted_address': 'Bogota, Bogota, Colombia'
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final coordinates = await fetchData.getCoordinates('Bogota, Colombia');

      expect(coordinates, isNotEmpty);
      expect(coordinates['lat'], 4.7110);
      expect(coordinates['lng'], -74.0721);
    }
  );

  test(
    'FetchData.getCoordinates devuelve coordenadas para direcciones válidas', () async {
      final mockResponse = {
        'results': [
          {
            'geometry': {
              'location': {
                'lat': 6.2442,
                'lng': -75.5812
              }
            },
            'formatted_address': 'Medellin, Antioquia, Colombia'
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final coordinates = await fetchData.getCoordinates('Medellin, Colombia');

      expect(coordinates, isNotEmpty);
      expect(coordinates['lat'], 6.2442);
      expect(coordinates['lng'], -75.5812);
    }
  );

  test(
    'FetchData.getOrders devuelve lista de pedidos para rol Ventas cuando API responde 200', () async {
      final mockResponse = {
        'data': [
          {
            'id': 1,
            'client_id': 'client123',
            'vendor_id': 'vendor456',
            'status': 'pending',
            'created_at': '2024-01-15T10:30:00Z',
            'products': [
              {
                'product_id': 'prod1',
                'quantity': 2,
                'price': 75.50
              }
            ]
          },
          {
            'id': 2,
            'client_id': 'client789',
            'vendor_id': 'vendor456',
            'status': 'completed',
            'created_at': '2024-01-14T15:45:00Z',
            'products': [
              {
                'product_id': 'prod2',
                'quantity': 1,
                'price': 89.99
              }
            ]
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/orders?vendor_id=test_user_id'), true);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getOrders('test_access_token', 'test_user_id', 'Ventas');

      expect(result, isA<List<Order>>());
      expect(result.length, equals(2));

      final order1 = result[0];
      expect(order1.iId, equals(1));
      expect(order1.sClientId, equals('client123'));
      expect(order1.sVendorId, equals('vendor456'));
      expect(order1.sStatus, equals('pending'));

      final order2 = result[1];
      expect(order2.iId, equals(2));
      expect(order2.sStatus, equals('completed'));
    }
  );

  test(
    'FetchData.getOrders devuelve lista de pedidos para rol Cliente cuando API responde 200', () async {
      final mockResponse = {
        'data': [
          {
            'id': 1,
            'client_id': 'client123',
            'vendor_id': 'vendor456',
            'status': 'pending',
            'created_at': '2024-01-15T10:30:00Z',
            'products': [
              {
                'product_id': 'prod1',
                'quantity': 2,
                'price': 75.50
              }
            ]
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/orders?client_id=test_user_id'), true);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getOrders('test_access_token', 'test_user_id', 'Cliente');

      expect(result, isA<List<Order>>());
      expect(result.length, equals(1));

      final order = result[0];
      expect(order.iId, equals(1));
      expect(order.sClientId, equals('client123'));
    }
  );

  test(
    'FetchData.getOrders devuelve lista vacía cuando API falla', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Unauthorized', 401)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getOrders('invalid_token', 'test_user_id', 'Ventas');

      expect(result, isA<List<Order>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getOrders devuelve lista vacía cuando status != 200', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Internal Server Error', 500)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getOrders('test_access_token', 'test_user_id', 'Cliente');

      expect(result, isA<List<Order>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getOrders maneja JSON malformado', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Invalid JSON', 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getOrders('test_access_token', 'test_user_id', 'Ventas'),
        throwsA(isA<FormatException>()),
      );
    }
  );

  test(
    'FetchData.getOrders maneja respuesta sin campo data', () async {
      final mockResponse = {'status': 'success'};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getOrders('test_access_token', 'test_user_id', 'Ventas'),
        throwsA(isA<TypeError>()),
      );
    }
  );

  test(
    'FetchData.getOrders devuelve lista vacía cuando data está vacío', () async {
      final mockResponse = {'data': []};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getOrders('test_access_token', 'test_user_id', 'Ventas');

      expect(result, isA<List<Order>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getOrders maneja diferentes roles correctamente', () async {
      final mockResponse = {'data': []};

      // Test para rol 'Ventas'
      final mockClientVentas = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/orders?vendor_id='), true);
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchDataVentas = FetchData.withClient(mockClientVentas);
      await fetchDataVentas.getOrders('token', 'user_id', 'Ventas');

      // Test para rol diferente (cliente)
      final mockClientCliente = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/orders?client_id='), true);
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchDataCliente = FetchData.withClient(mockClientCliente);
      await fetchDataCliente.getOrders('token', 'user_id', 'Cliente');
    }
  );

  test(
    'FetchData.getAssignedClients devuelve lista de clientes asignados cuando API responde 200', () async {
      final mockResponse = {
        'data': {
          'assigned_clients': [
            {
              'id': 'client1',
              'name': 'Hospital',
              'address': 'Calle 123',
              'phone': '1234567890',
              'email': 'test@test.com'
            },
            {
              'id': 'client2',
              'name': 'Clinica',
              'address': 'Carrera 89',
              'phone': '0987654321',
              'email': 'info@test.com'
            }
          ]
        }
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/auth/assigned-clients/test_vendor_id'), true);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getAssignedClients('test_access_token', 'test_vendor_id');

      expect(result, isA<List<Client>>());
      expect(result.length, equals(2));

      final client1 = result[0];
      expect(client1.sClientId, equals('client1'));
      expect(client1.sName, equals('Hospital'));
      expect(client1.sAddress, equals('Calle 123'));
      expect(client1.sPhone, equals('1234567890'));
      expect(client1.sEmail, equals('test@test.com'));

      final client2 = result[1];
      expect(client2.sClientId, equals('client2'));
      expect(client2.sName, equals('Clinica'));
    }
  );

  test(
    'FetchData.getAssignedClients devuelve lista vacía cuando assigned_clients es null', () async {
      final mockResponse = {
        'data': {
          'assigned_clients': null
        }
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getAssignedClients('test_access_token', 'test_vendor_id');

      expect(result, isA<List<Client>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getAssignedClients devuelve lista vacía cuando assigned_clients está vacío', () async {
      final mockResponse = {
        'data': {
          'assigned_clients': []
        }
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getAssignedClients('test_access_token', 'test_vendor_id');

      expect(result, isA<List<Client>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getAssignedClients devuelve lista vacía cuando API falla', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Unauthorized', 401)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getAssignedClients('invalid_token', 'test_vendor_id');

      expect(result, isA<List<Client>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getAssignedClients devuelve lista vacía cuando status != 200', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Internal Server Error', 500)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getAssignedClients('test_access_token', 'test_vendor_id');

      expect(result, isA<List<Client>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getAssignedClients maneja JSON malformado', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Invalid JSON', 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getAssignedClients('test_access_token', 'test_vendor_id'),
        throwsA(isA<FormatException>()),
      );
    }
  );

  test(
    'FetchData.getVisitsByDate devuelve lista de visitas cuando API responde 200', () async {
      final mockResponse = {
        'data': [
          {
            'id': '1',
            'date': '15-11-2025',
            'count_clients': 2
          },
          {
            'id': '2',
            'date': '15-11-2025',
            'count_clients': 1
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/sellers/test_user_id/scheduled-visits?date=15-11-2025'), true);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitsByDate('test_access_token', 'test_user_id', '15-11-2025');

      expect(result, isA<List<Visit>>());
      expect(result.length, equals(2));

      final visit1 = result[0];
      expect(visit1.sId, equals('1'));
      expect(visit1.sDate, equals('15-11-2025'));
      expect(visit1.iCountClients, equals(2));

      final visit2 = result[1];
      expect(visit2.sId, equals('2'));
      expect(visit2.iCountClients, equals(1));
    }
  );

  test(
    'FetchData.getVisitsByDate devuelve lista vacía cuando data está vacío', () async {
      final mockResponse = {'data': []};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitsByDate('test_access_token', 'test_user_id', '15-11-2025');

      expect(result, isA<List<Visit>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getVisitsByDate devuelve lista vacía cuando API falla', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Unauthorized', 401)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitsByDate('invalid_token', 'test_user_id', '15-11-2025');

      expect(result, isA<List<Visit>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getVisitsByDate devuelve lista vacía cuando status != 200', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Internal Server Error', 500)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitsByDate('test_access_token', 'test_user_id', '15-11-2025');

      expect(result, isA<List<Visit>>());
      expect(result.length, equals(0));
    }
  );

  test(
    'FetchData.getVisitsByDate maneja JSON malformado', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Invalid JSON', 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getVisitsByDate('test_access_token', 'test_user_id', '15-11-2025'),
        throwsA(isA<FormatException>()),
      );
    }
  );

  test(
    'FetchData.getVisitsByDate maneja respuesta sin campo data', () async {
      final mockResponse = {'status': 'success'};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getVisitsByDate('test_access_token', 'test_user_id', '15-11-2025'),
        throwsA(isA<TypeError>()),
      );
    }
  );

  test(
    'FetchData.createVisit devuelve true cuando API responde 201', () async {
      final visitData = {
        'date': '15-11-2025',
        'clients': [
          {'client_id': 'client1'},
          {'client_id': 'client2'}
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/sellers/test_user_id/scheduled-visits'), true);
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          expect(request.headers['Content-Type'], contains('application/json'));
          expect(request.body, equals(jsonEncode(visitData)));
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createVisit('test_access_token', 'test_user_id', visitData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.createVisit devuelve false cuando API responde con error', () async {
      final visitData = {
        'date': '15-11-2025',
        'clients': [{'client_id': 'client1'}]
      };

      final mockClient = MockClient(
        ( request ) async => http.Response('Bad Request', 400)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createVisit('test_access_token', 'test_user_id', visitData);

      expect(result, isFalse);
    }
  );

  test(
    'FetchData.createVisit maneja diferentes códigos de estado de error', () async {
      final visitData = {
        'date': '15-11-2025',
        'clients': [{'client_id': 'client1'}]
      };

      final testCases = [400, 401, 403, 409, 422, 500];

      for (final statusCode in testCases) {
        final mockClient = MockClient(
          ( request ) async => http.Response('Error', statusCode)
        );

        final fetchData = FetchData.withClient(mockClient);
        final result = await fetchData.createVisit('test_access_token', 'test_user_id', visitData);

        expect(result, isFalse, reason: 'Should return false for status code $statusCode');
      }
    }
  );

  test(
    'FetchData.createVisit incluye headers correctos en la petición', () async {
      final visitData = {
        'date': '15-11-2025',
        'clients': [{'client_id': 'client1'}]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.headers['Authorization'], equals('Bearer test_token'));
          expect(request.headers['Content-Type'], contains('application/json'));
          expect(request.url.toString().contains('/sellers/test_user/scheduled-visits'), true);
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createVisit('test_token', 'test_user', visitData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.createVisit maneja datos de visita complejos', () async {
      final complexVisitData = {
        'date': '20-11-2025',
        'clients': [
          {'client_id': 'client1'},
          {'client_id': 'client2'},
          {'client_id': 'client3'}
        ],
        'notes': 'Visita de seguimiento trimestral'
      };

      final mockClient = MockClient(
        ( request ) async {
          final decodedBody = jsonDecode(request.body);
          expect(decodedBody['date'], equals('20-11-2025'));
          expect(decodedBody['clients'], hasLength(3));
          expect(decodedBody['notes'], equals('Visita de seguimiento trimestral'));
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createVisit('test_token', 'test_user', complexVisitData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.createOrder incluye headers y body correctos', () async {
      final orderData = {
        'client_id': 'client123',
        'vendor_id': 'vendor456',
        'products': [
          {
            'product_id': 'prod1',
            'quantity': 2,
            'price': 75.50
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/orders/create'), true);
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          expect(request.headers['Content-Type'], contains('application/json'));
          expect(request.body, equals(jsonEncode(orderData)));
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createOrder('test_access_token', orderData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.createOrder devuelve false cuando API responde con error', () async {
      final orderData = {'client_id': 'client123', 'products': []};

      final mockClient = MockClient(
        ( request ) async => http.Response('Bad Request', 400)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createOrder('test_access_token', orderData);

      expect(result, isFalse);
    }
  );

  test(
    'FetchData.createOrder maneja diferentes códigos de estado de error', () async {
      final orderData = {'client_id': 'client123', 'products': []};
      final testCases = [400, 401, 403, 409, 422, 500];

      for (final statusCode in testCases) {
        final mockClient = MockClient(
          ( request ) async => http.Response('Error', statusCode)
        );

        final fetchData = FetchData.withClient(mockClient);
        final result = await fetchData.createOrder('test_access_token', orderData);

        expect(result, isFalse, reason: 'Should return false for status code $statusCode');
      }
    }
  );
}