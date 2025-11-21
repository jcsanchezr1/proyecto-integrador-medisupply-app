import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/client.dart';

import '../../providers/login_provider.dart';
import '../../providers/create_account_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import 'info_visit_item.dart';
import 'findings_text_field.dart';
import '../general_widgets/main_button.dart';
import '../general_widgets/poppins_text.dart';
import '../general_widgets/snackbar_widget.dart';
import '../general_widgets/button_file_picker.dart';

class CreateVisitForm extends StatefulWidget {

  final Client oClient;
  final String sVisitId;

  const CreateVisitForm(
    {
      super.key,
      required this.oClient,
      required this.sVisitId
    }
  );

  @override
  State<CreateVisitForm> createState() => _CreateVisitFormState();

}

class _CreateVisitFormState extends State<CreateVisitForm> {

  final controller = TextEditingController();
  final oFetchData = FetchData();

  registerFindings() async {
    
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);
    final createAccountProvider = Provider.of<CreateAccountProvider>(context, listen: false);

    loginProvider.bLoading = true;
    
    final String sFindings = controller.text.trim();

    final bSuccess = await oFetchData.uploadVisitFindings(
      loginProvider.oUser!.sAccessToken!,
      loginProvider.oUser!.sId!,
      widget.sVisitId,
      widget.oClient.sClientId!,
      sFindings,
      createAccountProvider.logoFile!
    );

    if ( !bSuccess ) {
      if ( !mounted ) return;
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget(
          sMessage: TextsUtil.of(context)!.getText('visit_detail.error_register')
        )
      );
    } else {
      if ( !mounted ) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget(
          sMessage: TextsUtil.of(context)!.getText('visit_detail.success_register'),
          bError: false
        )
      );
    }

    loginProvider.bLoading = false;

  }

  @override
  Widget build( BuildContext context ) {

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.95
      ),
      decoration: BoxDecoration(
        color: ColorsApp.backgroundColor,
        borderRadius: BorderRadius.vertical(
          top: Radius.circular( 12.0 )
        )
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: ResponsiveApp.dWidth( 24.0 ),
            vertical: ResponsiveApp.dHeight( 16.0 )
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: ResponsiveApp.dWidth( 40.0 ),
                  height: ResponsiveApp.dHeight( 4.0 ),
                  margin: EdgeInsets.only( bottom: ResponsiveApp.dHeight( 16.0 ) ),
                  decoration: BoxDecoration(
                    color: ColorsApp.borderColor,
                    borderRadius: BorderRadius.circular( 4.0 )
                  )
                )
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: PoppinsText(
                      sText: widget.oClient.sName ?? '',
                      dFontSize: ResponsiveApp.dSize( 18.0 ),
                      fontWeight: FontWeight.w500,
                      colorText: ColorsApp.secondaryColor,
                      iMaxLines: 2
                    )
                  ),
                  SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      width: ResponsiveApp.dHeight( 48.0 ),
                      height: ResponsiveApp.dHeight( 48.0 ),
                      decoration: BoxDecoration(
                        color: ColorsApp.closeButtonColor,
                        borderRadius: BorderRadius.circular( 12.0 ),
                        boxShadow: [
                          BoxShadow(
                            color: ColorsApp.shadowColor,
                            blurRadius: 10.0,
                            offset: const Offset( 0, 2 )
                          )
                        ]
                      ),
                      child: const Icon(
                        Icons.close,
                        color: ColorsApp.backgroundColor,
                        semanticLabel: 'Close'
                      )
                    )
                  )
                ]
              ),
              SizedBox( height: ResponsiveApp.dHeight( 36.0 ) ),
              InfoVisitItem(
                icon: Icons.location_on,
                sText: widget.oClient.sAddress ?? ''
              ),
              SizedBox( height: ResponsiveApp.dHeight( 12.0 ) ),
              InfoVisitItem(
                icon: Icons.mark_email_read,
                sText: widget.oClient.sEmail ?? ''
              ),
              SizedBox( height: ResponsiveApp.dHeight( 12.0 ) ),
              InfoVisitItem(
                icon: Icons.phone_in_talk,
                sText: widget.oClient.sPhone ?? ''
              ),
              SizedBox( height: ResponsiveApp.dHeight( 36.0 ) ),
              FindingsTextField( controller: controller ),
              SizedBox( height: ResponsiveApp.dHeight( 24.0 ) ),
              ButtonFilePicker(
                sLabel: TextsUtil.of(context)!.getText('visit_detail.evidence_label'),
                lAllowedExtensions: ['mp4']
              ),
              SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
              MainButton(
                sLabel: TextsUtil.of(context)!.getText('visit_detail.register_button'), 
                onPressed: registerFindings
              ),
              SizedBox( height: ResponsiveApp.dHeight( 8.0 ) )
            ]
          )
        )
      )
    );

  }
}