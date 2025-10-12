import 'dart:convert';

import '../classes/user.dart';

import 'package:http/http.dart' as http;

class FetchData {

  final baseUrl = 'https://medisupply-gateway-gw-d7fde8rj.uc.gateway.dev';

  final http.Client client;

  FetchData( { http.Client? client } ) : client = client ?? http.Client();

  FetchData.withClient(this.client);

  Future<User> login( String sEmail, String sPassword ) async {

    User oUser = User();

    final response = await client.post(
      Uri.parse( '$baseUrl/auth/token' ),
      body: {
        'user' : sEmail,
        'password' : sPassword
      }
    );

    if( response.statusCode == 200 ) {

      final mResponse = jsonDecode( utf8.decode( response.bodyBytes ) );

      oUser = User.fromJson( mResponse );

    }

    return oUser;

  }

}