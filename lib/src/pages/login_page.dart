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
  final FetchData? fetchData;
  final TextsUtil? textsUtil; // Nuevo parámetro opcional para pruebas

  const LoginPage({super.key, this.fetchData, this.textsUtil});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  late final FetchData oFetchData;

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

      final textsUtil = widget.textsUtil ?? TextsUtil.of(context)!;
      if( oUser.sAccessToken != null ) {
        Navigator.pushReplacement(
          context,
          SlidePageRoute( page:  HomePage() )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          snackBarWidget(
            sMessage: textsUtil.getText('login.error_login')
          )
        );
      }

    }

  }

  @override
  void initState() {
    super.initState();
    oFetchData = widget.fetchData ?? FetchData();
  }

  @override
  Widget build( BuildContext context ) {

    final textsUtil = widget.textsUtil ?? TextsUtil.of(context)!;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                LoginHeader(textsUtil: textsUtil),
                SizedBox(height: ResponsiveApp.dHeight(40.0)),
                TextFormFieldWidget(
                  fieldKey: const Key('email_field'),
                  controller: controllerEmail,
                  sLabel: textsUtil.getText('login.email'),
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState(() => bEmailError = true);
                      return textsUtil.getText('login.error');
                    }
                    return null;
                  },
                  bError: bEmailError,
                ),
                SizedBox(height: ResponsiveApp.dHeight(32.0)),
                TextFormFieldWidget(
                  fieldKey: const Key('password_field'),
                  controller: controllerPassword,
                  sLabel: textsUtil.getText('login.password'),
                  bIsPassword: true,
                  validator: (value) {
                    if (value!.isEmpty) {
                      setState(() => bPassError = true);
                      return textsUtil.getText('login.error');
                    }
                    return null;
                  },
                  bError: bPassError,
                ),
                SizedBox(height: ResponsiveApp.dHeight(48.0)),
                MainButton(
                  key: const Key('login_button'),
                  sLabel: textsUtil.getText('login.button'),
                  onPressed: login,
                ),
                SizedBox(height: ResponsiveApp.dHeight(16.0)),
                CreateAccountButton(textsUtil: textsUtil),
              ],
            ),
          ),
        ),
      ),
    );

  }
}