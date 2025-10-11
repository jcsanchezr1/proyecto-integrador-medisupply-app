import 'package:flutter/material.dart';

class LoginProvider extends ChangeNotifier {

  bool _bLoading = false;

  bool get bLoading => _bLoading;

  set bLoading( bool bLoading ) {

    _bLoading = bLoading;

    notifyListeners();

  }

}