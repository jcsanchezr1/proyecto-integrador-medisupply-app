import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/product.dart';
import 'package:medisupply_app/src/classes/products_group.dart';

void main() {
  group('ProductsGroup', () {
    test('should create ProductsGroup with all fields', () {
      // Arrange
      const providerName = 'Test Provider';
      final products = [
        Product(sName: 'Product 1', dPrice: 10.0),
        Product(sName: 'Product 2', dPrice: 20.0),
      ];

      // Act
      final productsGroup = ProductsGroup(
        sProviderName: providerName,
        lProducts: products,
      );

      // Assert
      expect(productsGroup.sProviderName, equals(providerName));
      expect(productsGroup.lProducts, equals(products));
    });

    test('should create ProductsGroup with null fields', () {
      // Act
      final productsGroup = ProductsGroup();

      // Assert
      expect(productsGroup.sProviderName, isNull);
      expect(productsGroup.lProducts, isNull);
    });

    test('should create ProductsGroup with some null fields', () {
      // Arrange
      const providerName = 'Test Provider';

      // Act
      final productsGroup = ProductsGroup(
        sProviderName: providerName,
      );

      // Assert
      expect(productsGroup.sProviderName, equals(providerName));
      expect(productsGroup.lProducts, isNull);
    });

    group('fromJson', () {
      test('should create ProductsGroup from valid JSON', () {
        // Arrange
        final json = {
          'provider': 'Test Provider',
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
        };

        // Act
        final productsGroup = ProductsGroup.fromJson(json);

        // Assert
        expect(productsGroup.sProviderName, equals('Test Provider'));
        expect(productsGroup.lProducts, isNotNull);
        expect(productsGroup.lProducts!.length, equals(2));

        final product1 = productsGroup.lProducts![0];
        expect(product1.sName, equals('Product 1'));
        expect(product1.sImage, equals('https://example.com/image1.jpg'));
        expect(product1.dQuantity, equals(10.0));
        expect(product1.dPrice, equals(15.99));

        final product2 = productsGroup.lProducts![1];
        expect(product2.sName, equals('Product 2'));
        expect(product2.sImage, equals('https://example.com/image2.jpg'));
        expect(product2.dQuantity, equals(5.0));
        expect(product2.dPrice, equals(25.50));
      });

      test('should handle empty products list in JSON', () {
        // Arrange
        final json = {
          'provider': 'Test Provider',
          'products': [],
        };

        // Act
        final productsGroup = ProductsGroup.fromJson(json);

        // Assert
        expect(productsGroup.sProviderName, equals('Test Provider'));
        expect(productsGroup.lProducts, isNotNull);
        expect(productsGroup.lProducts!.length, equals(0));
      });

      test('should handle null provider in JSON', () {
        // Arrange
        final json = {
          'products': [
            {
              'name': 'Product 1',
              'photo_url': 'https://example.com/image1.jpg',
              'quantity': 10,
              'price': 15.99,
            },
          ],
        };

        // Act
        final productsGroup = ProductsGroup.fromJson(json);

        // Assert
        expect(productsGroup.sProviderName, isNull);
        expect(productsGroup.lProducts, isNotNull);
        expect(productsGroup.lProducts!.length, equals(1));
      });

      test('should handle products with null values in JSON', () {
        // Arrange
        final json = {
          'provider': 'Test Provider',
          'products': [
            {
              'name': 'Product 1',
              // missing photo_url, quantity, price
            },
          ],
        };

        // Act
        final productsGroup = ProductsGroup.fromJson(json);

        // Assert
        expect(productsGroup.sProviderName, equals('Test Provider'));
        expect(productsGroup.lProducts, isNotNull);
        expect(productsGroup.lProducts!.length, equals(1));

        final product = productsGroup.lProducts![0];
        expect(product.sName, equals('Product 1'));
        expect(product.sImage, isNull);
        expect(product.dQuantity, isNull);
        expect(product.dPrice, isNull);
      });
    });
  });
}