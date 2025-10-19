import 'package:flutter/material.dart';

import '../../classes/product.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/poppins_text.dart';

class ProductCard extends StatelessWidget {

  final Product oProduct;

  const ProductCard( { super.key, required this.oProduct } );

  @override
  Widget build( BuildContext context ) {

    return Padding(
      padding: EdgeInsets.only( right: 24.0 ),
      child: SizedBox(
        width: ResponsiveApp.dHeight( 112.0 ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              clipBehavior: Clip.antiAlias,
              height: ResponsiveApp.dHeight( 112.0 ),
              width: ResponsiveApp.dHeight( 112.0 ),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular( 16.0 ),
                image: const DecorationImage(
                  image: AssetImage( 'assets/images/placeholder.png' ),
                  fit: BoxFit.cover
                )
              ),
              child: FadeInImage(
                fit: BoxFit.cover,
                placeholder: const AssetImage( 'assets/images/placeholder.png' ),
                imageErrorBuilder: (context, error, stackTrace) => Image.asset( 'assets/images/placeholder.png', fit: BoxFit.cover ),
                image: NetworkImage( oProduct.sImage ?? '' )
              )
            ),
            SizedBox( height: ResponsiveApp.dHeight( 4.0 ) ),
            PoppinsText(
              sText: '\$${ oProduct.dPrice!.toInt().toString() }',
              dFontSize: ResponsiveApp.dSize( 14.0 ),
              colorText: ColorsApp.secondaryColor,
              fontWeight: FontWeight.bold
            ),
            SizedBox( height: ResponsiveApp.dHeight( 4.0 ) ),
            PoppinsText(
              sText: oProduct.sName!,
              dFontSize: ResponsiveApp.dSize( 13.0 ),
              colorText: ColorsApp.secondaryColor,
              iMaxLines: 2,
              fontWeight: FontWeight.w500
            ),
            SizedBox( height: ResponsiveApp.dHeight( 2.0 ) ),
            PoppinsText(
              sText: '${ oProduct.dQuantity!.toInt().toString() } ${ TextsUtil.of(context)?.getText( oProduct.dQuantity! == 1 ? 'new_order.availabe' : 'new_order.availabes' ) }',
              dFontSize: ResponsiveApp.dSize( 12.0 ),
              colorText: ColorsApp.textColor
            )
          ]
        ),
      ),
    );
  
  }

}