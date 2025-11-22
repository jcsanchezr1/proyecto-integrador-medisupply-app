import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/product.dart';

import '../../providers/order_provider.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/main_button.dart';
import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/new_order_widgets/quantity_product.dart';

class ProductDetailPage extends StatefulWidget {

  final Product oProduct;

  const ProductDetailPage( { super.key, required this.oProduct } );

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();

}

class _ProductDetailPageState extends State<ProductDetailPage> {

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: ColorsApp.backgroundColor,
        scrolledUnderElevation: 0
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveApp.dWidth( 24.0 ),
                vertical: ResponsiveApp.dHeight( 16.0 )
              ),
              children: [
                Container(
                  decoration: BoxDecoration( borderRadius: BorderRadius.circular( 16.0 ) ),
                  child: FadeInImage(
                    placeholder: AssetImage('assets/images/placeholder.png'),
                    image: (widget.oProduct.sImage != null && widget.oProduct.sImage!.isNotEmpty) ? NetworkImage(widget.oProduct.sImage!) : AssetImage('assets/images/placeholder.png'),
                    imageErrorBuilder: (context, error, stackTrace) => Image.asset(
                      'assets/images/placeholder.png',
                      width: ResponsiveApp.dWidth( 312.0 ),
                      height: ResponsiveApp.dWidth( 312.0 )
                    ),
                    width: ResponsiveApp.dWidth( 312.0 ),
                    height: ResponsiveApp.dWidth( 312.0 ),
                    fit: BoxFit.cover
                  )
                ),
                SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
                PoppinsText(
                  sText: '\$${ TextsUtil.of(context)?.formatNumber( widget.oProduct.dPrice ?? 0.0 ) }',
                  dFontSize: ResponsiveApp.dSize( 16.0 ),
                  colorText: ColorsApp.secondaryColor,
                  fontWeight: FontWeight.bold
                ),
                SizedBox( height: ResponsiveApp.dHeight( 8.0 ) ),
                PoppinsText(
                  sText: widget.oProduct.sName ?? 'Unknown Product',
                  dFontSize: ResponsiveApp.dSize( 24.0 ),
                  colorText: ColorsApp.secondaryColor,
                  iMaxLines: 5
                ),
                SizedBox( height: ResponsiveApp.dHeight( 4.0 ) ),
                PoppinsText(
                  sText: '${TextsUtil.of(context)?.getText( 'new_order.expiry' )} ${widget.oProduct.sExpirationDate != null ? TextsUtil.of(context)?.formatLocalizedDate(context, widget.oProduct.sExpirationDate!) : 'N/A'}',
                  dFontSize: ResponsiveApp.dSize( 12.0 ),
                  colorText: ColorsApp.secondaryColor,
                  fontWeight: FontWeight.w500
                ),
                SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
                PoppinsText(
                  sText: widget.oProduct.sDescription ?? '',
                  dFontSize: ResponsiveApp.dSize( 13.0 ),
                  colorText: ColorsApp.textColor,
                  iMaxLines: 100
                )
              ]
            )
          ),
          Padding(
            padding: EdgeInsets.symmetric(
              horizontal: ResponsiveApp.dWidth( 24.0 ),
              vertical: ResponsiveApp.dHeight( 32.0 )
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                QuantityProduct( dQuantity: widget.oProduct.dQuantity ?? 999 ),
                SizedBox(
                  width: ResponsiveApp.dWidth( 128.0 ),
                  height: ResponsiveApp.dHeight( 48.0 ),
                  child: MainButton(
                    sLabel: TextsUtil.of(context)?.getText( 'new_order.add_button' ) ?? 'Add to Cart',
                    onPressed: () {
                      orderProvider.addProduct(
                        Product(
                          iId: widget.oProduct.iId,
                          sName: widget.oProduct.sName,
                          sImage: widget.oProduct.sImage,
                          dPrice: widget.oProduct.dPrice,
                          dQuantity: orderProvider.dQuantity,
                          sExpirationDate: widget.oProduct.sExpirationDate,
                          sDescription: widget.oProduct.sDescription
                        )
                      );
                      orderProvider.resetQuantity();
                      Navigator.pop(context);
                    }
                  )
                )
              ]
            )
          )
        ]
      )
    );

  }

}