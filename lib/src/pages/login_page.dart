import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:medisupply_app/src/widgets/general_widgets/snackbar_widget.dart';

import 'package:provider/provider.dart';

import '../providers/login_provider.dart';

import '../services/fetch_data.dart';

import '../utils/slide_transition.dart';
import '../utils/texts_util.dart';
import '../utils/responsive_app.dart';

import '../widgets/login_widgets/login_header.dart';
import '../widgets/general_widgets/main_button.dart';
import '../widgets/login_widgets/create_account_button.dart';
import '../widgets/general_widgets/text_form_field_widget.dart';

import 'home_page.dart';

class LoginPage extends StatefulWidget {

  const LoginPage( { super.key } );

  @override
  State<LoginPage> createState() => _LoginPageState();

}

class _LoginPageState extends State<LoginPage> {

  final oFetchData = FetchData();

  final controllerEmail = TextEditingController();
  final controllerPassword = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  bool bEmailError = false;
  bool bPassError = false;

  login() async {

    final loginProvider = Provider.of<LoginProvider>( context, listen: false );

    if( _formKey.currentState!.validate() ) {

      loginProvider.bLoading = true;

      final oUser = await oFetchData.login( controllerEmail.text, controllerPassword.text );

      loginProvider.bLoading = false;

      if(!mounted) return;

      if( oUser.sAccessToken != null ) {
        Navigator.pushReplacement(
          context,
          SlidePageRoute( page:  HomePage() )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarWidget(
            sMessage: TextsUtil.of(context)!.getText( 'login.error_login' )
          )
        );
      }

    }

  }

  @override
  Widget build( BuildContext context ) {

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const LoginHeader(),
                SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
                TextFormFieldWidget(
                  controller: controllerEmail,
                  sLabel: TextsUtil.of(context)!.getText( 'login.email' ),
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState( () => bEmailError = true );
                      return TextsUtil.of(context)!.getText( 'login.error' );
                    }
                    return null;
                  },
                  bError: bEmailError
                ),
                SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                TextFormFieldWidget(
                  controller: controllerPassword,
                  sLabel: TextsUtil.of(context)!.getText( 'login.password' ),
                  bIsPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState( () => bPassError = true );
                      return TextsUtil.of(context)!.getText( 'login.error' );
                    }
                    return null;
                  },
                  bError: bPassError
                ),
                SizedBox( height: ResponsiveApp.dHeight( 48.0 ) ),
                MainButton(
                  sLabel: TextsUtil.of(context)!.getText( 'login.button' ),
                  onPressed: login
                ),
                SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
                const CreateAccountButton()
              ]
            )
          )
        )
      )
    );

  }
}