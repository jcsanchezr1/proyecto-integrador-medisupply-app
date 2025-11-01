import 'package:flutter/material.dart';

import '../../classes/order.dart';

import '../../pages/orders_pages/order_detail_page.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../general_widgets/poppins_text.dart';
import 'order_badge.dart';

class OrderCard extends StatelessWidget {

  final Order oOrder;

  const OrderCard( { super.key, required this.oOrder } );

  @override
  Widget build(BuildContext context ) {

    return GestureDetector( 
      onTap: () => Navigator.push(
        context,
        SlidePageRoute( page: OrderDetailPage( oOrder: oOrder ) )
      ),
      child: Container(
        margin: EdgeInsets.symmetric(
          vertical: ResponsiveApp.dHeight( 8.0 ),
          horizontal: ResponsiveApp.dWidth( 16.0 ),
        ),
        padding: EdgeInsets.symmetric(
          vertical: ResponsiveApp.dHeight( 16.0 ),
          horizontal: ResponsiveApp.dWidth( 16.0 )
        ),
        decoration: BoxDecoration(
          color: ColorsApp.cardBackgroundColor,
          borderRadius: BorderRadius.circular( 12.0 )
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PoppinsText(
                    sText: oOrder.sOrderNumber!,
                    dFontSize: ResponsiveApp.dSize( 14.0 ),
                    colorText: ColorsApp.secondaryColor,
                    fontWeight: FontWeight.w500
                  ),
                  SizedBox( height: ResponsiveApp.dHeight( 8.0 ) ),
                  OrderBadge(
                    sLabel: TextsUtil.of(context)!.formatLocalizedDate( context, oOrder.sDeliveryDate! ),
                    colorBadge: ColorsApp.secondaryColor
                  ),
                  SizedBox( height: ResponsiveApp.dHeight( 8.0 ) ),
                  OrderBadge(
                    sLabel: oOrder.sStatus!,
                    colorBadge: TextsUtil.of(context)!.getStatusColor( oOrder.sStatus! )
                  )
                ]
              )
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: ColorsApp.secondaryColor,
              semanticLabel: 'View Order Details'
            )
          ]
        )
      )
    );

  }

}