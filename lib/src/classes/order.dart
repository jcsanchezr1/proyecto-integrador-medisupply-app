class Order {

  int? iId;
  String? sOrderNumber;
  String? sClientId;
  String? sVendorId;
  String? sStatus;
  String? sDeliveryDate;
  String? sAssignedTruck;
  String? sCreatedAt;
  String? sUpdatedAt;

  Order(
    {
      this.iId,
      this.sOrderNumber,
      this.sClientId,
      this.sVendorId,
      this.sStatus,
      this.sDeliveryDate,
      this.sAssignedTruck,
      this.sCreatedAt,
      this.sUpdatedAt
    }
  );

  factory Order.fromJson( Map<String, dynamic> json ) => Order(
    iId: json['id'],
    sOrderNumber: json['order_number'],
    sClientId: json['client_id'],
    sVendorId: json['vendor_id'],
    sStatus: json['status'],
    sDeliveryDate: json['scheduled_delivery_date'],
    sAssignedTruck: json['assigned_truck'],
    sCreatedAt: json['created_at'],
    sUpdatedAt: json['updated_at']
  );

}