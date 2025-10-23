import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/main_button.dart';
import '../general_widgets/poppins_text.dart';

class FooterOrderSummary extends StatelessWidget {

  const FooterOrderSummary( { super.key } );

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>( context );

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveApp.dWidth( 24.0 ),
        vertical: ResponsiveApp.dHeight( 32.0 )
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoppinsText(
                      sText: TextsUtil.of(context)?.getText( 'order_summary.total' ) ?? 'Total',
                      dFontSize: ResponsiveApp.dSize( 12.0 ),
                      colorText: ColorsApp.textColor
                    ),
                    SizedBox( height: ResponsiveApp.dHeight( 2.0 ) ),
                    PoppinsText(
                      sText: '\$${TextsUtil.of(context)?.formatNumber( orderProvider.dTotalPrice.toInt() ) ?? '0'}',
                      dFontSize: ResponsiveApp.dSize( 22.0 ),
                      colorText: ColorsApp.secondaryColor,
                      fontWeight: FontWeight.w600
                    )
                  ]
                )
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoppinsText(
                      sText: TextsUtil.of(context)?.getText( 'order_summary.delivery_time' ) ?? 'Delivery Time',
                      dFontSize: ResponsiveApp.dSize( 12.0 ),
                      colorText: ColorsApp.textColor
                    ),
                    SizedBox( height: ResponsiveApp.dHeight( 2.0 ) ),
                    PoppinsText(
                      sText: '2 ${TextsUtil.of(context)?.getText( 'order_summary.days' ) ?? 'days'}',
                      dFontSize: ResponsiveApp.dSize( 22.0 ),
                      colorText: ColorsApp.secondaryColor,
                      fontWeight: FontWeight.w600
                    )
                  ]
                )
              )
            ]
          ),
          SizedBox( height: ResponsiveApp.dHeight( 24.0 ) ),
          MainButton(
            sLabel: TextsUtil.of(context)?.getText( 'order_summary.finish_button' ) ?? 'Finish Order',
            onPressed: () {}
          )
        ]
      )
    );

  }

}