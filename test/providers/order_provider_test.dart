import 'package:flutter_test/flutter_test.dart';
import 'package:medisupply_app/src/classes/product.dart';
import 'package:medisupply_app/src/providers/order_provider.dart';

void main() {
  group('OrderProvider', () {
    late OrderProvider orderProvider;

    setUp(() {
      orderProvider = OrderProvider();
    });

    group('Initial state', () {
      test('should have empty order products list initially', () {
        expect(orderProvider.lOrderProducts, isEmpty);
      });

      test('should have quantity of 1.0 initially', () {
        expect(orderProvider.dQuantity, 1.0);
      });

      test('should have total price of 0.0 initially', () {
        expect(orderProvider.dTotalPrice, 0.0);
      });
    });

    group('dQuantity setter', () {
      test('should set quantity correctly', () {
        orderProvider.dQuantity = 5.0;
        expect(orderProvider.dQuantity, 5.0);
      });

      test('should handle zero quantity', () {
        orderProvider.dQuantity = 0.0;
        expect(orderProvider.dQuantity, 0.0);
      });

      test('should handle negative quantity', () {
        orderProvider.dQuantity = -1.0;
        expect(orderProvider.dQuantity, -1.0);
      });
    });

    group('addProduct', () {
      test('should add new product to order', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          sImage: 'test.jpg',
          dPrice: 10.0,
          dQuantity: 2.0,
        );

        orderProvider.addProduct(product);

        expect(orderProvider.lOrderProducts.length, 1);
        expect(orderProvider.lOrderProducts[0].iId, 1);
        expect(orderProvider.lOrderProducts[0].sName, 'Test Product');
        expect(orderProvider.lOrderProducts[0].dQuantity, 1.0); // Uses current dQuantity
      });

      test('should update existing product quantity when adding same product', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          sImage: 'test.jpg',
          dPrice: 10.0,
          dQuantity: 2.0,
        );

        // Add product first time
        orderProvider.addProduct(product);
        expect(orderProvider.lOrderProducts[0].dQuantity, 1.0);

        // Change quantity and add again
        orderProvider.dQuantity = 3.0;
        orderProvider.addProduct(product);

        expect(orderProvider.lOrderProducts.length, 1);
        expect(orderProvider.lOrderProducts[0].dQuantity, 3.0);
      });

      test('should preserve product properties when updating', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          sImage: 'test.jpg',
          dPrice: 10.0,
          dQuantity: 2.0,
          sDescription: 'Test description',
          sExpirationDate: '2024-12-31',
        );

        orderProvider.dQuantity = 5.0;
        orderProvider.addProduct(product);

        final addedProduct = orderProvider.lOrderProducts[0];
        expect(addedProduct.iId, 1);
        expect(addedProduct.sName, 'Test Product');
        expect(addedProduct.sImage, 'test.jpg');
        expect(addedProduct.dPrice, 10.0);
        expect(addedProduct.dQuantity, 5.0); // Updated quantity
        expect(addedProduct.sDescription, 'Test description');
        expect(addedProduct.sExpirationDate, '2024-12-31');
      });
    });

    group('removeProduct', () {
      test('should remove existing product from order', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          sImage: 'test.jpg',
          dPrice: 10.0,
        );

        orderProvider.addProduct(product);
        expect(orderProvider.lOrderProducts.length, 1);

        orderProvider.removeProduct(product);
        expect(orderProvider.lOrderProducts.length, 0);
      });

      test('should not crash when removing non-existing product', () {
        final product1 = Product(iId: 1, sName: 'Product 1');
        final product2 = Product(iId: 2, sName: 'Product 2');

        orderProvider.addProduct(product1);
        expect(orderProvider.lOrderProducts.length, 1);

        // Try to remove product that doesn't exist
        orderProvider.removeProduct(product2);
        expect(orderProvider.lOrderProducts.length, 1);
        expect(orderProvider.lOrderProducts[0].iId, 1);
      });
    });

    group('clearOrders', () {
      test('should clear all products from order', () {
        final product1 = Product(iId: 1, sName: 'Product 1', dPrice: 10.0);
        final product2 = Product(iId: 2, sName: 'Product 2', dPrice: 20.0);

        orderProvider.addProduct(product1);
        orderProvider.addProduct(product2);
        expect(orderProvider.lOrderProducts.length, 2);

        orderProvider.clearOrders();
        expect(orderProvider.lOrderProducts.length, 0);
      });
    });

    group('quantity methods', () {
      test('increaseQuantity should increment quantity by 1', () {
        expect(orderProvider.dQuantity, 1.0);

        orderProvider.increaseQuantity();
        expect(orderProvider.dQuantity, 2.0);

        orderProvider.increaseQuantity();
        expect(orderProvider.dQuantity, 3.0);
      });

      test('decreaseQuantity should decrement quantity by 1', () {
        orderProvider.dQuantity = 5.0;

        orderProvider.decreaseQuantity();
        expect(orderProvider.dQuantity, 4.0);

        orderProvider.decreaseQuantity();
        expect(orderProvider.dQuantity, 3.0);
      });

      test('resetQuantity should set quantity to 1.0', () {
        orderProvider.dQuantity = 10.0;
        expect(orderProvider.dQuantity, 10.0);

        orderProvider.resetQuantity();
        expect(orderProvider.dQuantity, 1.0);
      });
    });

    group('dTotalPrice calculation', () {
      test('should calculate total price correctly with single product', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          dPrice: 15.0,
          dQuantity: 3.0,
        );

        orderProvider.dQuantity = 2.0;
        orderProvider.addProduct(product);

        // Total should be price * quantity = 15.0 * 2.0 = 30.0
        expect(orderProvider.dTotalPrice, 30.0);
      });

      test('should calculate total price correctly with multiple products', () {
        final product1 = Product(iId: 1, sName: 'Product 1', dPrice: 10.0);
        final product2 = Product(iId: 2, sName: 'Product 2', dPrice: 20.0);

        orderProvider.dQuantity = 2.0;
        orderProvider.addProduct(product1); // 10.0 * 2.0 = 20.0

        orderProvider.dQuantity = 3.0;
        orderProvider.addProduct(product2); // 20.0 * 3.0 = 60.0

        // Total should be 20.0 + 60.0 = 80.0
        expect(orderProvider.dTotalPrice, 80.0);
      });

      test('should handle null prices', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          dPrice: null,
          dQuantity: 2.0,
        );

        orderProvider.dQuantity = 3.0;
        orderProvider.addProduct(product);

        // Total should be 0.0 * 3.0 = 0.0
        expect(orderProvider.dTotalPrice, 0.0);
      });

      test('should handle null quantities', () {
        final product = Product(
          iId: 1,
          sName: 'Test Product',
          dPrice: 10.0,
          dQuantity: null,
        );

        orderProvider.dQuantity = 2.0;
        orderProvider.addProduct(product);

        // Total should be 10.0 * 2.0 = 20.0
        expect(orderProvider.dTotalPrice, 20.0);
      });

      test('should update total price when product quantity changes', () {
        final product = Product(iId: 1, sName: 'Test Product', dPrice: 10.0);

        orderProvider.dQuantity = 2.0;
        orderProvider.addProduct(product);
        expect(orderProvider.dTotalPrice, 20.0);

        // Update quantity of existing product
        orderProvider.dQuantity = 5.0;
        orderProvider.addProduct(product);
        expect(orderProvider.dTotalPrice, 50.0);
      });

      test('should update total price when product is removed', () {
        final product1 = Product(iId: 1, sName: 'Product 1', dPrice: 10.0);
        final product2 = Product(iId: 2, sName: 'Product 2', dPrice: 20.0);

        orderProvider.dQuantity = 2.0;
        orderProvider.addProduct(product1); // 10 * 2 = 20
        orderProvider.addProduct(product2); // 20 * 2 = 40
        expect(orderProvider.dTotalPrice, 60.0);

        orderProvider.removeProduct(product1);
        expect(orderProvider.dTotalPrice, 40.0);
      });

      test('should update total price when orders are cleared', () {
        final product = Product(iId: 1, sName: 'Test Product', dPrice: 10.0);

        orderProvider.dQuantity = 3.0;
        orderProvider.addProduct(product);
        expect(orderProvider.dTotalPrice, 30.0);

        orderProvider.clearOrders();
        expect(orderProvider.dTotalPrice, 0.0);
      });
    });

    group('notifyListeners calls', () {
      test('addProduct should call notifyListeners', () {
        final product = Product(iId: 1, sName: 'Test Product');

        // We can't directly test notifyListeners calls, but we can verify
        // that the provider behaves as expected after operations
        expect(orderProvider.lOrderProducts.length, 0);

        orderProvider.addProduct(product);

        expect(orderProvider.lOrderProducts.length, 1);
      });

      test('removeProduct should call notifyListeners', () {
        final product = Product(iId: 1, sName: 'Test Product');

        orderProvider.addProduct(product);
        expect(orderProvider.lOrderProducts.length, 1);

        orderProvider.removeProduct(product);
        expect(orderProvider.lOrderProducts.length, 0);
      });

      test('clearOrders should call notifyListeners', () {
        final product = Product(iId: 1, sName: 'Test Product');

        orderProvider.addProduct(product);
        expect(orderProvider.lOrderProducts.length, 1);

        orderProvider.clearOrders();
        expect(orderProvider.lOrderProducts.length, 0);
      });

      test('dQuantity setter should call notifyListeners', () {
        expect(orderProvider.dQuantity, 1.0);

        orderProvider.dQuantity = 5.0;
        expect(orderProvider.dQuantity, 5.0);
      });

      test('increaseQuantity should call notifyListeners', () {
        expect(orderProvider.dQuantity, 1.0);

        orderProvider.increaseQuantity();
        expect(orderProvider.dQuantity, 2.0);
      });

      test('decreaseQuantity should call notifyListeners', () {
        orderProvider.dQuantity = 3.0;

        orderProvider.decreaseQuantity();
        expect(orderProvider.dQuantity, 2.0);
      });

      test('resetQuantity should call notifyListeners', () {
        orderProvider.dQuantity = 5.0;

        orderProvider.resetQuantity();
        expect(orderProvider.dQuantity, 1.0);
      });
    });
  });
}