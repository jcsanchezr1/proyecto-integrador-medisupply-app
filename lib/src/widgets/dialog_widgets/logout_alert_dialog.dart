import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/login_page.dart';

import '../../providers/login_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../general_widgets/main_button.dart';
import '../general_widgets/poppins_text.dart';
import '../general_widgets/snackbar_widget.dart';

class LogoutAlertDialog extends StatefulWidget {

  const LogoutAlertDialog( { super.key });

  @override
  State<LogoutAlertDialog> createState() => _LogoutAlertDialogState();

}

class _LogoutAlertDialogState extends State<LogoutAlertDialog> {
  
  logout() async {

    final loginProvider = Provider.of<LoginProvider>( context, listen: false );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    FetchData oFetchData = FetchData();

    loginProvider.bLoading = true;

    final token = prefs.getString('refreshToken');
    
    final bResponse = await oFetchData.logout( token! );

    if( bResponse ) {

      await prefs.clear();

      loginProvider.bLoading = false;

      if(!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        SlidePageRoute(page: LoginPage()),
        (route) => false
      );

    } else {

      loginProvider.bLoading = false;

      if(!mounted) return;

      Navigator.of(context).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget(
          sMessage: TextsUtil.of(context)!.getText('logout.error_logout'),
          bError: true
        )
      );

    }

  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: ColorsApp.backgroundColor,
      shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular( 20.0 ) ),
      content: SizedBox(
        width: ResponsiveApp.dWidth( 200.0 ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(height: ResponsiveApp.dHeight( 16.0 ) ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                PoppinsText(
                  sText: TextsUtil.of(context)!.getText('logout.title_dialog'),
                  dFontSize: ResponsiveApp.dSize( 20.0 ),
                  colorText: ColorsApp.secondaryColor,
                  fontWeight: FontWeight.w500
                ),
              ],
            ),
            SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: ResponsiveApp.dSize( 80.0 ),
                  color: ColorsApp.primaryColor
                )
              ]
            ),
            SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
            PoppinsText(
              textAlign: TextAlign.center,
              sText: TextsUtil.of(context)!.getText('logout.message_dialog'),
              dFontSize: ResponsiveApp.dSize( 14.0 ),
              colorText: ColorsApp.textColor,
              iMaxLines: 10
            )
          ]
        )
      ),
      actions: [
        MainButton(
          color: ColorsApp.textColor,
          sLabel: TextsUtil.of(context)!.getText('logout.cancel_dialog'),
          onPressed: () => Navigator.of(context).pop()
        ),
        SizedBox( height: ResponsiveApp.dHeight( 12.0 ) ),
        MainButton(
          sLabel: TextsUtil.of(context)!.getText('logout.confirm_dialog'),
          onPressed: logout
        )
      ]
    );
  }
}
