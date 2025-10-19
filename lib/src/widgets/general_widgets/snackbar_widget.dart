import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';

import '../../utils/responsive_app.dart';

import 'poppins_text.dart';

SnackBar snackBarWidget(
  {
    bool bError = true,
    required String sMessage
  }
) => SnackBar(
  duration: Duration( seconds: 5 ),
  content: PoppinsText(
    sText: sMessage,
    dFontSize: ResponsiveApp.dSize( 12.0 ),
    colorText: ColorsApp.secondaryTextColor,
    fontWeight: FontWeight.w500,
    iMaxLines: 3
  ),
  backgroundColor: bError ? ColorsApp.errorColor : ColorsApp.sucessColor
);