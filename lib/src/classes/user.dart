class User {

  final String? sAccessToken;
  final String? sRefreshToken;
  final String? sName;
  final String? sEmail;
  final String? sRole;
  final String? sId;

  User(
    {
      this.sName,
      this.sEmail,
      this.sAccessToken,
      this.sRefreshToken,
      this.sRole,
      this.sId
    }
  );

  factory User.fromJson( Map<String, dynamic> json )
    => User(
      sName: json['name'],
      sEmail: json['email'],
      sAccessToken: json['access_token'],
      sRefreshToken: json['refresh_token'],
      sRole: json['role'],
      sId: json['id']
    );

}