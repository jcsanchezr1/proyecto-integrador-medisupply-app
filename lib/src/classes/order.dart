import 'package:medisupply_app/src/classes/product.dart';

class Order {

  int? iId;
  String? sOrderNumber;
  String? sClientId;
  String? sVendorId;
  String? sStatus;
  double? dTotalAmount;
  String? sDeliveryDate;
  String? sAssignedTruck;
  String? sCreatedAt;
  String? sUpdatedAt;
  List<Product>? lProducts;

  Order(
    {
      this.iId,
      this.sOrderNumber,
      this.sClientId,
      this.sVendorId,
      this.sStatus,
      this.dTotalAmount,
      this.sDeliveryDate,
      this.sAssignedTruck,
      this.sCreatedAt,
      this.sUpdatedAt,
      this.lProducts
    }
  );

  factory Order.fromJson( Map<String, dynamic> json ) {

    List<Product> lOrderProducts = [];

    if ( json['items'] != null && json['items'].isNotEmpty ) {
      json['items'].forEach( ( product ) {
        lOrderProducts.add( Product.fromOrderJson( product ) );
      } );
    }

    return Order(
      iId: json['id'],
      sOrderNumber: json['order_number'],
      sClientId: json['client_id'],
      sVendorId: json['vendor_id'],
      sStatus: json['status'],
      dTotalAmount: json['total_amount'],
      sDeliveryDate: json['scheduled_delivery_date'],
      sAssignedTruck: json['assigned_truck'],
      sCreatedAt: json['created_at'],
      sUpdatedAt: json['updated_at'],
      lProducts: lOrderProducts
    );

  }

}