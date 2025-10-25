import 'package:flutter/material.dart';

import '../../classes/order.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/oder_widgets/order_badge.dart';
import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/oder_widgets/order_info_item.dart';
import '../../widgets/new_order_widgets/oder_product_card.dart';

class OrderDetailPage extends StatelessWidget {

  final Order oOrder;

  const OrderDetailPage( { super.key, required this.oOrder } );

  @override
  Widget build( BuildContext context ) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.backgroundColor,
        scrolledUnderElevation: 0.0,
        title: PoppinsText(
          sText: oOrder.sOrderNumber!,
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor
        )
      ),
      body: Padding(
        padding: EdgeInsets.symmetric( horizontal: ResponsiveApp.dWidth( 24.0 ) ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
            OrderBadge(
              sLabel: oOrder.sStatus!,
              colorBadge: TextsUtil.of(context)!.getStatusColor( oOrder.sStatus! )
            ),
            SizedBox( height: ResponsiveApp.dHeight( 24.0 ) ),
            OrderInfoItem(
              sLabel: TextsUtil.of( context )!.getText( 'orders.delivery' ) ?? 'Scheduled delivery: ',
              sValue: TextsUtil.of( context )!.formatLocalizedDate( context, oOrder.sDeliveryDate! )
            ),
            SizedBox( height: ResponsiveApp.dHeight( 12.0 ) ),
            OrderInfoItem(
              sLabel: TextsUtil.of( context )!.getText( 'orders.truck' ) ?? 'Assigned truck: ',
              sValue: oOrder.sAssignedTruck!
            ),
            SizedBox( height: ResponsiveApp.dHeight( 40.0 ) ),
            PoppinsText(
              sText: TextsUtil.of( context )!.getText( 'orders.products' ) ?? 'Products',
              dFontSize: ResponsiveApp.dSize( 20.0 ),
              colorText: ColorsApp.secondaryColor,
              fontWeight: FontWeight.w500
            ),
            SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
            Expanded(
              child: ListView.builder(
                itemCount: oOrder.lProducts?.length ?? 0,
                itemBuilder: (context, index) => OrderProductCard(
                  oProduct: oOrder.lProducts![index],
                  bDelete: false,
                  bCompact: false
                )
              )
            )
          ]
        ),
      )
    );

  }

}