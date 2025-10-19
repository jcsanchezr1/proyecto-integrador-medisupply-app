class Product {

  final String? sName;
  final String? sImage;
  final double? dQuantity;
  final double? dPrice;

  Product(
    {
      this.sName,
      this.sImage,
      this.dQuantity,
      this.dPrice
    }
  );

  factory Product.fromJson( Map<String, dynamic > json )
    => Product(
      sName: json['name'],
      sImage: json['photo_url'],
      dQuantity: json['quantity']?.toDouble(),
      dPrice: json['price']?.toDouble()
    );

}