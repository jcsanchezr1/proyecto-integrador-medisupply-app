import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/visit.dart';

void main() {
  group('Visit', () {
    test('constructor assigns values correctly', () {
      // Arrange
      const id = 'visit123';
      const date = '2025-11-12';
      const countClients = 5;

      // Act
      final visit = Visit(
        sId: id,
        sDate: date,
        iCountClients: countClients,
      );

      // Assert
      expect(visit.sId, equals(id));
      expect(visit.sDate, equals(date));
      expect(visit.iCountClients, equals(countClients));
    });

    test('fromJson parses all fields correctly', () {
      // Arrange
      final json = {
        'id': 'visit123',
        'date': '2025-11-12',
        'count_clients': 5,
      };

      // Act
      final visit = Visit.fromJson(json);

      // Assert
      expect(visit.sId, equals('visit123'));
      expect(visit.sDate, equals('2025-11-12'));
      expect(visit.iCountClients, equals(5));
    });

    test('fromJson handles zero count_clients', () {
      // Arrange
      final json = {
        'id': 'visit_empty',
        'date': '2025-11-12',
        'count_clients': 0,
      };

      // Act
      final visit = Visit.fromJson(json);

      // Assert
      expect(visit.sId, equals('visit_empty'));
      expect(visit.sDate, equals('2025-11-12'));
      expect(visit.iCountClients, equals(0));
    });

    test('fromJson handles large count_clients', () {
      // Arrange
      final json = {
        'id': 'visit_large',
        'date': '2025-11-12',
        'count_clients': 999,
      };

      // Act
      final visit = Visit.fromJson(json);

      // Assert
      expect(visit.sId, equals('visit_large'));
      expect(visit.sDate, equals('2025-11-12'));
      expect(visit.iCountClients, equals(999));
    });

    test('fromJson handles different date formats', () {
      // Arrange
      final json1 = {
        'id': 'visit1',
        'date': '2025-11-12',
        'count_clients': 1,
      };

      final json2 = {
        'id': 'visit2',
        'date': '12-11-2025',
        'count_clients': 2,
      };

      // Act
      final visit1 = Visit.fromJson(json1);
      final visit2 = Visit.fromJson(json2);

      // Assert
      expect(visit1.sDate, equals('2025-11-12'));
      expect(visit2.sDate, equals('12-11-2025'));
    });

    test('fromJson handles string count_clients', () {
      // Arrange
      final json = {
        'id': 'visit_string_count',
        'date': '2025-11-12',
        'count_clients': '3', // String instead of int
      };

      // Act & Assert
      // This should throw a TypeError because count_clients is expected to be int
      expect(() => Visit.fromJson(json), throwsA(isA<TypeError>()));
    });

    test('fromJson handles missing fields', () {
      // Arrange
      final incompleteJson = {
        'id': 'visit_partial',
        'date': '2025-11-12',
        // missing count_clients
      };

      // Act & Assert
      expect(() => Visit.fromJson(incompleteJson), throwsA(isA<TypeError>()));
    });

    test('fromJson handles null values', () {
      // Arrange
      final nullJson = {
        'id': null,
        'date': null,
        'count_clients': null,
      };

      // Act & Assert
      expect(() => Visit.fromJson(nullJson), throwsA(isA<TypeError>()));
    });

    test('fromJson handles empty json', () {
      // Arrange
      final emptyJson = <String, dynamic>{};

      // Act & Assert
      expect(() => Visit.fromJson(emptyJson), throwsA(isA<TypeError>()));
    });
  });
}