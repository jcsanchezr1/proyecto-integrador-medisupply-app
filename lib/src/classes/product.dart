class Product {

  final String? sName;
  final String? sImage;
  final double? dPrice;
  final String? sDescription;
  final double? sDate;

  double dQuantity;

  Product(
    {
      this.sName,
      this.sImage,
      this.dQuantity = 0.0,
      this.dPrice,
      this.sDescription,
      this.sDate
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