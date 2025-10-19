import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/order.dart';

import '../../providers/login_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/texts_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/responsive_app.dart';
import '../../utils/slide_transition.dart';

import '../../widgets/oder_widgets/order_card.dart';
import '../../widgets/general_widgets/poppins_text.dart';

import 'new_order_page.dart';

class OrdersPage extends StatefulWidget {

  const OrdersPage( { super.key, this.fetchData } );

  final FetchData? fetchData;

  @override
  State<OrdersPage> createState() => _OrdersPageState();

}

class _OrdersPageState extends State<OrdersPage> {

  List<Order> lOrders = [];
  bool bIsLoading = true;

  getOrdersByRol() async {

    final oFetchData = widget.fetchData ?? FetchData();
    final loginProvider = Provider.of<LoginProvider>(context, listen: false);

    try {
      lOrders = await oFetchData.getOrders(
        loginProvider.oUser!.sAccessToken!,
        loginProvider.oUser!.sId!,
        loginProvider.oUser!.sRole!
      );
    } catch (e) {
      lOrders = [];
    }

    if (mounted) {
      setState( () => bIsLoading = false );
    }

  }

  @override
  void initState() {
    super.initState();
    getOrdersByRol();
  }

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
      body: bIsLoading ? Center(
        child: CircularProgressIndicator( color: ColorsApp.primaryColor )
      ) : lOrders.isEmpty ? Center(
        child: PoppinsText(
          sText: TextsUtil.of(context)?.getText( 'orders.no_orders' ) ?? 'No Products Available',
          dFontSize: ResponsiveApp.dSize( 16.0 ),
          colorText: ColorsApp.textColor
        )
      ): ListView.builder(
        itemCount: lOrders.length,
        itemBuilder: ( context, index ) => OrderCard( oOrder: lOrders[index] )
      )
    );

  }
}