import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/order.dart';

void main() {
  group('Order Class Tests', () {
    test('Order constructor with all parameters', () {
      final order = Order(
        iId: 1,
        sOrderNumber: 'ORD-001',
        sClientId: 'client123',
        sVendorId: 'vendor456',
        sStatus: 'pending',
        sDeliveryDate: '2024-01-15',
        sAssignedTruck: 'truck001',
        sCreatedAt: '2024-01-01T10:00:00Z',
        sUpdatedAt: '2024-01-01T10:00:00Z'
      );

      expect(order.iId, equals(1));
      expect(order.sOrderNumber, equals('ORD-001'));
      expect(order.sClientId, equals('client123'));
      expect(order.sVendorId, equals('vendor456'));
      expect(order.sStatus, equals('pending'));
      expect(order.sDeliveryDate, equals('2024-01-15'));
      expect(order.sAssignedTruck, equals('truck001'));
      expect(order.sCreatedAt, equals('2024-01-01T10:00:00Z'));
      expect(order.sUpdatedAt, equals('2024-01-01T10:00:00Z'));
    });

    test('Order constructor with null parameters', () {
      final order = Order();

      expect(order.iId, isNull);
      expect(order.sOrderNumber, isNull);
      expect(order.sClientId, isNull);
      expect(order.sVendorId, isNull);
      expect(order.sStatus, isNull);
      expect(order.sDeliveryDate, isNull);
      expect(order.sAssignedTruck, isNull);
      expect(order.sCreatedAt, isNull);
      expect(order.sUpdatedAt, isNull);
    });

    test('Order constructor with some parameters', () {
      final order = Order(
        iId: 5,
        sStatus: 'completed'
      );

      expect(order.iId, equals(5));
      expect(order.sStatus, equals('completed'));
      expect(order.sOrderNumber, isNull);
      expect(order.sClientId, isNull);
      expect(order.sVendorId, isNull);
      expect(order.sDeliveryDate, isNull);
      expect(order.sAssignedTruck, isNull);
      expect(order.sCreatedAt, isNull);
      expect(order.sUpdatedAt, isNull);
    });

    test('Order.fromJson with complete JSON', () {
      final json = {
        'id': 10,
        'order_number': 'ORD-010',
        'client_id': 'client789',
        'vendor_id': 'vendor101',
        'status': 'in_progress',
        'scheduled_delivery_date': '2024-02-01',
        'assigned_truck': 'truck005',
        'created_at': '2024-01-15T08:30:00Z',
        'updated_at': '2024-01-15T09:00:00Z'
      };

      final order = Order.fromJson(json);

      expect(order.iId, equals(10));
      expect(order.sOrderNumber, equals('ORD-010'));
      expect(order.sClientId, equals('client789'));
      expect(order.sVendorId, equals('vendor101'));
      expect(order.sStatus, equals('in_progress'));
      expect(order.sDeliveryDate, equals('2024-02-01'));
      expect(order.sAssignedTruck, equals('truck005'));
      expect(order.sCreatedAt, equals('2024-01-15T08:30:00Z'));
      expect(order.sUpdatedAt, equals('2024-01-15T09:00:00Z'));
    });

    test('Order.fromJson with partial JSON', () {
      final json = {
        'id': 20,
        'status': 'cancelled'
      };

      final order = Order.fromJson(json);

      expect(order.iId, equals(20));
      expect(order.sStatus, equals('cancelled'));
      expect(order.sOrderNumber, isNull);
      expect(order.sClientId, isNull);
      expect(order.sVendorId, isNull);
      expect(order.sDeliveryDate, isNull);
      expect(order.sAssignedTruck, isNull);
      expect(order.sCreatedAt, isNull);
      expect(order.sUpdatedAt, isNull);
    });

    test('Order.fromJson with empty JSON', () {
      final json = <String, dynamic>{};

      final order = Order.fromJson(json);

      expect(order.iId, isNull);
      expect(order.sOrderNumber, isNull);
      expect(order.sClientId, isNull);
      expect(order.sVendorId, isNull);
      expect(order.sStatus, isNull);
      expect(order.sDeliveryDate, isNull);
      expect(order.sAssignedTruck, isNull);
      expect(order.sCreatedAt, isNull);
      expect(order.sUpdatedAt, isNull);
    });

    test('Order.fromJson with null values in JSON', () {
      final json = {
        'id': null,
        'order_number': null,
        'client_id': null,
        'vendor_id': null,
        'status': null,
        'scheduled_delivery_date': null,
        'assigned_truck': null,
        'created_at': null,
        'updated_at': null
      };

      final order = Order.fromJson(json);

      expect(order.iId, isNull);
      expect(order.sOrderNumber, isNull);
      expect(order.sClientId, isNull);
      expect(order.sVendorId, isNull);
      expect(order.sStatus, isNull);
      expect(order.sDeliveryDate, isNull);
      expect(order.sAssignedTruck, isNull);
      expect(order.sCreatedAt, isNull);
      expect(order.sUpdatedAt, isNull);
    });

    test('Order.fromJson with different data types', () {
      final json = {
        'id': 100,  // int
        'order_number': 'ORD-100',  // String
        'client_id': 'client100',  // String
        'vendor_id': 'vendor100',  // String
        'status': 'approved',  // String
        'scheduled_delivery_date': '2024-03-01',  // String
        'assigned_truck': 'truck100',  // String
        'created_at': '2024-02-01T12:00:00Z',  // String
        'updated_at': '2024-02-01T12:30:00Z'  // String
      };

      final order = Order.fromJson(json);

      expect(order.iId, equals(100));
      expect(order.sOrderNumber, equals('ORD-100'));
      expect(order.sClientId, equals('client100'));
      expect(order.sVendorId, equals('vendor100'));
      expect(order.sStatus, equals('approved'));
      expect(order.sDeliveryDate, equals('2024-03-01'));
      expect(order.sAssignedTruck, equals('truck100'));
      expect(order.sCreatedAt, equals('2024-02-01T12:00:00Z'));
      expect(order.sUpdatedAt, equals('2024-02-01T12:30:00Z'));
    });

    test('Order.fromJson handles missing fields gracefully', () {
      final json = {
        'id': 50,
        // Missing other fields
      };

      final order = Order.fromJson(json);

      expect(order.iId, equals(50));
      expect(order.sOrderNumber, isNull);
      expect(order.sClientId, isNull);
      expect(order.sVendorId, isNull);
      expect(order.sStatus, isNull);
      expect(order.sDeliveryDate, isNull);
      expect(order.sAssignedTruck, isNull);
      expect(order.sCreatedAt, isNull);
      expect(order.sUpdatedAt, isNull);
    });

    test('Order properties are mutable', () {
      final order = Order(iId: 1, sStatus: 'pending');

      // Verify initial values
      expect(order.iId, equals(1));
      expect(order.sStatus, equals('pending'));

      // Modify properties (since they are not final)
      order.iId = 2;
      order.sStatus = 'completed';

      expect(order.iId, equals(2));
      expect(order.sStatus, equals('completed'));
    });

    test('Order equality comparison', () {
      final order1 = Order(
        iId: 1,
        sOrderNumber: 'ORD-001',
        sStatus: 'pending'
      );

      final order2 = Order(
        iId: 1,
        sOrderNumber: 'ORD-001',
        sStatus: 'pending'
      );

      final order3 = Order(
        iId: 2,
        sOrderNumber: 'ORD-002',
        sStatus: 'completed'
      );

      // Orders with same values should be equal (reference equality)
      expect(order1 == order2, isFalse); // Different instances
      expect(order1 == order3, isFalse); // Different values

      // But we can compare individual properties
      expect(order1.iId, equals(order2.iId));
      expect(order1.sOrderNumber, equals(order2.sOrderNumber));
      expect(order1.sStatus, equals(order2.sStatus));
    });
  });
}