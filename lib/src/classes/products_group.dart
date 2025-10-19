import 'package:medisupply_app/src/classes/product.dart';

class ProductsGroup {

  final String? sProviderName;
  final List<Product>? lProducts;

  ProductsGroup(
    {
      this.sProviderName,
      this.lProducts
    }
  );

  factory ProductsGroup.fromJson( Map<String, dynamic > json )
    => ProductsGroup(
      sProviderName: json['provider'],
      lProducts: List<Product>.from( json['products'].map( ( x ) => Product.fromJson( x ) ) )
    );

}