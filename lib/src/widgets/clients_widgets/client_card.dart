import 'package:flutter/material.dart';

import '../../classes/client.dart';

import '../../pages/clients_pages/client_detail_page.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../general_widgets/poppins_text.dart';

class ClientCard extends StatelessWidget {
  
  final Client oClient;

  const ClientCard(
    {
      super.key,
      required this.oClient
    }
  );

  @override
  Widget build( BuildContext context ) {

    return GestureDetector( 
      onTap: () => Navigator.push(
        context,
        SlidePageRoute( page: ClientDetailPage( oClient: oClient ) )
      ),
      child: Container(
        color: ColorsApp.backgroundColor,
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveApp.dHeight( 8.0 ),
          horizontal: ResponsiveApp.dWidth( 16.0 ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveApp.dHeight( 16.0 ),
          horizontal: ResponsiveApp.dWidth( 8.0 )
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular( 8.0 ),
              child: FadeInImage(
                placeholder: AssetImage('assets/images/client_placeholder.png'),
                image: NetworkImage( oClient.sLogoUrl ?? '' ),
                imageErrorBuilder: (context, error, stackTrace) => Image.asset('assets/images/client_placeholder.png' ),
                width: ResponsiveApp.dHeight( 48.0 ),
                height: ResponsiveApp.dHeight( 48.0 ),
                fit: BoxFit.cover
              )
            ),
            SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PoppinsText(
                    sText: oClient.sName!,
                    dFontSize: ResponsiveApp.dSize( 14.0 ),
                    colorText: ColorsApp.secondaryColor,
                    fontWeight: FontWeight.w500
                  ),
                  SizedBox( height: ResponsiveApp.dHeight( 4.0 ) ),
                  PoppinsText(
                    sText: oClient.sAddress!,
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
              semanticLabel: 'View Client Details'
            )
          ]
        )
      )
    );

  }

}