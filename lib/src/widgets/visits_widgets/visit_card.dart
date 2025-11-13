import 'package:flutter/material.dart';

import '../../classes/visit.dart';

import '../../pages/visits_pages/visit_detail_page.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../general_widgets/poppins_text.dart';

class VisitCard extends StatelessWidget {

  final Visit oVisit;
  final int iIndex;

  const VisitCard(
    {
      super.key,
      required this.oVisit,
      required this.iIndex
    }
  );

  @override
  Widget build( BuildContext context ) {

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        SlidePageRoute( page: VisitDetailPage( oVisit: oVisit ) )
      ),
      child: Container(
        color: ColorsApp.backgroundColor,
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveApp.dHeight( 4.0 ),
          horizontal: ResponsiveApp.dWidth( 8.0 ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveApp.dHeight( 10.0 ),
          horizontal: ResponsiveApp.dWidth( 8.0 )
        ),
        child: Row(
          children: [
            Container(
              width: ResponsiveApp.dHeight( 48.0 ),
              height: ResponsiveApp.dHeight( 48.0 ),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ColorsApp.primaryColor.withValues( alpha: 0.1 )
              ),
              child: PoppinsText(
                sText: iIndex.toString().padLeft(2, '0'),
                dFontSize: ResponsiveApp.dSize( 14.0 ),
                colorText: ColorsApp.primaryColor,
                fontWeight: FontWeight.w600
              )
            ),
            SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PoppinsText(
                    sText: TextsUtil.of( context )?.largeFormatLocalizedDate( context, oVisit.sDate ) ?? 'Unknown Date',
                    dFontSize: ResponsiveApp.dSize( 14.0 ),
                    colorText: ColorsApp.secondaryColor,
                    fontWeight: FontWeight.w500
                  ),
                  SizedBox( height: ResponsiveApp.dHeight( 4.0 ) ),
                  PoppinsText(
                    sText: '${oVisit.iCountClients} ${TextsUtil.of(context)?.getText( oVisit.iCountClients > 1 ? 'visits.count_clients' : 'visits.count_client' ) }',
                    dFontSize: ResponsiveApp.dSize( 12.0 ),
                    colorText: ColorsApp.textColor
                  )
                ]
              )
            ),
            SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
            Icon(
              Icons.chevron_right_rounded,
              color: ColorsApp.secondaryColor,
              semanticLabel: 'View Visit Details'
            )
          ]
        )
      )
    );

  }

}