class User {

  final String? sAccessToken;
  final String? sRefreshToken;
  
  String? sName;
  String? sEmail;
  String? sRole;

  User(
    {
      this.sName,
      this.sEmail,
      this.sAccessToken,
      this.sRefreshToken,
      this.sRole
    }
  );

  factory User.fromJson( Map<String, dynamic> json )
    => User(
      sAccessToken: json['access_token'],
      sRefreshToken: json['refresh_token']
    );

}