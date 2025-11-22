import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/product.dart';

import '../../providers/order_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../../utils/texts_util.dart';

import '../general_widgets/poppins_text.dart';

class OrderProductCard extends StatelessWidget {

  final bool bDelete;
  final bool bCompact;
  final Product oProduct;

  const OrderProductCard(
    {
      super.key,
      this.bDelete = true,
      this.bCompact = true,
      required this.oProduct
    }
  );

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>( context );

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: ResponsiveApp.dWidth( bCompact ? 16.0 : 0.0 ),
        vertical: ResponsiveApp.dHeight( 8.0 )
      ),
      padding: EdgeInsets.symmetric(
        horizontal: ResponsiveApp.dWidth( bCompact ? 8.0 : 0.0 ),
        vertical: ResponsiveApp.dHeight( 8.0 )
      ),
      child: Row(
        children: [
          Container(
            width: ResponsiveApp.dWidth( 40.0 ),
            height: ResponsiveApp.dWidth( 40.0 ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular( 8.0 )
            ),
            child: FadeInImage(
              placeholder: AssetImage( 'assets/images/placeholder.png' ),
              image: (oProduct.sImage != null && oProduct.sImage!.isNotEmpty) ? NetworkImage(oProduct.sImage!) : AssetImage('assets/images/placeholder.png'),
              imageErrorBuilder: (context, error, stackTrace) => Image.asset( 'assets/images/placeholder.png' )
            )
          ),
          SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                PoppinsText(
                  sText: oProduct.sName ?? 'Unknown Product',
                  dFontSize: ResponsiveApp.dSize( 14.0 ),
                  colorText: ColorsApp.secondaryColor,
                  fontWeight: FontWeight.w500
                ),
                SizedBox( height: ResponsiveApp.dHeight( 2.0 ) ),
                PoppinsText(
                  sText: '${(oProduct.dQuantity ?? 0).toInt().toString()} ${TextsUtil.of(context)?.getText( (oProduct.dQuantity ?? 0) > 1 ? 'order_summary.units' : 'order_summary.unit' ) ?? 'units'}',
                  dFontSize: ResponsiveApp.dSize( 12.0 ),
                  colorText: ColorsApp.textColor
                )
              ]
            )
          ),
          SizedBox( width: ResponsiveApp.dWidth( 12.0 ) ),
          bDelete ? IconButton(
            onPressed: () => orderProvider.removeProduct(oProduct),
            icon: Icon(
              Icons.delete_rounded,
              color: ColorsApp.textColor,
              semanticLabel: 'Delete product'
            )
          ) : SizedBox()
        ]
      )
    );

  }

}