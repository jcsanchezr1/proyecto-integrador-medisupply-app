import 'dart:io';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:medisupply_app/src/classes/products_group.dart';

import '../classes/user.dart';

import 'package:http/http.dart' as http;

class FetchData {

  final baseUrl = 'https://medisupply-gateway-gw-d7fde8rj.uc.gateway.dev';
  //final baseUrl = 'http://192.168.18.23:8082';
  final baseUrlMaps = 'https://maps.googleapis.com/maps/api/geocode/json?address=';

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

  Future<bool> logout( String sRefreshToken ) async {
    
    bool bSuccess = false;
    
    final response = await client.post(
      Uri.parse( '$baseUrl/auth/logout' ),
      body: {
        'refresh_token' : sRefreshToken
      }
    );

    if( response.statusCode == 204 ) {
      bSuccess = true;
    }

    return bSuccess;

  }

  Future<Map<String, dynamic>> getCoordinates( String sAddress ) async {

    Map<String, dynamic> mCoordinates = {};

    await dotenv.load(fileName: ".env");

    final encodedAddress = Uri.encodeComponent('$sAddress, Bogotá Colombia');

    final response = await client.get(
      Uri.parse( '$baseUrlMaps$encodedAddress&key=${dotenv.env['API_KEY_MAPS']}' ),
    );

    if( response.statusCode == 200 ) {

      final mResponse = jsonDecode( utf8.decode( response.bodyBytes ) );

      if( mResponse['results'].isNotEmpty && mResponse['results'][0]['formatted_address'] != "Bogotá, Bogota, Colombia" ) {
        mCoordinates = mResponse['results'][0]['geometry']['location'];
      }

    }

    return mCoordinates;

  }

  Future<bool> createAccount( {
    required String sName,
    required String sTaxId,
    required String sEmail,
    required String sAddress,
    required String sPhone,
    required String sInstitutionType,
    required File logoFile,
    required String sSpecialty,
    required String sApplicatName,
    required String sApplicatEmail,
    required double dLatitude,
    required double dLongitude,
    required String sPassword,
    required String sPasswordConfirmation
  } ) async {

    bool bSuccess = false;

    final request = http.MultipartRequest(
      'POST',
      Uri.parse( '$baseUrl/auth/user' ),
    );

    request.fields.addAll( {
      'name' : sName,
      'tax_id' : sTaxId,
      'email' : sEmail,
      'address' : sAddress,
      'phone' : sPhone,
      'institution_type' : sInstitutionType,
      'specialty' : sSpecialty,
      'applicant_name' : sApplicatName,
      'applicant_email' : sApplicatEmail,
      'latitude' : dLatitude.toString(),
      'longitude' : dLongitude.toString(),
      'password' : sPassword,
      'confirm_password' : sPasswordConfirmation
    } );

    request.files.add( await http.MultipartFile.fromPath(
      'logo',
      logoFile.path
    ) );

    final response = await client.send( request );

    if( response.statusCode == 201 ) {
      bSuccess = true;
    }

    return bSuccess;

  }

  Future<List<ProductsGroup>> getProductsbyProvider( String sAccessToken ) async {

    List<ProductsGroup> lProductsGroups = [];

    final response = await client.get(
      Uri.parse( '$baseUrl/inventory/providers/products' ),
      headers: {
        'Authorization' : 'Bearer $sAccessToken'
      }
    );

    if( response.statusCode == 200 ) {

      final mResponse = jsonDecode( utf8.decode( response.bodyBytes ) );

      for( var mProduct in mResponse['data']['groups'] ) {
        lProductsGroups.add( ProductsGroup.fromJson( mProduct ) );
      }

    }

    return lProductsGroups;
    
  }

}