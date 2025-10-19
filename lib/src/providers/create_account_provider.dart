import 'dart:io';

import 'package:flutter/material.dart';

class CreateAccountProvider extends ChangeNotifier {

  File? _logoFile;
  String _sSelectedSpeciality = '';
  String _sSelectedType = '';

  File? get logoFile => _logoFile;
  String get sSelectedSpeciality => _sSelectedSpeciality;
  String get sSelectedType => _sSelectedType;

  set logoFile( File? file ) {
    _logoFile = file;
    notifyListeners();
  }
  
  set sSelectedSpeciality( String value ) {
    _sSelectedSpeciality = value;
    notifyListeners();
  }
  
  set sSelectedType( String value ) {
    _sSelectedType = value;
    notifyListeners();
  }

}