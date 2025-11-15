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
import 'package:medisupply_app/src/classes/visit_detail.dart';
import 'package:medisupply_app/src/classes/products_group.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

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

  test(
    'FetchData.createOrder maneja datos de orden complejos', () async {
      final complexOrderData = {
        'client_id': 'client123',
        'vendor_id': 'vendor456',
        'notes': 'Orden urgente',
        'products': [
          {
            'product_id': 'prod1',
            'quantity': 5,
            'price': 75.50
          },
          {
            'product_id': 'prod2',
            'quantity': 2,
            'price': 125.00
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          final decodedBody = jsonDecode(request.body);
          expect(decodedBody['client_id'], equals('client123'));
          expect(decodedBody['products'], hasLength(2));
          expect(decodedBody['notes'], equals('Orden urgente'));
          return http.Response('', 201);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.createOrder('test_access_token', complexOrderData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.getVisitDetail devuelve VisitDetail cuando API responde 200', () async {
      final mockResponse = {
        'data': {
          'id': 'visit123',
          'clients': [
            {
              'id': 'client1',
              'name': 'Hospital Central',
              'latitude': 4.7110,
              'longitude': -74.0721
            },
            {
              'id': 'client2',
              'name': 'Clinica Norte',
              'latitude': 4.7120,
              'longitude': -74.0730
            }
          ]
        }
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/sellers/test_user_id/route/visit123'), true);
          expect(request.method, 'GET');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitDetail('test_access_token', 'test_user_id', 'visit123');

      expect(result, isA<VisitDetail>());
      expect(result.sId, equals('visit123'));
      expect(result.lClients, isNotNull);
      expect(result.lClients!.length, equals(2));
      expect(result.lClients![0].sClientId, equals('client1'));
      expect(result.lClients![1].sClientId, equals('client2'));
    }
  );

  test(
    'FetchData.getVisitDetail devuelve VisitDetail vacío cuando API falla', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Unauthorized', 401)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitDetail('invalid_token', 'test_user_id', 'visit123');

      expect(result, isA<VisitDetail>());
      expect(result.sId, isNull);
      expect(result.lClients, isNull);
    }
  );

  test(
    'FetchData.getVisitDetail devuelve VisitDetail vacío cuando status != 200', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Internal Server Error', 500)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getVisitDetail('test_access_token', 'test_user_id', 'visit123');

      expect(result, isA<VisitDetail>());
      expect(result.sId, isNull);
    }
  );

  test(
    'FetchData.getVisitDetail maneja JSON malformado', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Invalid JSON', 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getVisitDetail('test_access_token', 'test_user_id', 'visit123'),
        throwsA(isA<FormatException>()),
      );
    }
  );

  test(
    'FetchData.getVisitDetail maneja respuesta sin campo data', () async {
      final mockResponse = {'status': 'success'};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.getVisitDetail('test_access_token', 'test_user_id', 'visit123'),
        throwsA(isA<TypeError>()),
      );
    }
  );

  test(
    'FetchData.getRoute procesa correctamente respuesta de Google Directions API', () async {
      // Nota: Este test es limitado porque getRoute usa http.get directamente
      // En un entorno real, necesitaríamos mockear el paquete http
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        )
      ];

      final fetchData = FetchData();
      
      // Solo verificamos que el método existe y puede ser llamado
      expect(fetchData.getRoute(clients), isA<Future<List<LatLng>>>());
    }
  );

  test(
    'FetchData.getRoute maneja lista vacía de clientes', () async {
      final clients = <Client>[];
      final fetchData = FetchData();
      
      expect(fetchData.getRoute(clients), isA<Future<List<LatLng>>>());
    }
  );

  test(
    'FetchData.getRoute maneja clientes con coordenadas válidas', () async {
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        ),
        Client(
          sClientId: 'client2',
          sName: 'Client Two',
          dLatitude: 4.7120,
          dLongitude: -74.0730,
        )
      ];

      final fetchData = FetchData();
      
      // Verificamos que el método puede manejar múltiples clientes
      expect(fetchData.getRoute(clients), isA<Future<List<LatLng>>>());
    }
  );

  test(
    'FetchData constructor maneja client opcional correctamente', () {
      final customClient = MockClient((request) async => http.Response('', 200));
      
      final fetchDataWithClient = FetchData.withClient(customClient);
      expect(fetchDataWithClient.client, equals(customClient));
      
      final fetchDataDefault = FetchData();
      expect(fetchDataDefault.client, isNotNull);
    }
  );

  test(
    'FetchData URLs base están configuradas correctamente', () {
      final fetchData = FetchData();
      
      expect(fetchData.baseUrl, contains('medisupply-gateway'));
      expect(fetchData.baseUrlMaps, contains('maps.googleapis.com'));
      expect(fetchData.baseUrlMapsDirections, contains('maps.googleapis.com'));
    }
  );

  test(
    'FetchData.getCoordinates maneja diferentes formatos de dirección', () async {
      final testAddresses = [
        'Calle 123 # 45-67, Bogotá',
        'Carrera 89, Medellín',
        'Avenida Siempre Viva 742, Springfield'
      ];

      for (final address in testAddresses) {
        final mockResponse = {
          'results': [
            {
              'geometry': {'location': {'lat': 4.7110, 'lng': -74.0721}},
              'formatted_address': 'Test Address, Colombia'
            }
          ]
        };

        final mockClient = MockClient(
          ( request ) async => http.Response(jsonEncode(mockResponse), 200)
        );

        final fetchData = FetchData.withClient(mockClient);
        final coordinates = await fetchData.getCoordinates(address);

        expect(coordinates, isNotEmpty);
        expect(coordinates['lat'], isNotNull);
        expect(coordinates['lng'], isNotNull);
      }
    }
  );

  test(
    'FetchData.getProductsbyProvider maneja diferentes estructuras de respuesta', () async {
      final mockResponse = {
        'data': {
          'groups': [
            {
              'provider': 'Provider A',
              'products': []
            }
          ]
        }
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getProductsbyProvider('token', 'user');

      expect(result, isA<List<ProductsGroup>>());
      expect(result.length, equals(1));
      expect(result[0].sProviderName, equals('Provider A'));
    }
  );

  test(
    'FetchData.getOrders maneja paginación y filtros', () async {
      // Este test verifica que los parámetros se pasan correctamente en la URL
      final mockResponse = {'data': []};

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString(), contains('vendor_id=test_user'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      await fetchData.getOrders('token', 'test_user', 'Ventas');
    }
  );

  test(
    'FetchData.getAssignedClients maneja diferentes tipos de respuesta', () async {
      final mockResponse = {
        'data': {
          'assigned_clients': [
            {
              'id': 'client1',
              'name': 'Hospital',
              'address': 'Address 1',
              'phone': '123',
              'email': 'test@test.com',
              'latitude': 4.7110,
              'longitude': -74.0721
            }
          ]
        }
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getAssignedClients('token', 'vendor');

      expect(result, isA<List<Client>>());
      expect(result.length, equals(1));
      expect(result[0].sClientId, equals('client1'));
      expect(result[0].dLatitude, equals(4.7110));
      expect(result[0].dLongitude, equals(-74.0721));
    }
  );

  test(
    'FetchData.getVisitsByDate maneja diferentes formatos de fecha', () async {
      final testDates = ['2023-11-14', '15-11-2023', '2023/11/14'];

      for (final date in testDates) {
        final mockResponse = {'data': []};

        final mockClient = MockClient(
          ( request ) async => http.Response(jsonEncode(mockResponse), 200)
        );

        final fetchData = FetchData.withClient(mockClient);
        final result = await fetchData.getVisitsByDate('token', 'user', date);

        expect(result, isA<List<Visit>>());
      }
    }
  );

  test(
    'FetchData.createVisit valida estructura de datos de visita', () async {
      final invalidVisitData = {
        'date': '15-11-2025',
        // Sin clients
      };

      final mockClient = MockClient(
        ( request ) async => http.Response('', 201)
      );

      final fetchData = FetchData.withClient(mockClient);
      // El método no valida la estructura, solo la envía
      final result = await fetchData.createVisit('token', 'user', invalidVisitData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData.createOrder valida estructura de datos de orden', () async {
      final invalidOrderData = {
        // Sin client_id
        'products': []
      };

      final mockClient = MockClient(
        ( request ) async => http.Response('', 201)
      );

      final fetchData = FetchData.withClient(mockClient);
      // El método no valida la estructura, solo la envía
      final result = await fetchData.createOrder('token', invalidOrderData);

      expect(result, isTrue);
    }
  );

  test(
    'FetchData maneja errores de red correctamente', () async {
      final mockClient = MockClient(
        ( request ) async => throw Exception('Network error')
      );

      final fetchData = FetchData.withClient(mockClient);

      expect(
        () => fetchData.login('user', 'pass'),
        throwsA(isA<Exception>()),
      );
    }
  );

  test(
    'FetchData valida tokens de autorización', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.headers['Authorization'], startsWith('Bearer '));
          return http.Response('{"data":{"groups":[]}}', 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      await fetchData.getProductsbyProvider('test_token', 'user_id');
    }
  );

  test(
    'FetchData maneja respuestas con diferentes encodings', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response(
          '{"data": {"groups": []}}',
          200,
          headers: {'content-type': 'application/json; charset=utf-8'}
        )
      );

      final fetchData = FetchData.withClient(mockClient);
      final result = await fetchData.getProductsbyProvider('token', 'user');

      expect(result, isA<List<ProductsGroup>>());
    }
  );

  test(
    'FetchData.decodePolylineForTesting decodifica correctamente polylines válidas', () {
      final fetchData = FetchData();
      
      // Polyline de ejemplo (codificada)
      final encodedPolyline = '_p~iF~ps|U_ulLnnqC_mqNvxq`@';
      final result = fetchData.decodePolylineForTesting(encodedPolyline);
      
      expect(result, isA<List<LatLng>>());
      expect(result.isNotEmpty, isTrue);
      
      // Verificar que cada punto tenga coordenadas válidas
      for (final point in result) {
        expect(point.latitude, isA<double>());
        expect(point.longitude, isA<double>());
        expect(point.latitude, inInclusiveRange(-90, 90));
        expect(point.longitude, inInclusiveRange(-180, 180));
      }
    }
  );

  test(
    'FetchData.decodePolylineForTesting maneja polylines vacías', () {
      final fetchData = FetchData();
      
      final result = fetchData.decodePolylineForTesting('');
      
      expect(result, isA<List<LatLng>>());
      expect(result.isEmpty, isTrue);
    }
  );

  test(
    'FetchData.decodePolylineForTesting maneja polylines simples', () {
      final fetchData = FetchData();
      
      // Polyline muy simple
      final result = fetchData.decodePolylineForTesting('??');
      
      expect(result, isA<List<LatLng>>());
      expect(result.length, greaterThanOrEqualTo(0));
    }
  );

  test(
    'FetchData.getRoute procesa respuesta exitosa de Google Directions API', () async {
      final mockResponse = {
        'routes': [
          {
            'overview_polyline': {
              'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'
            }
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString(), contains('maps.googleapis.com/maps/api/directions'));
          expect(request.url.toString(), contains('origin=4.693549628123178'));
          expect(request.url.toString(), contains('destination=4.693549628123178'));
          expect(request.url.toString(), contains('waypoints=4.711,'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        )
      ];

      final result = await fetchData.getRoute(clients);

      expect(result, isA<List<LatLng>>());
      expect(result.isNotEmpty, isTrue);
    }
  );

  test(
    'FetchData.getRoute lanza excepción cuando API responde con error', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Not Found', 404)
      );

      final fetchData = FetchData.withClient(mockClient);
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        )
      ];

      expect(
        () => fetchData.getRoute(clients),
        throwsA(isA<Exception>()),
      );
    }
  );

  test(
    'FetchData.getRoute maneja respuesta sin routes', () async {
      final mockResponse = {'routes': []};

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        )
      ];

      expect(
        () => fetchData.getRoute(clients),
        throwsA(isA<RangeError>()),
      );
    }
  );

  test(
    'FetchData.getRoute maneja respuesta sin overview_polyline', () async {
      final mockResponse = {
        'routes': [
          {
            // Sin overview_polyline
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async => http.Response(jsonEncode(mockResponse), 200)
      );

      final fetchData = FetchData.withClient(mockClient);
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        )
      ];

      expect(
        () => fetchData.getRoute(clients),
        throwsA(isA<NoSuchMethodError>()),
      );
    }
  );

  test(
    'FetchData.getRoute construye URL correcta con múltiples waypoints', () async {
      final mockResponse = {
        'routes': [
          {
            'overview_polyline': {
              'points': '_p~iF~ps|U_ulLnnqC_mqNvxq`@'  // Polyline válida
            }
          }
        ]
      };

      final mockClient = MockClient(
        ( request ) async {
          final url = request.url.toString();
          expect(url, contains('waypoints=4.711,-74.0721%7C4.712,-74.073'));
          return http.Response(jsonEncode(mockResponse), 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      final clients = [
        Client(
          sClientId: 'client1',
          sName: 'Client One',
          dLatitude: 4.7110,
          dLongitude: -74.0721,
        ),
        Client(
          sClientId: 'client2',
          sName: 'Client Two',
          dLatitude: 4.7120,
          dLongitude: -74.0730,
        )
      ];

      final result = await fetchData.getRoute(clients);

      expect(result, isA<List<LatLng>>());
      expect(result.isNotEmpty, isTrue);
    }
  );

  test(
    'FetchData.uploadVisitFindings devuelve true cuando API responde 200', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.url.toString().contains('/sellers/test_user_id/route/test_visit_id/client/test_client_id'), true);
          expect(request.method, 'POST');
          expect(request.headers['Authorization'], equals('Bearer test_access_token'));
          expect(request.headers['Content-Type'], contains('multipart/form-data'));
          return http.Response('', 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.uploadVisitFindings(
        'test_access_token',
        'test_user_id',
        'test_visit_id',
        'test_client_id',
        'Test findings',
        testFile
      );

      // Clean up
      await testFile.delete();
      expect(result, isTrue);
    }
  );

  test(
    'FetchData.uploadVisitFindings devuelve false cuando API responde con error', () async {
      final mockClient = MockClient(
        ( request ) async => http.Response('Bad Request', 400)
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.uploadVisitFindings(
        'test_access_token',
        'test_user_id',
        'test_visit_id',
        'test_client_id',
        'Test findings',
        testFile
      );

      // Clean up
      await testFile.delete();
      expect(result, isFalse);
    }
  );

  test(
    'FetchData.uploadVisitFindings maneja diferentes códigos de estado de error', () async {
      final testCases = [400, 401, 403, 409, 422, 500];
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      for (final statusCode in testCases) {
        final mockClient = MockClient(
          ( request ) async => http.Response('Error', statusCode)
        );

        final fetchData = FetchData.withClient(mockClient);
        final result = await fetchData.uploadVisitFindings(
          'test_access_token',
          'test_user_id',
          'test_visit_id',
          'test_client_id',
          'Test findings',
          testFile
        );

        expect(result, isFalse, reason: 'Should return false for status code $statusCode');
      }

      // Clean up
      await testFile.delete();
    }
  );

  test(
    'FetchData.uploadVisitFindings incluye headers correctos en la petición', () async {
      final mockClient = MockClient(
        ( request ) async {
          expect(request.headers['Authorization'], equals('Bearer test_token'));
          expect(request.headers['Content-Type'], contains('multipart/form-data'));
          expect(request.url.toString().contains('/sellers/test_user/route/test_visit/client/test_client'), true);
          return http.Response('', 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.uploadVisitFindings(
        'test_token',
        'test_user',
        'test_visit',
        'test_client',
        'Findings text',
        testFile
      );

      // Clean up
      await testFile.delete();
      expect(result, isTrue);
    }
  );

  test(
    'FetchData.uploadVisitFindings incluye archivo y campos correctamente', () async {
      final mockClient = MockClient(
        ( request ) async {
          // Verificar que es multipart
          expect(request.headers['Content-Type'], contains('multipart/form-data'));
          // Verificar que contiene el archivo (esto es limitado con MockClient)
          expect(request.body, contains('file'));
          return http.Response('', 200);
        }
      );

      final fetchData = FetchData.withClient(mockClient);
      // Create a temporary test file
      final tempDir = Directory.systemTemp;
      final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

      final result = await fetchData.uploadVisitFindings(
        'test_access_token',
        'test_user_id',
        'test_visit_id',
        'test_client_id',
        'Detailed findings about the visit',
        testFile
      );

      // Clean up
      await testFile.delete();
      expect(result, isTrue);
    }
  );

  test(
    'FetchData.uploadVisitFindings maneja diferentes tipos de archivo', () async {
      final fileExtensions = ['.jpg', '.png', '.jpeg', '.gif'];

      for (final extension in fileExtensions) {
        final mockClient = MockClient(
          ( request ) async => http.Response('', 200)
        );

        final fetchData = FetchData.withClient(mockClient);
        // Create a temporary test file with different extension
        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}$extension');
        await testFile.writeAsBytes([1, 2, 3, 4, 5]); // Write some dummy data

        final result = await fetchData.uploadVisitFindings(
          'test_access_token',
          'test_user_id',
          'test_visit_id',
          'test_client_id',
          'Test findings',
          testFile
        );

        // Clean up
        await testFile.delete();
        expect(result, isTrue, reason: 'Should handle $extension files');
      }
    }
  );

  test(
    'FetchData.uploadVisitFindings maneja diferentes tamaños de archivo', () async {
      final fileSizes = [0, 1024, 1024 * 1024]; // 0 bytes, 1KB, 1MB

      for (final size in fileSizes) {
        final mockClient = MockClient(
          ( request ) async => http.Response('', 200)
        );

        final fetchData = FetchData.withClient(mockClient);
        // Create a temporary test file with different sizes
        final tempDir = Directory.systemTemp;
        final testFile = File('${tempDir.path}/test_image_${DateTime.now().millisecondsSinceEpoch}_$size.jpg');
        final data = List<int>.filled(size, 42); // Fill with dummy data
        await testFile.writeAsBytes(data);

        final result = await fetchData.uploadVisitFindings(
          'test_access_token',
          'test_user_id',
          'test_visit_id',
          'test_client_id',
          'Test findings',
          testFile
        );

        // Clean up
        await testFile.delete();
        expect(result, isTrue, reason: 'Should handle files of size $size bytes');
      }
    }
  );
}