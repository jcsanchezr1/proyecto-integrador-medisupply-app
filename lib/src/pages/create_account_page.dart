import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/texts_util.dart';
import '../utils/responsive_app.dart';

import '../widgets/general_widgets/button_file_picker.dart';
import '../widgets/general_widgets/main_button.dart';
import '../widgets/general_widgets/drop_down_widget.dart';
import '../widgets/general_widgets/text_form_field_widget.dart';
import '../widgets/create_account_widgets/create_account_header.dart';

class CreateAccountPage extends StatefulWidget {

  const CreateAccountPage( { super.key } );

  @override
  State<CreateAccountPage> createState() => _CreateAccountPageState();

}

class _CreateAccountPageState extends State<CreateAccountPage> {

  final _formKey = GlobalKey<FormState>();

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
                        validator: fieldValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerEmail,
                        sLabel: TextsUtil.of(context)!.getText('create_account.email'),
                        validator: fieldValidator
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
                        validator: fieldValidator
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
                        lItems: TextsUtil.of(context)!.getText('create_account.specialities')
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
                        validator: fieldValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerPassword,
                        sLabel: TextsUtil.of(context)!.getText('create_account.password'),
                        bIsPassword: true,
                        validator: fieldValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
                      TextFormFieldWidget(
                        controller: controllerConfirmPassword,
                        sLabel: TextsUtil.of(context)!.getText('create_account.confirm_password'),
                        bIsPassword: true,
                        validator: fieldValidator
                      ),
                      SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
                      MainButton(
                        sLabel: TextsUtil.of(context)!.getText('create_account.button'),
                        onPressed: () {
                          _formKey.currentState!.validate();
                        }
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