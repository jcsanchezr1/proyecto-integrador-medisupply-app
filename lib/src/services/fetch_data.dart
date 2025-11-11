import 'dart:io';
import 'dart:convert';

import 'package:flutter_dotenv/flutter_dotenv.dart';

import '../classes/user.dart';
import '../classes/visit.dart';
import '../classes/order.dart';
import '../classes/client.dart';
import '../classes/products_group.dart';

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

  Future<List<ProductsGroup>> getProductsbyProvider( String sAccessToken, String sUserId ) async {

    List<ProductsGroup> lProductsGroups = [];

    final response = await client.get(
      Uri.parse( '$baseUrl/inventory/providers/products?userId=$sUserId' ),
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

  Future<List<Order>> getOrders( String sAccessToken, String sUserId, String sRole ) async {

    List<Order> lOrders = [];

    final response = await client.get(
      Uri.parse(
        sRole == 'Ventas' ? '$baseUrl/orders?vendor_id=$sUserId' : '$baseUrl/orders?client_id=$sUserId'
      ),
      headers: {
        'Authorization' : 'Bearer $sAccessToken'
      }
    );

    if( response.statusCode == 200 ) {

      final mResponse = jsonDecode( utf8.decode( response.bodyBytes ) );


      for( var mOrder in mResponse['data'] ) {
        lOrders.add( Order.fromJson( mOrder ) );
      }

    }

    return lOrders;
    
  }

  Future<bool> createOrder( String sAccessToken, Map<String, dynamic> mOrder ) async {

    bool bSuccess = false;

    final response = await client.post(
      Uri.parse( '$baseUrl/orders/create' ),
      headers: {
        'Authorization' : 'Bearer $sAccessToken',
        'Content-Type' : 'application/json'
      },
      body: jsonEncode( mOrder )
    );

    if( response.statusCode == 201 ) {
      bSuccess = true;
    }

    return bSuccess;

  }

  Future<List<Client>> getAssignedClients( String sAccessToken, String sVendorId ) async {

    List<Client> lClients = [];

    final response = await client.get(
      Uri.parse( '$baseUrl/auth/assigned-clients/$sVendorId' ),
      headers: {
        'Authorization' : 'Bearer $sAccessToken'
      }
    );

    if( response.statusCode == 200 ) {

      final mResponse = jsonDecode( utf8.decode( response.bodyBytes ) );

      if( mResponse['data']['assigned_clients'] != null && mResponse['data']['assigned_clients'].isNotEmpty ){
        for( var mClient in mResponse['data']['assigned_clients'] ) {
          lClients.add( Client.fromJson( mClient ) );
        }
      }

    }

    return lClients;
    
  }

  Future<List<Visit>> getVisitsByDate( String sAccessToken, String sUserId, String sDate ) async {

    List<Visit> lVisits = [];

    final response = await client.get(
      Uri.parse( '$baseUrl/sellers/$sUserId/scheduled-visits?date=$sDate' ),
      headers: {
        'Authorization' : 'Bearer $sAccessToken'
      }
    );

    if( response.statusCode == 200 ) {

      final mResponse = jsonDecode( utf8.decode( response.bodyBytes ) );

      for( var mVisit in mResponse['data'] ) {
        lVisits.add( Visit.fromJson( mVisit ) );
      }

    }

    return lVisits;
    
  }

}