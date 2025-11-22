import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';

import 'package:medisupply_app/src/classes/client.dart';
import 'package:medisupply_app/src/providers/create_visit_provider.dart';

class MockClient extends Mock implements Client {}

void main() {
  late CreateVisitProvider provider;
  late List<Client> mockClients;
  late List<MultiSelectItem<Client>> mockItems;
  late DateTime mockDate;

  setUp(() {
    provider = CreateVisitProvider();
    mockClients = [
      Client(sClientId: 'client1', sName: 'Client 1'),
      Client(sClientId: 'client2', sName: 'Client 2'),
      Client(sClientId: 'client3', sName: 'Client 3'),
    ];
    mockItems = mockClients.map((client) => MultiSelectItem<Client>(client, client.sName!)).toList();
    mockDate = DateTime(2025, 11, 12);
  });

  group('CreateVisitProvider - Initialization', () {
    test('should initialize with empty lists', () {
      expect(provider.lClients, isEmpty);
      expect(provider.lItems, isEmpty);
      expect(provider.lSelectedClients, isEmpty);
      expect(provider.selectedDate, isNull);
    });
  });

  group('CreateVisitProvider - Getters', () {
    test('lClients getter returns correct list', () {
      provider.setClients(mockClients);
      expect(provider.lClients, equals(mockClients));
    });

    test('lItems getter returns correct list', () {
      provider.setItems(mockItems);
      expect(provider.lItems, equals(mockItems));
    });

    test('lSelectedClients getter returns correct list', () {
      provider.setSelectedClients(mockClients);
      expect(provider.lSelectedClients, equals(mockClients));
    });

    test('selectedDate getter returns correct date', () {
      provider.setSelectedDate(mockDate);
      expect(provider.selectedDate, equals(mockDate));
    });
  });

  group('CreateVisitProvider - setClients', () {
    test('should set clients list correctly', () {
      provider.setClients(mockClients);
      expect(provider.lClients, equals(mockClients));
    });

    test('should notify listeners when clients are set', () {
      var notified = false;
      provider.addListener(() => notified = true);

      provider.setClients(mockClients);

      expect(notified, isTrue);
    });

    test('should handle empty clients list', () {
      provider.setClients([]);
      expect(provider.lClients, isEmpty);
    });
  });

  group('CreateVisitProvider - setItems', () {
    test('should set items list correctly', () {
      provider.setItems(mockItems);
      expect(provider.lItems, equals(mockItems));
    });

    test('should notify listeners when items are set', () {
      var notified = false;
      provider.addListener(() => notified = true);

      provider.setItems(mockItems);

      expect(notified, isTrue);
    });

    test('should handle empty items list', () {
      provider.setItems([]);
      expect(provider.lItems, isEmpty);
    });
  });

  group('CreateVisitProvider - setSelectedClients', () {
    test('should set selected clients list correctly', () {
      provider.setSelectedClients(mockClients);
      expect(provider.lSelectedClients, equals(mockClients));
    });

    test('should notify listeners when selected clients are set', () {
      var notified = false;
      provider.addListener(() => notified = true);

      provider.setSelectedClients(mockClients);

      expect(notified, isTrue);
    });

    test('should handle empty selected clients list', () {
      provider.setSelectedClients([]);
      expect(provider.lSelectedClients, isEmpty);
    });

    test('should handle partial selection of clients', () {
      final selectedClients = [mockClients[0], mockClients[2]];
      provider.setSelectedClients(selectedClients);
      expect(provider.lSelectedClients, equals(selectedClients));
    });
  });

  group('CreateVisitProvider - removeClientSelected', () {
    test('should remove client from selected list', () {
      final client1 = Client(sClientId: 'client1', sName: 'Client 1');
      final client2 = Client(sClientId: 'client2', sName: 'Client 2');
      final client3 = Client(sClientId: 'client3', sName: 'Client 3');

      provider.setSelectedClients([client1, client2, client3]);

      provider.removeClientSelected(client2);

      expect(provider.lSelectedClients, hasLength(2));
      expect(provider.lSelectedClients.contains(client2), isFalse);
      expect(provider.lSelectedClients.contains(client1), isTrue);
      expect(provider.lSelectedClients.contains(client3), isTrue);
    });

    test('should notify listeners when client is removed', () {
      provider.setSelectedClients(mockClients);
      var notified = false;
      provider.addListener(() => notified = true);

      provider.removeClientSelected(mockClients[0]);

      expect(notified, isTrue);
    });

    test('should handle removing non-existent client gracefully', () {
      provider.setSelectedClients([mockClients[0]]);
      final nonExistentClient = Client(sClientId: 'nonexistent', sName: 'Non Existent');

      expect(() => provider.removeClientSelected(nonExistentClient), returnsNormally);
      expect(provider.lSelectedClients, hasLength(1));
    });

    test('should handle removing from empty list', () {
      expect(() => provider.removeClientSelected(mockClients[0]), returnsNormally);
      expect(provider.lSelectedClients, isEmpty);
    });
  });

  group('CreateVisitProvider - setSelectedDate', () {
    test('should set selected date correctly', () {
      provider.setSelectedDate(mockDate);
      expect(provider.selectedDate, equals(mockDate));
    });

    test('should notify listeners when date is set', () {
      var notified = false;
      provider.addListener(() => notified = true);

      provider.setSelectedDate(mockDate);

      expect(notified, isTrue);
    });

    test('should handle setting date to null', () {
      provider.setSelectedDate(mockDate);
      expect(provider.selectedDate, isNotNull);

      provider.setSelectedDate(null);
      expect(provider.selectedDate, isNull);
    });

    test('should handle different date values', () {
      final dates = [
        DateTime(2025, 1, 1),
        DateTime(2025, 12, 31),
        DateTime.now(),
      ];

      for (final date in dates) {
        provider.setSelectedDate(date);
        expect(provider.selectedDate, equals(date));
      }
    });
  });

  group('CreateVisitProvider - Integration Tests', () {
    test('should handle complete visit creation workflow', () {
      // Set clients
      provider.setClients(mockClients);
      expect(provider.lClients, hasLength(3));

      // Set items for multi-select
      provider.setItems(mockItems);
      expect(provider.lItems, hasLength(3));

      // Select some clients
      final selectedClients = [mockClients[0], mockClients[2]];
      provider.setSelectedClients(selectedClients);
      expect(provider.lSelectedClients, hasLength(2));

      // Set date
      provider.setSelectedDate(mockDate);
      expect(provider.selectedDate, equals(mockDate));

      // Remove one client
      provider.removeClientSelected(mockClients[0]);
      expect(provider.lSelectedClients, hasLength(1));
      expect(provider.lSelectedClients[0], equals(mockClients[2]));
    });

    test('should reset all data when setting empty lists', () {
      // Set initial data
      provider.setClients(mockClients);
      provider.setItems(mockItems);
      provider.setSelectedClients(mockClients);
      provider.setSelectedDate(mockDate);

      // Reset all to empty
      provider.setClients([]);
      provider.setItems([]);
      provider.setSelectedClients([]);
      provider.setSelectedDate(null);

      expect(provider.lClients, isEmpty);
      expect(provider.lItems, isEmpty);
      expect(provider.lSelectedClients, isEmpty);
      expect(provider.selectedDate, isNull);
    });
  });
}