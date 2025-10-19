class User {

  final String? sAccessToken;
  final String? sRefreshToken;
  final String? sName;
  final String? sEmail;
  final String? sRole;

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
      sName: json['name'],
      sEmail: json['email'],
      sAccessToken: json['access_token'],
      sRefreshToken: json['refresh_token'],
      sRole: json['role']
    );

}