import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/new_order_widgets/footer_order_summary.dart';
import '../../widgets/new_order_widgets/oder_product_card.dart';

class OrderSummaryPage extends StatelessWidget {
  
  const OrderSummaryPage( { super.key } );

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>( context );

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
          FooterOrderSummary()
        ]
      )
    );

  }

}