import 'package:flutter/material.dart';

import '../classes/product.dart';

class OrderProvider with ChangeNotifier {

  final List<Product> _lOrderProducts = [];

  double _dQuantity = 1.0;
  double get dTotalPrice => _lOrderProducts.fold(0.0, (sum, item) => sum + (item.dPrice ?? 0.0) * (item.dQuantity ?? 0.0));

  List<Product> get lOrderProducts => _lOrderProducts;
  double get dQuantity => _dQuantity;

  void addProduct( Product oProduct ) {

    final index = _lOrderProducts.indexWhere((item) => item.iId == oProduct.iId);

    if (index >= 0) {
      final updatedProduct = Product(
        iId: oProduct.iId,
        sName: oProduct.sName,
        sImage: oProduct.sImage,
        dQuantity: _dQuantity,
        dPrice: oProduct.dPrice,
        sDescription: oProduct.sDescription,
        sExpirationDate: oProduct.sExpirationDate,
      );
      _lOrderProducts[index] = updatedProduct;
    } else {
      final newProduct = Product(
        iId: oProduct.iId,
        sName: oProduct.sName,
        sImage: oProduct.sImage,
        dQuantity: _dQuantity,
        dPrice: oProduct.dPrice,
        sDescription: oProduct.sDescription,
        sExpirationDate: oProduct.sExpirationDate,
      );
      _lOrderProducts.add( newProduct );
    }
    notifyListeners();
  }

  void removeProduct( Product oProduct ) {
    _lOrderProducts.removeWhere((item) => item.iId == oProduct.iId);
    notifyListeners();
  }

  void clearOrders() {
    _lOrderProducts.clear();
    notifyListeners();
  }

  set dQuantity( double value ) {
    _dQuantity = value;
    notifyListeners();
  }

  void decreaseQuantity( ) {
    _dQuantity--;
    notifyListeners();
  }

  void increaseQuantity( ) {
    _dQuantity++;
    notifyListeners();
  }

  void resetQuantity() {
    _dQuantity = 1.0;
    notifyListeners();
  }

}