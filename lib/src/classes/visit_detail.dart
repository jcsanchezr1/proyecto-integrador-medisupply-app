import 'client.dart';

class VisitDetail {

  final String? sDate;
  final String? sId;
  final String? sSellerId;
  
  final List<Client>? lClients;

  VisitDetail(
    {
      this.sDate,
      this.sId,
      this.sSellerId,
      this.lClients,
    }
  );

  factory VisitDetail.fromJson( Map<String, dynamic> json ) {

    List<Client> lClients = [];
    
    if ( json['clients'] != null ) {
      json['clients'].forEach( ( client ) {
        lClients.add( Client.fromJson( client ) );
      } );
    }

    return VisitDetail(
      sDate: json['date'],
      sId: json['id'],
      sSellerId: json['sellerId'],
      lClients: lClients
    );
  }

}