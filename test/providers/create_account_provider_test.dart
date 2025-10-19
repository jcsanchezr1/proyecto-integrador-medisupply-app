import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/providers/create_account_provider.dart';

void main() {
  group('CreateAccountProvider', () {
    late CreateAccountProvider provider;

    setUp(() {
      provider = CreateAccountProvider();
    });

    test('Initial values are correct', () {
      expect(provider.logoFile, isNull);
      expect(provider.sSelectedSpeciality, isEmpty);
      expect(provider.sSelectedType, isEmpty);
    });

    test('logoFile setter updates value and notifies listeners', () {
      File? capturedFile;
      bool notified = false;

      provider.addListener(() {
        notified = true;
        capturedFile = provider.logoFile;
      });

      final testFile = File('test.jpg');
      provider.logoFile = testFile;

      expect(provider.logoFile, equals(testFile));
      expect(notified, isTrue);
      expect(capturedFile, equals(testFile));
    });

    test('logoFile setter accepts null value', () {
      // Set initial file
      provider.logoFile = File('test.jpg');
      expect(provider.logoFile, isNotNull);

      // Set to null
      provider.logoFile = null;
      expect(provider.logoFile, isNull);
    });

    test('sSelectedSpeciality setter updates value and notifies listeners', () {
      String? capturedValue;
      bool notified = false;

      provider.addListener(() {
        notified = true;
        capturedValue = provider.sSelectedSpeciality;
      });

      const testValue = 'Cardiology';
      provider.sSelectedSpeciality = testValue;

      expect(provider.sSelectedSpeciality, equals(testValue));
      expect(notified, isTrue);
      expect(capturedValue, equals(testValue));
    });

    test('sSelectedSpeciality setter accepts empty string', () {
      provider.sSelectedSpeciality = 'Test';
      expect(provider.sSelectedSpeciality, isNotEmpty);

      provider.sSelectedSpeciality = '';
      expect(provider.sSelectedSpeciality, isEmpty);
    });

    test('sSelectedType setter updates value and notifies listeners', () {
      String? capturedValue;
      bool notified = false;

      provider.addListener(() {
        notified = true;
        capturedValue = provider.sSelectedType;
      });

      const testValue = 'Doctor';
      provider.sSelectedType = testValue;

      expect(provider.sSelectedType, equals(testValue));
      expect(notified, isTrue);
      expect(capturedValue, equals(testValue));
    });

    test('sSelectedType setter accepts empty string', () {
      provider.sSelectedType = 'Test';
      expect(provider.sSelectedType, isNotEmpty);

      provider.sSelectedType = '';
      expect(provider.sSelectedType, isEmpty);
    });

    test('Multiple property changes trigger multiple notifications', () {
      int notificationCount = 0;

      provider.addListener(() {
        notificationCount++;
      });

      provider.logoFile = File('test.jpg');
      provider.sSelectedSpeciality = 'Neurology';
      provider.sSelectedType = 'Nurse';

      expect(notificationCount, equals(3));
      expect(provider.logoFile, isNotNull);
      expect(provider.sSelectedSpeciality, equals('Neurology'));
      expect(provider.sSelectedType, equals('Nurse'));
    });

    test('Setting same value does not trigger notification', () {
      int notificationCount = 0;

      provider.addListener(() {
        notificationCount++;
      });

      provider.sSelectedSpeciality = 'Cardiology';
      expect(notificationCount, equals(1));

      // Setting same value again - ChangeNotifier always notifies
      provider.sSelectedSpeciality = 'Cardiology';
      expect(notificationCount, equals(2)); // ChangeNotifier notifies even for same value
    });

    test('Provider can be disposed without errors', () {
      provider.logoFile = File('test.jpg');
      provider.sSelectedSpeciality = 'Test';
      provider.sSelectedType = 'Test';

      expect(() => provider.dispose(), returnsNormally);
    });
  });
}