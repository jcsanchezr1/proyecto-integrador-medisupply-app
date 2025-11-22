import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import 'colors_app.dart';

class TextsUtil {
  
  final Locale locale;

  late Map<String, dynamic> mLocalizedStrings;

  TextsUtil(this.locale);

  static const LocalizationsDelegate<TextsUtil> delegate = TextsUtilDelegate();

  static TextsUtil? of( BuildContext context ) {

    TextsUtil? result = Localizations.of<TextsUtil>( context, TextsUtil );
    if (result != null) return result;
    
    try {
      return Provider.of<TextsUtil>(context, listen: false);
    } catch (e) {
      return null;
    }
  }

  Future<void> load() async {
    String sJsonString = await rootBundle.loadString('assets/language/${locale.languageCode}_language.json');
    mLocalizedStrings = json.decode(sJsonString);
  }

  dynamic getText(String sKey) {
    List<String> lKeys = sKey.split('.');
    dynamic value = mLocalizedStrings;
    for (var k in lKeys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value;
  }

  static Future<dynamic> getSpanishText(String sKey) async {
    String sJsonString = await rootBundle.loadString('assets/language/es_language.json');
    Map<String, dynamic> localizedStrings = json.decode(sJsonString);

    List<String> lKeys = sKey.split('.');
    dynamic value = localizedStrings;

    for (var k in lKeys) {
      if (value is Map<String, dynamic> && value.containsKey(k)) {
        value = value[k];
      } else {
        return null;
      }
    }
    return value;
  }

  String formatLocalizedDate(BuildContext context, String isoDateString) {
    try {
      final date = DateTime.parse(isoDateString);

      final textsUtil = TextsUtil.of(context);
      final languageCode = textsUtil?.locale.languageCode ?? Localizations.localeOf(context).languageCode;

      const pattern = "MMM d, y";
      final formatter = DateFormat(pattern, languageCode);

      final formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
    } catch (e) {
      return isoDateString;
    }
  }

  String largeFormatLocalizedDate( BuildContext context, String sDateString ) {
    try {
      DateTime date;

      if (RegExp(r'^\d{2}-\d{2}-\d{4}$').hasMatch(sDateString)) {
        date = DateFormat('dd-MM-yyyy').parse(sDateString);
      } else {
        date = DateTime.parse(sDateString);
      }

      final textsUtil = TextsUtil.of(context);
      final languageCode = textsUtil?.locale.languageCode ?? Localizations.localeOf(context).languageCode;

      final formatter = DateFormat('MMMM dd, yyyy', languageCode);

      final formatted = formatter.format(date);
      return formatted[0].toUpperCase() + formatted.substring(1);
      
    } catch (e) {
      return sDateString;
    }
  }

  Color getStatusColor(String sStatus) {
    switch (sStatus.toLowerCase()) {
      case 'recibido':
        return ColorsApp.primaryColor;
      case 'en preparación':
        return ColorsApp.accentColor;
      case 'en tránsito':
        return ColorsApp.transitColor;
      case 'entregado':
        return ColorsApp.sucessColor;
      case 'devuelto':
        return ColorsApp.errorColor;
      default:
        return ColorsApp.secondaryColor;
    }
  }

  String formatNumber(double dNumber) {
    final formatter = NumberFormat("#,##0.##", "es_ES");
    return formatter.format(dNumber);
  }

}

class TextsUtilDelegate extends LocalizationsDelegate<TextsUtil> {

  const TextsUtilDelegate();

  @override
  bool isSupported( Locale locale ) => ['en', 'es'].contains( locale.languageCode );

  @override
  Future<TextsUtil> load( Locale locale ) async {

    TextsUtil localizations = TextsUtil( locale );
    
    await localizations.load();
    
    return localizations;
  
  }

  @override
  bool shouldReload( TextsUtilDelegate old ) => false;

}