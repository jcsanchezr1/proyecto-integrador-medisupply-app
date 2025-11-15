import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/poppins_text.dart';

class ButtonUploadFile extends StatelessWidget {
  
  const ButtonUploadFile( { super.key } );

  @override
  Widget build( BuildContext context ) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PoppinsText(
              sText: '${TextsUtil.of(context)!.getText('visit_detail.evidence_label')} ',
              dFontSize: ResponsiveApp.dSize(12.0),
              colorText: ColorsApp.textColor
            ),
            PoppinsText(
              sText: '*',
              dFontSize: ResponsiveApp.dSize(12.0),
              colorText: ColorsApp.errorColor
            )
          ]
        ),
        SizedBox(height: ResponsiveApp.dHeight(8.0)),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: ColorsApp.sucessColor,
            foregroundColor: ColorsApp.backgroundColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveApp.dWidth( 24.0 ),
              vertical: ResponsiveApp.dHeight( 12.0 )
            )
          ),
          onPressed: () {},
          icon: Icon(
            Icons.upload,
            color: ColorsApp.backgroundColor,
            semanticLabel: 'Upload File'
          ),
          label: PoppinsText(
            sText: TextsUtil.of(context)!.getText('visit_detail.upload_button'),
            dFontSize: ResponsiveApp.dSize(12.0),
            colorText: ColorsApp.backgroundColor,
            fontWeight: FontWeight.w500
          )
        )
      ]
    );

  }

}