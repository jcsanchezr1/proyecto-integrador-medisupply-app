import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../pages/home_page.dart';
import '../../providers/login_provider.dart';
import '../../providers/order_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../general_widgets/main_button.dart';
import '../general_widgets/poppins_text.dart';
import '../general_widgets/snackbar_widget.dart';

class FooterOrderSummary extends StatefulWidget {

  final Map<String, dynamic> mOrder;

  const FooterOrderSummary( { super.key, required this.mOrder } );

  @override
  State<FooterOrderSummary> createState() => _FooterOrderSummaryState();

}

class _FooterOrderSummaryState extends State<FooterOrderSummary> {
  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>( context );
    final loginProvider = Provider.of<LoginProvider>( context );
    final oFetchData = FetchData();

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
                flex: 2,
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
                      sText: '\$${TextsUtil.of(context)?.formatNumber( orderProvider.dTotalPrice ) ?? '0'}',
                      dFontSize: ResponsiveApp.dSize( 22.0 ),
                      colorText: ColorsApp.secondaryColor,
                      fontWeight: FontWeight.w600
                    )
                  ]
                )
              ),
              Expanded(
                flex: 1,
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
            onPressed: () async {

              loginProvider.bLoading = true;

              final messenger = ScaffoldMessenger.of(context);
              final navigator = Navigator.of(context);
              final texts = TextsUtil.of(context)!;

              final bSuccess = await oFetchData.createOrder( loginProvider.oUser!.sAccessToken!, widget.mOrder );

              if ( bSuccess ) {
                messenger.showSnackBar(
                  snackBarWidget(sMessage: texts.getText( 'new_order.success_order' ), bError: false),
                );
                orderProvider.lOrderProducts.clear();
                navigator.pushAndRemoveUntil( SlidePageRoute(page: HomePage()), ( route ) => false );
              } else {
                messenger.showSnackBar(
                  snackBarWidget(sMessage: texts.getText( 'new_order.error_order' ), bError: true),
                );
              }

              loginProvider.bLoading = false;

            }
          )
        ]
      )
    );

  }
}