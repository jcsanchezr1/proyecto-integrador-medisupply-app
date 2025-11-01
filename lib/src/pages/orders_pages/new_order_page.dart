import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/products_group.dart';

import '../../providers/login_provider.dart';
import '../../providers/order_provider.dart';

import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/slide_transition.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/new_order_widgets/product_card.dart';
import 'order_summary_page.dart';

class NewOrderPage extends StatefulWidget {

  const NewOrderPage( { super.key = const Key('new_order_page'), this.fetchData } );

  final FetchData? fetchData;

  @override
  State<NewOrderPage> createState() => _NewOrderPageState();

}

class _NewOrderPageState extends State<NewOrderPage> {

  bool bIsLoading = true;
  List<ProductsGroup> lProductsGroups = [];

  Future<void> getProductsbyProvider() async {

    final loginPrvovider = Provider.of<LoginProvider>(context, listen: false);

    final oFetchData = widget.fetchData ?? FetchData();

    try {
      lProductsGroups = await oFetchData.getProductsbyProvider( loginPrvovider.oUser!.sAccessToken!, loginPrvovider.oUser!.sId! );
    } catch (e) {
      lProductsGroups = [];
    }

    setState( () => bIsLoading = false );

  }

  @override
  void initState() {
    getProductsbyProvider();
    super.initState();
  }

  @override
  Widget build( BuildContext context ) {

    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: PoppinsText(
          sText: TextsUtil.of(context)?.getText( 'new_order.title' ) ?? 'New Order',
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor,
          fontWeight: FontWeight.w500
        ),
        actions: [
          Padding(
            padding: EdgeInsets.only(
              right: ResponsiveApp.dWidth( 12.0 ),
              top: ResponsiveApp.dHeight( 8.0 )
            ),
            child: IconButton(
              onPressed: orderProvider.lOrderProducts.isNotEmpty ? () => Navigator.push( context, SlidePageRoute(page: OrderSummaryPage()) ) : null,
              icon: Stack(
                clipBehavior: Clip.none,
                children: [
                  Icon(
                    Icons.shopping_cart_outlined,
                    color: ColorsApp.secondaryColor,
                    semanticLabel: 'Shopping Cart'
                  ),
                  orderProvider.lOrderProducts.isNotEmpty ? Positioned(
                    right: -10.0,
                    top: -10.0,
                    child: Container(
                      alignment: Alignment.center,
                      width: ResponsiveApp.dWidth( 20.0 ),
                      height: ResponsiveApp.dWidth( 20.0 ),
                      decoration: BoxDecoration(
                        color: ColorsApp.primaryColor,
                        borderRadius: BorderRadius.circular( 12.0 )
                      ),
                      child: PoppinsText(
                        sText: orderProvider.lOrderProducts.length.toString(),
                        dFontSize: ResponsiveApp.dSize( 11.0 ),
                        colorText: ColorsApp.backgroundColor,
                        fontWeight: FontWeight.w600,
                        textAlign: TextAlign.center
                      )
                    )
                  ) : SizedBox()
                ]
              )
            )
          )
        ],
        backgroundColor: ColorsApp.backgroundColor,
        elevation: 0.0
      ),
      body: bIsLoading ? Center(
        child: CircularProgressIndicator( color: ColorsApp.primaryColor )
      ) : lProductsGroups.isEmpty ? Center(
        child: PoppinsText(
          sText: TextsUtil.of(context)?.getText( 'new_order.empty_state' ) ?? 'No Products Available',
          dFontSize: ResponsiveApp.dSize( 16.0 ),
          colorText: ColorsApp.textColor
        )
      ) : Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.symmetric(
                horizontal: ResponsiveApp.dWidth( 16.0 ),
                vertical: ResponsiveApp.dHeight( 16.0 )
              ),
              itemCount: lProductsGroups.length,
              itemBuilder: (context, index) => Padding(
                padding: EdgeInsets.only( bottom: ResponsiveApp.dHeight( 32.0 ) ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    PoppinsText(
                      sText: lProductsGroups[index].sProviderName!,
                      dFontSize: ResponsiveApp.dSize( 20.0 ),
                      colorText: ColorsApp.secondaryColor,
                      fontWeight: FontWeight.w500
                    ),
                    SizedBox( height: ResponsiveApp.dHeight( 24.0 ) ),
                    SizedBox(
                      height: ResponsiveApp.dHeight( 188.0 ),
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: lProductsGroups[index].lProducts!.length,
                        itemBuilder: (context, inIndex) => ProductCard( oProduct: lProductsGroups[index].lProducts![ inIndex ] )
                      )
                    )
                  ]
                )
              )
            )
          )
        ]
      )
    );
  
  }
}