import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class TextsUtil {
  
  final Locale locale;

  late Map<String, dynamic> mLocalizedStrings;

  TextsUtil(this.locale);

  static const LocalizationsDelegate<TextsUtil> delegate = TextsUtilDelegate();

  static TextsUtil? of( BuildContext context ) {
    // First try Localizations
    TextsUtil? result = Localizations.of<TextsUtil>( context, TextsUtil );
    if (result != null) return result;
    
    // Fallback to Provider for testing
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