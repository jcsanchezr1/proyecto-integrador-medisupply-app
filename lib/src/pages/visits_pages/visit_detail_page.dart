import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../classes/client.dart';
import '../../classes/visit.dart';
import '../../classes/visit_detail.dart';

import '../../providers/login_provider.dart';
import '../../services/fetch_data.dart';

import '../../utils/map_util.dart';
import '../../utils/colors_app.dart';
import '../../utils/texts_util.dart';
import '../../utils/responsive_app.dart';

import '../../widgets/general_widgets/poppins_text.dart';
import '../../widgets/general_widgets/snackbar_widget.dart';
import '../../widgets/visits_widgets/create_visit_form.dart';

class VisitDetailPage extends StatefulWidget {

  final Visit oVisit;
  final FetchData? fetchData; // For testing
  
  const VisitDetailPage(
    {
      super.key,
      required this.oVisit,
      this.fetchData
    }
  );

  @override
  State<VisitDetailPage> createState() => _VisitDetailPageState();

}

class _VisitDetailPageState extends State<VisitDetailPage> {

  late GoogleMapController _mapController;
  late final FetchData oFetchData;

  bool bLoading = true;
  VisitDetail oVisitDetail = VisitDetail();
  
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};

  final CameraPosition _initialPosition = const CameraPosition(
    target: LatLng(4.7110, -74.0721), 
    zoom: 14
  );

  void moveCameraToFitMarkers(Set<Marker> markers, List<LatLng> polylinePoints) async {

    if ( markers.isEmpty ) return;

    final bounds = MapUtil().getBoundsFromMarkersAndPolylines(markers, polylinePoints);
    final cameraUpdate = CameraUpdate.newLatLngBounds(bounds, 50);

    await _mapController.animateCamera(cameraUpdate);

  }

  getRoute() async {

    final loginProvider = Provider.of<LoginProvider>( context, listen: false );

    oVisitDetail = await oFetchData.getVisitDetail(
      loginProvider.oUser!.sAccessToken!,
      loginProvider.oUser!.sId!,
      widget.oVisit.sId
    );

    if( oVisitDetail.sId == null ) {
      if( !mounted ) return;
      ScaffoldMessenger.of(context).showSnackBar(
        snackBarWidget( sMessage: (TextsUtil.of(context) ?? Provider.of<TextsUtil>(context, listen: false)).getText( 'visit_detail.error' ) ),
      );
      setState( () => bLoading = false );
      return;
    }

    await createMarkers( oVisitDetail.lClients! );

    final routePoints = await oFetchData.getRoute( oVisitDetail.lClients! );

    await drawPolyline(routePoints);

    setState( () => bLoading = false );

  }

  createMarkers( List<Client> lClients ) async {
    
    _markers.clear();

    _markers.add(
      Marker(
        markerId: const MarkerId('start_end'),
        position: const LatLng(4.693549628123178, -74.10477902136584),
        infoWindow: const InfoWindow(title: 'Inicio/Fin'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      )
    );

    for (var oClient in lClients) {
      _markers.add(
        Marker(
          markerId: MarkerId( oClient.sClientId! ),
          position: LatLng( oClient.dLatitude!, oClient.dLongitude! ),
          onTap: () => _showClientBottomSheet(oClient)
        )
      );
    }
  }

  drawPolyline( List<LatLng> lPoints ) async {

    _polylines.clear();

    _polylines.add(
      Polyline(
        polylineId: const PolylineId('route'),
        points: lPoints,
        color: ColorsApp.primaryColor,
        width: 4
      )
    );
    
  }

  _showClientBottomSheet(Client oClient) {

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => CreateVisitForm(
        oClient: oClient,
        sVisitId: widget.oVisit.sId
      )
    );

  }
  
  @override
  void initState() {
    super.initState();
    oFetchData = widget.fetchData ?? FetchData();
    getRoute();
  }

  @override
  Widget build( BuildContext context ) {

    return Scaffold(
      key: const Key('visit_detail_page'),
      appBar: AppBar(
        title: PoppinsText(
          sText: (TextsUtil.of(context) ?? Provider.of<TextsUtil>(context, listen: false)).formatLocalizedDate(
            context,
            DateFormat( "yyyy-MM-dd" ).format( DateFormat( "dd-MM-yyyy" ).parse( widget.oVisit.sDate ) )
          ),
          dFontSize: ResponsiveApp.dSize( 20.0 ),
          colorText: ColorsApp.secondaryColor,
          fontWeight: FontWeight.w500
        )
      ),
      body: bLoading ? const Center(
        child: CircularProgressIndicator()
      ) : GoogleMap(
        initialCameraPosition: _initialPosition,
        onMapCreated: (controller) {
          _mapController = controller;
          moveCameraToFitMarkers(_markers, _polylines.first.points.toList());
        },
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: false,
        markers: _markers,
        polylines: _polylines
      )
    );

  }
}