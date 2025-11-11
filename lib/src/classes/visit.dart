class Visit {

  final String sId;
  final String sDate;
  final int iCountClients;

  Visit(
    {
      required this.sId,
      required this.sDate,
      required this.iCountClients
    }
  );

  factory Visit.fromJson( Map<String, dynamic> json ) => Visit(
    sId: json['id'],
    sDate: json['date'],
    iCountClients: json['count_clients']
  );

}