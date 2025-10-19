import 'dart:ui';
import 'package:flutter/material.dart';

class LanguageUtils {
  static final LanguageUtils _instance = LanguageUtils._internal();
  factory LanguageUtils() => _instance;
  LanguageUtils._internal();

  void Function(Locale)? _setLocale;

  void setCallBack(void Function(Locale) callback) {
    _setLocale = callback;
  }

  void changeLocale(Locale locale) {
    _setLocale?.call(locale);
  }

  Locale getDefaultLocate(BuildContext context) {
    return Locale(PlatformDispatcher.instance.locale.languageCode, '');
  }
}