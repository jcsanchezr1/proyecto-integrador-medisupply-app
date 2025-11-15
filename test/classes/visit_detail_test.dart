import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/visit_detail.dart';
import 'package:medisupply_app/src/classes/client.dart';

void main() {
  group('VisitDetail', () {
    group('constructor', () {
      test('creates VisitDetail with all null values', () {
        final visitDetail = VisitDetail();

        expect(visitDetail.sDate, isNull);
        expect(visitDetail.sId, isNull);
        expect(visitDetail.sSellerId, isNull);
        expect(visitDetail.lClients, isNull);
      });

      test('creates VisitDetail with provided values', () {
        final clients = [Client(sClientId: '1', sName: 'Test Client')];
        final visitDetail = VisitDetail(
          sDate: '2023-11-14',
          sId: 'visit123',
          sSellerId: 'seller456',
          lClients: clients,
        );

        expect(visitDetail.sDate, equals('2023-11-14'));
        expect(visitDetail.sId, equals('visit123'));
        expect(visitDetail.sSellerId, equals('seller456'));
        expect(visitDetail.lClients, equals(clients));
      });
    });

    group('fromJson', () {
      test('parses JSON with all fields', () {
        final json = {
          'date': '2023-11-14',
          'id': 'visit123',
          'sellerId': 'seller456',
          'clients': [
            {
              'id': 'client1',
              'name': 'Client One',
              'tax_id': '123456',
              'email': 'client1@example.com',
              'address': '123 Main St',
              'phone': '555-0123',
              'institution_type': 'Hospital',
              'logo_filename': 'logo.png',
              'logo_url': 'http://example.com/logo.png',
              'specialty': 'Cardiology',
              'applicant_name': 'John Doe',
              'applicant_email': 'john@example.com',
              'enabled': true,
              'latitude': 10.0,
              'longitude': -74.0,
            }
          ]
        };

        final visitDetail = VisitDetail.fromJson(json);

        expect(visitDetail.sDate, equals('2023-11-14'));
        expect(visitDetail.sId, equals('visit123'));
        expect(visitDetail.sSellerId, equals('seller456'));
        expect(visitDetail.lClients, isNotNull);
        expect(visitDetail.lClients!.length, equals(1));
        expect(visitDetail.lClients![0].sClientId, equals('client1'));
        expect(visitDetail.lClients![0].sName, equals('Client One'));
      });

      test('parses JSON with null clients', () {
        final json = {
          'date': '2023-11-14',
          'id': 'visit123',
          'sellerId': 'seller456',
          'clients': null
        };

        final visitDetail = VisitDetail.fromJson(json);

        expect(visitDetail.sDate, equals('2023-11-14'));
        expect(visitDetail.sId, equals('visit123'));
        expect(visitDetail.sSellerId, equals('seller456'));
        expect(visitDetail.lClients, isNotNull);
        expect(visitDetail.lClients!.length, equals(0));
      });

      test('parses JSON with empty clients list', () {
        final json = {
          'date': '2023-11-14',
          'id': 'visit123',
          'sellerId': 'seller456',
          'clients': []
        };

        final visitDetail = VisitDetail.fromJson(json);

        expect(visitDetail.sDate, equals('2023-11-14'));
        expect(visitDetail.sId, equals('visit123'));
        expect(visitDetail.sSellerId, equals('seller456'));
        expect(visitDetail.lClients, isNotNull);
        expect(visitDetail.lClients!.length, equals(0));
      });

      test('parses JSON with missing optional fields', () {
        final json = {
          'date': '2023-11-14',
          'id': 'visit123',
          // sellerId is missing
          'clients': []
        };

        final visitDetail = VisitDetail.fromJson(json);

        expect(visitDetail.sDate, equals('2023-11-14'));
        expect(visitDetail.sId, equals('visit123'));
        expect(visitDetail.sSellerId, isNull);
        expect(visitDetail.lClients, isNotNull);
        expect(visitDetail.lClients!.length, equals(0));
      });

      test('handles multiple clients in JSON', () {
        final json = {
          'date': '2023-11-14',
          'id': 'visit123',
          'sellerId': 'seller456',
          'clients': [
            {
              'id': 'client1',
              'name': 'Client One',
              'latitude': 10.0,
              'longitude': -74.0,
            },
            {
              'id': 'client2',
              'name': 'Client Two',
              'latitude': 11.0,
              'longitude': -75.0,
            }
          ]
        };

        final visitDetail = VisitDetail.fromJson(json);

        expect(visitDetail.lClients, isNotNull);
        expect(visitDetail.lClients!.length, equals(2));
        expect(visitDetail.lClients![0].sClientId, equals('client1'));
        expect(visitDetail.lClients![1].sClientId, equals('client2'));
      });
    });
  });
}