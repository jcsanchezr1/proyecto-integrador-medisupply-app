class Client {
  
  final String? sClientId;
  final String? sName;
  final String? sTaxId;
  final String? sEmail;
  final String? sAddress;
  final String? sPhone;
  final String? sInstitutionType;
  final String? sLogoName;
  final String? sLogoUrl;
  final String? sSpeciality;
  final String? sApplicantName;
  final String? sApplicantEmail;
  final bool? bEnabled;

  Client(
    {
      this.sClientId,
      this.sName,
      this.sTaxId,
      this.sEmail,
      this.sAddress,
      this.sPhone,
      this.sInstitutionType,
      this.sLogoName,
      this.sLogoUrl,
      this.sSpeciality,
      this.sApplicantName,
      this.sApplicantEmail,
      this.bEnabled
    }
  );

  factory Client.fromJson( Map<String, dynamic > json )
    => Client(
      sClientId: json['id'],
      sName: json['name'],
      sTaxId: json['tax_id'],
      sEmail: json ['email'],
      sAddress: json['address'],
      sPhone: json['phone'],
      sInstitutionType: json['institution_type'],
      sLogoName: json['logo_filename'],
      sLogoUrl: json['logo_url'],
      sSpeciality: json['specialty'],
      sApplicantName: json['applicant_name'], 
      sApplicantEmail: json['applicant_email'],
      bEnabled: json['enabled']
    );

}