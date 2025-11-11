import 'package:flutter/material.dart';
import 'package:medisupply_app/src/pages/orders_pages/new_order_page.dart';

import '../../classes/client.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';
import '../../utils/texts_util.dart';
import '../../widgets/clients_widgets/info_client_item.dart';
import '../../widgets/general_widgets/main_button.dart';
import '../../widgets/general_widgets/poppins_text.dart';

class ClientDetailPage extends StatelessWidget {

  final Client oClient;

  const ClientDetailPage(
    {
      super.key,
      required this.oClient
    }
  );

  @override
  Widget build( BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.backgroundColor,
        scrolledUnderElevation: 0
      ),
      body: Stack(
        children: [
          Positioned(
            bottom: 0.0,
            child: Opacity(
              opacity: 0.1,
              child: FadeInImage(
                placeholder: AssetImage('assets/images/client_placeholder.png'),
                image: NetworkImage( oClient.sLogoUrl ?? '' ),
                imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                  'assets/images/client_placeholder.png',
                  width: ResponsiveApp.dWidth( 360.0 ),
                  height: ResponsiveApp.dWidth( 360.0 )
                ),
                width: ResponsiveApp.dWidth( 360.0 ),
                height: ResponsiveApp.dWidth( 360.0 ),
                fit: BoxFit.cover
              )
            )
          ),
          Column(
            children: [
              SizedBox( height: ResponsiveApp.dHeight( 24.0 ) ),
              Container(
                clipBehavior: Clip.antiAlias,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: ColorsApp.shadowColor,
                      blurRadius: 50.0,
                      offset: Offset( 0, 2 )
                    )
                  ]
                ),
                child: FadeInImage(
                  placeholder: AssetImage('assets/images/client_placeholder.png'),
                  image: NetworkImage( oClient.sLogoUrl ?? '' ),
                  imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                    'assets/images/client_placeholder.png',
                    width: ResponsiveApp.dHeight( 120.0 ),
                    height: ResponsiveApp.dHeight( 120.0 )
                  ),
                  width: ResponsiveApp.dHeight( 120.0 ),
                  height: ResponsiveApp.dHeight( 120.0 ),
                  fit: BoxFit.cover
                )
              ),
              SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
              PoppinsText(
                sText: oClient.sName!,
                dFontSize: ResponsiveApp.dSize( 20.0 ),
                colorText: ColorsApp.secondaryColor,
                fontWeight: FontWeight.w500
              ),
              SizedBox( height: ResponsiveApp.dHeight( 32.0 ) ),
              InfoClientItem(
                iconData: Icons.health_and_safety_rounded,
                sInfo: oClient.sInstitutionType!
              ),
              InfoClientItem(
                iconData: Icons.add_location_rounded,
                sInfo: oClient.sAddress!
              ),
              InfoClientItem(
                iconData: Icons.mark_email_read_rounded,
                sInfo: oClient.sEmail!
              ),
              InfoClientItem(
                iconData: Icons.phone_in_talk_rounded,
                sInfo: oClient.sPhone!
              ),
              Expanded( child: SizedBox() ),
              MainButton(
                sLabel: TextsUtil.of( context )!.getText( 'new_order.title' ),
                onPressed: () => Navigator.push(
                  context,
                  SlidePageRoute( page: NewOrderPage( sClientId: oClient.sClientId! ) )
                )
              ),
              SizedBox( height: ResponsiveApp.dHeight( 32.0 ) )
            ]
          )
        ]
      )
    );

  }

}