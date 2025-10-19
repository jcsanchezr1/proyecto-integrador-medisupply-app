import 'package:flutter/material.dart';

import 'package:provider/provider.dart';

import '../../classes/products_group.dart';

import '../../providers/login_provider.dart';
import '../../services/fetch_data.dart';

import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/new_order_widgets/product_card.dart';

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
      lProductsGroups = await oFetchData.getProductsbyProvider( loginPrvovider.oUser!.sAccessToken! );
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
            padding: EdgeInsets.only( right: ResponsiveApp.dWidth( 8.0 ) ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: ColorsApp.secondaryColor,
                semanticLabel: 'Shopping Cart'
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
                      height: ResponsiveApp.dHeight( 180.0 ),
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