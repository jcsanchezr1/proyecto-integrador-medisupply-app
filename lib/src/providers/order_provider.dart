import 'package:flutter/material.dart';

import '../classes/product.dart';

class OrderProvider with ChangeNotifier {

  final List<Product> _lOrderProducts = [];

  double _dQuantity = 1.0;
  double get dTotalPrice => _lOrderProducts.fold(0, (sum, item) => sum + item.dPrice! * _dQuantity);

  List<Product> get lOrderProducts => _lOrderProducts;
  double get dQuantity => _dQuantity;

  void addProduct( Product oProduct ) {
    
    final index = _lOrderProducts.indexWhere((item) => item.sName == oProduct.sName);

    if (index >= 0) {
      _lOrderProducts[index].dQuantity = _dQuantity;
    } else {
      _lOrderProducts.add( oProduct );
    }
    notifyListeners();
  }

  void removeProduct( Product oProduct ) {
    _lOrderProducts.remove( oProduct );
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