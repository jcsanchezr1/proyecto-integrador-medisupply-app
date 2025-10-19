import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../providers/login_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/language_util.dart';
import '../../utils/responsive_app.dart';

import '../dialog_widgets/logout_alert_dialog.dart';
import 'poppins_text.dart';

class DrawerMenuWidget extends StatefulWidget {

  const DrawerMenuWidget( { super.key} );

  @override
  State<DrawerMenuWidget> createState() => _DrawerMenuWidgetState();

}

class _DrawerMenuWidgetState extends State<DrawerMenuWidget> {

  List<dynamic> lLanguages = [];
  String? selectedLanguage;

  void _initLanguageValues() {
    lLanguages = TextsUtil.of(context)?.getText('menu.languages') ?? [];
  }

  Future<void> _savedSelectedLanguage(String sLanguageId) async {
    SharedPreferences perfs = await SharedPreferences.getInstance();
    Locale locale;
    switch (sLanguageId) {
      case 'en':
        locale = const Locale('en', 'US');
        break;
      case 'es':
        locale = const Locale('es', 'ES');
        break;
      default:
        locale = const Locale('en', 'US');
    }

    await perfs.setString('languageCode', locale.languageCode);
    _applyLocale(locale);

  }

  void _applyLocale(Locale locale) {
    LanguageUtils().changeLocale(locale);
    _initLanguageValues();
    setState(() {
      for (var language in lLanguages) {
        final languageId = language["id"];
        language["selected"] = languageId != null && languageId == locale.languageCode;
      }
      selectedLanguage = locale.languageCode;
    });
  }

  Future<void> _loadSelectedLanguage() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? savedLanguageId = prefs.getString('languageCode');

    setState(() {
      for (var language in lLanguages) {
        language["selected"] = false;
      }

      if (savedLanguageId != null) {
        final language = lLanguages.firstWhere(
          (language) => language["id"] != null && language["id"] == savedLanguageId,
          orElse: () => lLanguages.isNotEmpty ? lLanguages.first : {"id": "es", "selected": false},
        );
        language["selected"] = true;
        selectedLanguage = language["id"];
        _applyLocale(Locale(savedLanguageId, ''));
      } else {
        final String sDefaultLanguageId = LanguageUtils().getDefaultLocate(context).languageCode;
        final language = lLanguages.firstWhere(
          (language) => language["id"] != null && language["id"] == sDefaultLanguageId,
          orElse: () => lLanguages.isNotEmpty ? lLanguages.first : {"id": "es", "selected": false},
        );
        language["selected"] = true;
        selectedLanguage = language["id"];
        _applyLocale(Locale(language["id"] ?? "es", ''));
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _initLanguageValues();
    _loadSelectedLanguage();
  }

  @override
  Widget build( BuildContext context ) {

    final loginProvider = Provider.of<LoginProvider>(context);

    return SizedBox(
      width: ResponsiveApp.dWidth( 264.0 ),
      child: Drawer(
        backgroundColor: ColorsApp.backgroundColor,
        shape: RoundedRectangleBorder( borderRadius: BorderRadius.zero ),
        child: ListView(
          padding: EdgeInsets.only( top: ResponsiveApp.dHeight( 48.0 ) ),
          children: [
            Container(
              padding: EdgeInsets.only(
                left: ResponsiveApp.dWidth( 16.0 )
              ),
              alignment: Alignment.centerLeft,
              child: Image.asset(
                'assets/images/blue_logo.png',
                height: ResponsiveApp.dHeight( 48.0 )
              )
            ),
            Padding(
              padding: EdgeInsets.only(
                left: ResponsiveApp.dWidth( 16.0 ),
                right: ResponsiveApp.dWidth( 16.0 ),
                top: ResponsiveApp.dHeight( 16.0 ),
              ),
              child: PoppinsText(
                sText: ( '${TextsUtil.of(context)!.getText('menu.greeting')}, ${loginProvider.oUser!.sName}' ),
                colorText: ColorsApp.textColor,
                dFontSize: ResponsiveApp.dSize( 14.0 ),
                fontWeight: FontWeight.w600
              )
            ),
            Padding(
              padding: EdgeInsets.only(
                left: ResponsiveApp.dWidth( 16.0 ),
                right: ResponsiveApp.dWidth( 16.0 ),
                top: ResponsiveApp.dHeight( 8.0 ),
              ),
              child: PoppinsText(
                sText: loginProvider.oUser!.sEmail!,
                colorText: ColorsApp.textColor,
                dFontSize: ResponsiveApp.dSize( 12.0 )
              )
            ),
            Divider(
              height: ResponsiveApp.dHeight( 24.0 ),
              thickness: ResponsiveApp.dHeight( 1.0 ),
              color: ColorsApp.borderColor
            ),
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.language_rounded,
                        color: ColorsApp.primaryColor,
                        semanticLabel: 'Language'
                      ),
                      SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
                      PoppinsText(
                        sText: TextsUtil.of(context)?.getText('menu.language'),
                        colorText: ColorsApp.textColor,
                        dFontSize: ResponsiveApp.dSize( 12.0 )
                      )
                    ]
                  ),
                  SizedBox( height: ResponsiveApp.dHeight( 24.0 ) ),
                  Container(
                    alignment: Alignment.center,
                    height: ResponsiveApp.dHeight( 48.0 ),
                    width: ResponsiveApp.dWidth( 232.0 ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular( 12.0 ),
                      border: Border.all( color: ColorsApp.secondaryColor ),
                    ),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.symmetric( horizontal: ResponsiveApp.dWidth( 16.0 ) ),
                        border: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        errorBorder: InputBorder.none,
                        disabledBorder: InputBorder.none,
                      ),
                      items: lLanguages.where((language) => language["id"] != null && language["language"] != null).map((language) => DropdownMenuItem<String>(
                          value: language["id"]!,
                          child: PoppinsText(
                            sText: language["language"]!,
                            dFontSize: ResponsiveApp.dSize(12.0),
                            colorText: ColorsApp.textColor
                          )
                        )
                      ).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setState( () {
                            for (var language in lLanguages) {
                              language["selected"] = false;
                            }
                            lLanguages.firstWhere((language) => language["id"] == value)["selected"] = true;
                            selectedLanguage = value;
                          });
                          _savedSelectedLanguage(value);
                        }
                      },
                      value: selectedLanguage
                    )
                  )
                ]
              )
            ),
            Divider(
              height: ResponsiveApp.dHeight( 24.0 ),
              thickness: ResponsiveApp.dHeight( 1.0 ),
              color: ColorsApp.borderColor
            ),
            ListTile(
              title: Row(
                children: [
                  Icon(
                    Icons.logout_rounded,
                    color: ColorsApp.primaryColor,
                    semanticLabel: 'Logout',
                  ),
                  SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
                  PoppinsText(
                    sText: TextsUtil.of(context)?.getText('menu.logout'),
                    colorText: ColorsApp.textColor,
                    dFontSize: ResponsiveApp.dSize( 12.0 )
                  )
                ]
              ),
              onTap: () => showDialog(
                context: context,
                builder: ( _ ) => LogoutAlertDialog()
              )
            )
          ]
        )
      )
    );
  
  }
}