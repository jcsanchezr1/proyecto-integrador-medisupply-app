class Product {

  final int? iId;
  final String? sName;
  final String? sImage;
  final double? dPrice;
  final String? sDescription;
  final String? sExpirationDate;

  double dQuantity;

  Product(
    {
      this.iId,
      this.sName,
      this.sImage,
      this.dQuantity = 0.0,
      this.dPrice,
      this.sDescription,
      this.sExpirationDate
    }
  );

  factory Product.fromJson( Map<String, dynamic > json )
    => Product(
      iId: json['id'],
      sName: json['name'],
      sImage: json['photo_url'],
      dQuantity: json['quantity']?.toDouble(),
      dPrice: json['price']?.toDouble(),
      sExpirationDate: json['expiration_date'],
      sDescription: json['description']
    );

}