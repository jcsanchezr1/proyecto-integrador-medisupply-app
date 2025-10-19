import 'package:flutter/material.dart';

import '../../utils/colors_app.dart';
import '../../utils/slide_transition.dart';

import 'new_order_page.dart';

class OrdersPage extends StatelessWidget {

  const OrdersPage( { super.key } );

  @override
  Widget build( BuildContext context ) {

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: ColorsApp.backgroundColor,
        onPressed: () => Navigator.push( context, SlidePageRoute( page: NewOrderPage() ) ),
        child: const Icon(
          Icons.add_rounded,
          color: ColorsApp.primaryColor,
          semanticLabel: 'Add Order'
        )
      ),
      body: Center(
        child: Text( 'Orders Page' )
      )
    );

  }

}