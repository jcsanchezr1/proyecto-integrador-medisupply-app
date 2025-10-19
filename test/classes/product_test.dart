import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/product.dart';

void main() {
  group('Product', () {
    test('should create Product with all fields', () {
      // Arrange
      const name = 'Test Product';
      const image = 'https://example.com/image.jpg';
      const quantity = 10.0;
      const price = 25.99;

      // Act
      final product = Product(
        sName: name,
        sImage: image,
        dQuantity: quantity,
        dPrice: price,
      );

      // Assert
      expect(product.sName, equals(name));
      expect(product.sImage, equals(image));
      expect(product.dQuantity, equals(quantity));
      expect(product.dPrice, equals(price));
    });

    test('should create Product with null fields', () {
      // Act
      final product = Product();

      // Assert
      expect(product.sName, isNull);
      expect(product.sImage, isNull);
      expect(product.dQuantity, isNull);
      expect(product.dPrice, isNull);
    });

    test('should create Product with some null fields', () {
      // Arrange
      const name = 'Test Product';
      const price = 25.99;

      // Act
      final product = Product(
        sName: name,
        dPrice: price,
      );

      // Assert
      expect(product.sName, equals(name));
      expect(product.sImage, isNull);
      expect(product.dQuantity, isNull);
      expect(product.dPrice, equals(price));
    });

    group('fromJson', () {
      test('should create Product from valid JSON', () {
        // Arrange
        final json = {
          'name': 'Test Product',
          'photo_url': 'https://example.com/image.jpg',
          'quantity': 10,
          'price': 25.99,
        };

        // Act
        final product = Product.fromJson(json);

        // Assert
        expect(product.sName, equals('Test Product'));
        expect(product.sImage, equals('https://example.com/image.jpg'));
        expect(product.dQuantity, equals(10.0));
        expect(product.dPrice, equals(25.99));
      });

      test('should handle null values in JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final product = Product.fromJson(json);

        // Assert
        expect(product.sName, isNull);
        expect(product.sImage, isNull);
        expect(product.dQuantity, isNull);
        expect(product.dPrice, isNull);
      });

      test('should handle integer quantity and price in JSON', () {
        // Arrange
        final json = {
          'name': 'Test Product',
          'photo_url': 'https://example.com/image.jpg',
          'quantity': 5, // integer
          'price': 20, // integer
        };

        // Act
        final product = Product.fromJson(json);

        // Assert
        expect(product.dQuantity, equals(5.0));
        expect(product.dPrice, equals(20.0));
      });

      test('should handle double quantity and price in JSON', () {
        // Arrange
        final json = {
          'name': 'Test Product',
          'photo_url': 'https://example.com/image.jpg',
          'quantity': 5.5,
          'price': 20.75,
        };

        // Act
        final product = Product.fromJson(json);

        // Assert
        expect(product.dQuantity, equals(5.5));
        expect(product.dPrice, equals(20.75));
      });
    });
  });
}