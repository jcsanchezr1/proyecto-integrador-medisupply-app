import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/login_provider.dart';
import '../../providers/order_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/new_order_widgets/oder_product_card.dart';
import '../../widgets/new_order_widgets/footer_order_summary.dart';

class OrderSummaryPage extends StatelessWidget {
  
  const OrderSummaryPage( { super.key } );

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>( context );
    final loginProvider = Provider.of<LoginProvider>( context );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.backgroundColor,
        scrolledUnderElevation: 0.0,
        title: PoppinsText(
          sText: TextsUtil.of(context)?.getText( 'order_summary.title' ) ?? 'Order Summary',
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor
        )
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: orderProvider.lOrderProducts.length,
              itemBuilder: ( context, index ) => OrderProductCard( oProduct: orderProvider.lOrderProducts[index] )
            )
          ),
          FooterOrderSummary(
            mOrder: {
              "client_id": loginProvider.oUser!.sId,
              "total_amount": orderProvider.dTotalPrice,
              "scheduled_delivery_date": DateTime.now().add(const Duration(days: 2)).toIso8601String(),
              "items": orderProvider.lOrderProducts.map( ( product ) => {
                  "product_id": product.iId,
                  "quantity": product.dQuantity
              } ).toList()
            }
          )
        ]
      )
    );

  }

}