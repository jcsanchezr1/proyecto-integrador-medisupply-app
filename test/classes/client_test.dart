import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/client.dart';

void main() {
  group('Client', () {
    test('constructor assigns values correctly', () {
      // Arrange
      const clientId = 'client123';
      const name = 'Test Client';
      const taxId = '123456789';
      const email = 'test@client.com';
      const address = '123 Test St';
      const phone = '+1234567890';
      const institutionType = 'Hospital';
      const logoName = 'logo.png';
      const logoUrl = 'https://example.com/logo.png';
      const speciality = 'Cardiology';
      const applicantName = 'John Doe';
      const applicantEmail = 'john@example.com';
      const enabled = true;

      // Act
      final client = Client(
        sClientId: clientId,
        sName: name,
        sTaxId: taxId,
        sEmail: email,
        sAddress: address,
        sPhone: phone,
        sInstitutionType: institutionType,
        sLogoName: logoName,
        sLogoUrl: logoUrl,
        sSpeciality: speciality,
        sApplicantName: applicantName,
        sApplicantEmail: applicantEmail,
        bEnabled: enabled,
      );

      // Assert
      expect(client.sClientId, equals(clientId));
      expect(client.sName, equals(name));
      expect(client.sTaxId, equals(taxId));
      expect(client.sEmail, equals(email));
      expect(client.sAddress, equals(address));
      expect(client.sPhone, equals(phone));
      expect(client.sInstitutionType, equals(institutionType));
      expect(client.sLogoName, equals(logoName));
      expect(client.sLogoUrl, equals(logoUrl));
      expect(client.sSpeciality, equals(speciality));
      expect(client.sApplicantName, equals(applicantName));
      expect(client.sApplicantEmail, equals(applicantEmail));
      expect(client.bEnabled, equals(enabled));
    });

    test('constructor with null values assigns null', () {
      // Act
      final client = Client();

      // Assert
      expect(client.sClientId, isNull);
      expect(client.sName, isNull);
      expect(client.sTaxId, isNull);
      expect(client.sEmail, isNull);
      expect(client.sAddress, isNull);
      expect(client.sPhone, isNull);
      expect(client.sInstitutionType, isNull);
      expect(client.sLogoName, isNull);
      expect(client.sLogoUrl, isNull);
      expect(client.sSpeciality, isNull);
      expect(client.sApplicantName, isNull);
      expect(client.sApplicantEmail, isNull);
      expect(client.bEnabled, isNull);
    });

    test('fromJson parses all fields correctly', () {
      // Arrange
      final json = {
        'id': 'client123',
        'name': 'Test Client',
        'tax_id': '123456789',
        'email': 'test@client.com',
        'address': '123 Test St',
        'phone': '+1234567890',
        'institution_type': 'Hospital',
        'logo_filename': 'logo.png',
        'logo_url': 'https://example.com/logo.png',
        'specialty': 'Cardiology',
        'applicant_name': 'John Doe',
        'applicant_email': 'john@example.com',
        'enabled': true,
      };

      // Act
      final client = Client.fromJson(json);

      // Assert
      expect(client.sClientId, equals('client123'));
      expect(client.sName, equals('Test Client'));
      expect(client.sTaxId, equals('123456789'));
      expect(client.sEmail, equals('test@client.com'));
      expect(client.sAddress, equals('123 Test St'));
      expect(client.sPhone, equals('+1234567890'));
      expect(client.sInstitutionType, equals('Hospital'));
      expect(client.sLogoName, equals('logo.png'));
      expect(client.sLogoUrl, equals('https://example.com/logo.png'));
      expect(client.sSpeciality, equals('Cardiology'));
      expect(client.sApplicantName, equals('John Doe'));
      expect(client.sApplicantEmail, equals('john@example.com'));
      expect(client.bEnabled, isTrue);
    });

    test('fromJson handles null values', () {
      // Arrange
      final json = <String, dynamic>{};

      // Act
      final client = Client.fromJson(json);

      // Assert
      expect(client.sClientId, isNull);
      expect(client.sName, isNull);
      expect(client.sTaxId, isNull);
      expect(client.sEmail, isNull);
      expect(client.sAddress, isNull);
      expect(client.sPhone, isNull);
      expect(client.sInstitutionType, isNull);
      expect(client.sLogoName, isNull);
      expect(client.sLogoUrl, isNull);
      expect(client.sSpeciality, isNull);
      expect(client.sApplicantName, isNull);
      expect(client.sApplicantEmail, isNull);
      expect(client.bEnabled, isNull);
    });

    test('fromJson handles partial data', () {
      // Arrange
      final json = {
        'id': 'client123',
        'name': 'Test Client',
        'email': 'test@client.com',
        'enabled': false,
      };

      // Act
      final client = Client.fromJson(json);

      // Assert
      expect(client.sClientId, equals('client123'));
      expect(client.sName, equals('Test Client'));
      expect(client.sEmail, equals('test@client.com'));
      expect(client.bEnabled, isFalse);

      // Other fields should be null
      expect(client.sTaxId, isNull);
      expect(client.sAddress, isNull);
      expect(client.sPhone, isNull);
      expect(client.sInstitutionType, isNull);
      expect(client.sLogoName, isNull);
      expect(client.sLogoUrl, isNull);
      expect(client.sSpeciality, isNull);
      expect(client.sApplicantName, isNull);
      expect(client.sApplicantEmail, isNull);
    });

    test('fromJson handles boolean conversion', () {
      // Arrange
      final json = {
        'enabled': true, // Correct bool type
      };

      // Act
      final client = Client.fromJson(json);

      // Assert
      expect(client.bEnabled, isTrue);
    });

    test('fromJson handles numeric values as strings', () {
      // Arrange
      final json = {
        'id': '123', // String representation of number
        'tax_id': '987654321',
      };

      // Act
      final client = Client.fromJson(json);

      // Assert
      expect(client.sClientId, equals('123'));
      expect(client.sTaxId, equals('987654321'));
    });
  });
}