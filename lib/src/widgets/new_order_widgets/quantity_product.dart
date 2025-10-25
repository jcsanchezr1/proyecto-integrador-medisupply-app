import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../providers/order_provider.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';

import '../general_widgets/poppins_text.dart';

class QuantityProduct extends StatefulWidget {

  final double dQuantity;

  const QuantityProduct( { super.key, required this.dQuantity } );

  @override
  State<QuantityProduct> createState() => _QuantityProductState();

}

class _QuantityProductState extends State<QuantityProduct> {

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>(context);

    return Container(
      height: ResponsiveApp.dHeight( 50.0 ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular( 12.0 ),
        border: Border.all( color: ColorsApp.secondaryColor )
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            onPressed: orderProvider.dQuantity > 1 ? orderProvider.decreaseQuantity : null,
            icon: Icon(
              Icons.remove,
              color: orderProvider.dQuantity > 1 ? ColorsApp.secondaryColor : ColorsApp.borderColor,
              semanticLabel: 'Decrease Quantity'
            )
          ),
          SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
          PoppinsText(
            sText: orderProvider.dQuantity.toInt().toString(),
            dFontSize: ResponsiveApp.dSize( 16.0 ),
            colorText: ColorsApp.secondaryColor,
            fontWeight: FontWeight.bold
          ),
          SizedBox( width: ResponsiveApp.dWidth( 8.0 ) ),
          IconButton(
            onPressed: orderProvider.dQuantity < widget.dQuantity ? orderProvider.increaseQuantity : null,
            icon: Icon(
              Icons.add,
              color: orderProvider.dQuantity < widget.dQuantity ? ColorsApp.secondaryColor : ColorsApp.borderColor,
              semanticLabel: 'Increase Quantity'
            )
          )
        ]
      )
    );

  }
}