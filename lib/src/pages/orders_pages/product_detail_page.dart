import 'package:flutter/material.dart';
import 'package:medisupply_app/src/widgets/general_widgets/main_button.dart';

import '../../classes/product.dart';

import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import '../../utils/texts_util.dart';
import '../../widgets/general_widgets/poppins_text.dart';

class ProductDetailPage extends StatefulWidget {

  final Product oProduct;

  const ProductDetailPage( { super.key, required this.oProduct } );

  @override
  State<ProductDetailPage> createState() => _ProductDetailPageState();

}

class _ProductDetailPageState extends State<ProductDetailPage> {

  double dQuantity = 1.0;

  decreaseWQuantity() {
    if ( dQuantity > 1 ) {
      setState( () => dQuantity-- );
    }
  }

  increaseQuantity() {
    if ( dQuantity < widget.oProduct.dQuantity! ) {
      setState( () => dQuantity++ );
    }
  }

  @override
  Widget build( BuildContext context ) {

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
                    image: NetworkImage(widget.oProduct.sImage ?? ''),
                    imageErrorBuilder: (context, error, stackTrace) => Image.asset('assets/images/placeholder.png'),
                    width: ResponsiveApp.dWidth( 312.0 ),
                    height: ResponsiveApp.dWidth( 312.0 ),
                    fit: BoxFit.cover
                  )
                ),
                SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
                PoppinsText(
                  sText: '\$${ TextsUtil.of(context)?.formatNumber( widget.oProduct.dPrice!.toInt() ) }',
                  dFontSize: ResponsiveApp.dSize( 16.0 ),
                  colorText: ColorsApp.secondaryColor,
                  fontWeight: FontWeight.bold
                ),
                SizedBox( height: ResponsiveApp.dHeight( 8.0 ) ),
                PoppinsText(
                  sText: widget.oProduct.sName!,
                  dFontSize: ResponsiveApp.dSize( 24.0 ),
                  colorText: ColorsApp.secondaryColor,
                  iMaxLines: 5
                ),
                SizedBox( height: ResponsiveApp.dHeight( 4.0 ) ),
                PoppinsText(
                  sText: '${TextsUtil.of(context)?.getText( 'new_order.expiry' )} ${TextsUtil.of(context)?.formatLocalizedDate(context, '21/10/2025')}',
                  dFontSize: ResponsiveApp.dSize( 12.0 ),
                  colorText: ColorsApp.secondaryColor,
                  fontWeight: FontWeight.w500
                ),
                SizedBox( height: ResponsiveApp.dHeight( 16.0 ) ),
                PoppinsText(
                  sText: 'REGISTRO INVIMA: MH2019-0000784-R1 RX - Este producto requiere fórmula médica. Productos de prescripción Médica. Por su seguridad NO se automedique. Este producto es un medicamento. No exceder su consumo. Leer indicaciones y contraindicaciones. Si los síntomas persisten, consultar al médico.',
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
                Container(
                  width: ResponsiveApp.dWidth( 128.0 ),
                  height: ResponsiveApp.dHeight( 40.0 ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular( 12.0 ),
                    border: Border.all( color: ColorsApp.secondaryColor )
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        onPressed: dQuantity > 1 ? decreaseWQuantity : null,
                        icon: Icon(
                          Icons.remove,
                          color: dQuantity > 1 ? ColorsApp.secondaryColor : ColorsApp.borderColor,
                          semanticLabel: 'Decrease Quantity',
                        )
                      ),
                      SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
                      PoppinsText(
                        sText: dQuantity.toInt().toString(),
                        dFontSize: ResponsiveApp.dSize( 16.0 ),
                        colorText: ColorsApp.secondaryColor,
                        fontWeight: FontWeight.bold
                      ),
                      SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
                      IconButton(
                        onPressed: dQuantity < widget.oProduct.dQuantity! ? increaseQuantity : null,
                        icon: Icon(
                          Icons.add,
                          color: dQuantity < widget.oProduct.dQuantity! ? ColorsApp.secondaryColor : ColorsApp.borderColor,
                          semanticLabel: 'Increase Quantity',
                        )
                      )
                    ]
                  )
                ),
                SizedBox(
                  width: ResponsiveApp.dWidth( 128.0 ),
                  height: ResponsiveApp.dHeight( 40.0 ),
                  child: MainButton(
                    sLabel: TextsUtil.of(context)?.getText( 'new_order.add_button' ) ?? 'Add to Cart',
                    onPressed: (){}
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