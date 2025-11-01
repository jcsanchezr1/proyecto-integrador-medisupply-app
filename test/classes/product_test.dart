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

    group('fromOrderJson', () {
      test('should create Product from order JSON with all fields', () {
        // Arrange
        final json = {
          'product_name': 'Order Product',
          'product_image_url': 'https://example.com/order-image.jpg',
          'quantity': 3,
        };

        // Act
        final product = Product.fromOrderJson(json);

        // Assert
        expect(product.sName, equals('Order Product'));
        expect(product.sImage, equals('https://example.com/order-image.jpg'));
        expect(product.dQuantity, equals(3.0));
        expect(product.iId, isNull);
        expect(product.dPrice, isNull);
        expect(product.sDescription, isNull);
        expect(product.sExpirationDate, isNull);
      });

      test('should handle null values in order JSON', () {
        // Arrange
        final json = <String, dynamic>{};

        // Act
        final product = Product.fromOrderJson(json);

        // Assert
        expect(product.sName, isNull);
        expect(product.sImage, isNull);
        expect(product.dQuantity, isNull);
        expect(product.iId, isNull);
        expect(product.dPrice, isNull);
        expect(product.sDescription, isNull);
        expect(product.sExpirationDate, isNull);
      });

      test('should handle integer quantity in order JSON', () {
        // Arrange
        final json = {
          'product_name': 'Test Product',
          'product_image_url': 'https://example.com/image.jpg',
          'quantity': 5, // integer
        };

        // Act
        final product = Product.fromOrderJson(json);

        // Assert
        expect(product.dQuantity, equals(5.0));
      });

      test('should handle double quantity in order JSON', () {
        // Arrange
        final json = {
          'product_name': 'Test Product',
          'product_image_url': 'https://example.com/image.jpg',
          'quantity': 2.5,
        };

        // Act
        final product = Product.fromOrderJson(json);

        // Assert
        expect(product.dQuantity, equals(2.5));
      });

      test('should handle missing quantity in order JSON', () {
        // Arrange
        final json = {
          'product_name': 'Test Product',
          'product_image_url': 'https://example.com/image.jpg',
          // quantity is missing
        };

        // Act
        final product = Product.fromOrderJson(json);

        // Assert
        expect(product.sName, equals('Test Product'));
        expect(product.sImage, equals('https://example.com/image.jpg'));
        expect(product.dQuantity, isNull);
      });

      test('should handle empty strings in order JSON', () {
        // Arrange
        final json = {
          'product_name': '',
          'product_image_url': '',
          'quantity': 0,
        };

        // Act
        final product = Product.fromOrderJson(json);

        // Assert
        expect(product.sName, equals(''));
        expect(product.sImage, equals(''));
        expect(product.dQuantity, equals(0.0));
      });
    });
  });
}