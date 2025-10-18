import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../providers/login_provider.dart';
import '../providers/create_account_provider.dart';

import '../services/fetch_data.dart';

import '../utils/texts_util.dart';
import '../utils/responsive_app.dart';

import '../widgets/general_widgets/main_button.dart';
import '../widgets/general_widgets/snackbar_widget.dart';
import '../widgets/general_widgets/drop_down_widget.dart';
import '../widgets/general_widgets/button_file_picker.dart';
import '../widgets/general_widgets/text_form_field_widget.dart';
import '../widgets/create_account_widgets/create_account_header.dart';

class CreateAccountPage extends StatefulWidget {

  final void Function(BuildContext context, String message)? onShowSnackBar;

  const CreateAccountPage( { super.key, this.onShowSnackBar } );

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final _formKey = GlobalKey<FormState>();
  final oFetchData = FetchData();

  final controllerNIT = TextEditingController();
  final controllerName = TextEditingController();
  final controllerEmail = TextEditingController();
  final controllerPhone = TextEditingController();
  final controllerAdress = TextEditingController();
  final controllerPassword = TextEditingController();
  final controllerNameApplicant = TextEditingController();
  final controllerEmailApplicant = TextEditingController();
  final controllerConfirmPassword = TextEditingController();

  String? fieldValidator( String? sValue ) {
    if ( sValue == null || sValue.isEmpty ) {
      return TextsUtil.of(context)!.getText('create_account.error');
    } 
    return null;
  }

  String? passWordValidator( String? sValue ) {
    
    if (sValue == null || sValue.isEmpty) {
      return TextsUtil.of(context)!.getText('create_account.error');
    }

    final regex = RegExp(r'^(?=.*[A-Za-z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$');

    if (!regex.hasMatch(sValue)) {
      return TextsUtil.of(context)!.getText('create_account.error_password');
    }

    return null;
  }

  String? confirmPasswordValidator(String? value, String password) {
    if (value == null || value.isEmpty) {
      return TextsUtil.of(context)!.getText('create_account.error');
    }

    if (value != password) {
      return TextsUtil.of(context)!.getText('create_account.error_confirm_password');
    }

    return null;
  }

  void showErrorSnackBar(BuildContext context, String message) {
    if (widget.onShowSnackBar != null) {
      widget.onShowSnackBar!(context, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget(sMessage: message),
      );
    }
  }

  void showSuccessSnackBar(BuildContext context, String message) {
    if (widget.onShowSnackBar != null) {
      widget.onShowSnackBar!(context, message);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget(sMessage: message, bError: false),
      );
    }
  }

  createAccount() async {

    final bValidator =_formKey.currentState!.validate();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final createAccountProvider = Provider.of<CreateAccountProvider>(context, listen: false);

    if ( createAccountProvider.logoFile == null ) {

      showErrorSnackBar( context, TextsUtil.of(context)!.getText('create_account.error_logo') );
      return;

    } else {

      if ( bValidator ) {

        loginProvider.bLoading = true;

        final mCoordinates = await oFetchData.getCoordinates( controllerAdress.text );

        if ( mCoordinates.isNotEmpty ) {

          final bSuccess = await oFetchData.createAccount(
            sName: controllerName.text,
            sTaxId: controllerNIT.text,
            sEmail: controllerEmail.text,
            sAddress: controllerAdress.text,
            sPhone: controllerPhone.text,
            sInstitutionType: createAccountProvider.sSelectedType,
            logoFile: createAccountProvider.logoFile!,
            sSpecialty: createAccountProvider.sSelectedSpeciality,
            sApplicatName: controllerNameApplicant.text,
            sApplicatEmail: controllerEmailApplicant.text,
            dLatitude: mCoordinates['lat'],
            dLongitude: mCoordinates['lng'],
            sPassword: controllerPassword.text,
            sPasswordConfirmation: controllerConfirmPassword.text
          );

          if( bSuccess ) {

            if (!mounted) return;
            showSuccessSnackBar( context, TextsUtil.of(context)!.getText('create_account.success_create_account') );
            await Future.delayed(
              const Duration( seconds: 2 ),
              () {
                loginProvider.bLoading = false;
                if (!mounted) return;
                Navigator.pop( context );
              }
            );

          } else {

            loginProvider.bLoading = false;
            if (!mounted) return;
            showErrorSnackBar( context, TextsUtil.of(context)!.getText('create_account.error_create_account') );

          }

        } else {

          loginProvider.bLoading = false;
          if (!mounted) return;
          showErrorSnackBar( context, TextsUtil.of(context)!.getText('create_account.error_get_coordinates') );

        }

      }

    }

  }

  @override
  Widget build( BuildContext context ) {
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: Column(
          children: [
            const CreateAccountHeader(),
            Expanded(
              child: SingleChildScrollView(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerName,
                        sLabel: TextsUtil.of(context)!.getText('create_account.name'),
                        validator: fieldValidator                                                                                           
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerNIT,
                        sLabel: TextsUtil.of(context)!.getText('create_account.nit'),
                        validator: fieldValidator,
                        keyboardType: TextInputType.number
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerEmail,
                        sLabel: TextsUtil.of(context)!.getText('create_account.email'),
                        validator: fieldValidator,
                        keyboardType: TextInputType.emailAddress
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerAdress,
                        sLabel: TextsUtil.of(context)!.getText('create_account.address'),
                        validator: fieldValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerPhone,
                        sLabel: TextsUtil.of(context)!.getText('create_account.phone'),
                        validator: fieldValidator,
                        keyboardType: TextInputType.phone
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      DropDownWidget(
                        sHintText: TextsUtil.of(context)!.getText('create_account.hint_dropdown'),
                        sLabel: TextsUtil.of(context)!.getText('create_account.institution_type'),
                        validator: fieldValidator,
                        lItems: TextsUtil.of(context)!.getText('create_account.types')
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      ButtonFilePicker(
                        lAllowedExtensions: ['jpg', 'png'],
                        sLabel: TextsUtil.of(context)!.getText('create_account.logo')
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      DropDownWidget(
                        sHintText: TextsUtil.of(context)!.getText('create_account.hint_dropdown'),
                        sLabel: TextsUtil.of(context)!.getText('create_account.speciality'),
                        validator: fieldValidator,
                        lItems: TextsUtil.of(context)!.getText('create_account.specialities'),
                        bType: false
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerNameApplicant,
                        sLabel: TextsUtil.of(context)!.getText('create_account.applicant_name'),
                        validator: fieldValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerEmailApplicant,
                        sLabel: TextsUtil.of(context)!.getText('create_account.applicant_email'),
                        validator: fieldValidator,
                        keyboardType: TextInputType.emailAddress
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerPassword,
                        sLabel: TextsUtil.of(context)!.getText('create_account.password'),
                        bIsPassword: true,
                        validator: passWordValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerConfirmPassword,
                        sLabel: TextsUtil.of(context)!.getText('create_account.confirm_password'),
                        bIsPassword: true,
                        validator: (value) => confirmPasswordValidator(value, controllerPassword.text)
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
                      MainButton(
                        sLabel: TextsUtil.of(context)!.getText('create_account.button'),
                        onPressed: createAccount
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 40.0 ) )
                    ]
                  )
                )
              )
            )
          ]
        )
      )
    );
  
  }

}