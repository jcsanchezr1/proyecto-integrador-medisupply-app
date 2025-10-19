import 'package:flutter/material.dart';

import '../classes/user.dart';

class LoginProvider extends ChangeNotifier {

  User? _oUser = User();
  bool _bLoading = false;

  User? get oUser => _oUser;
  bool get bLoading => _bLoading;

  set oUser( User? oUser ) {

    _oUser = oUser;

    notifyListeners();

  }

  set bLoading( bool bLoading ) {

    _bLoading = bLoading;

    notifyListeners();

  }

}