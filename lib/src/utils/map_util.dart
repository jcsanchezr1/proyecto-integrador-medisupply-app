import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapUtil {

  LatLngBounds getBoundsFromMarkersAndPolylines( Set<Marker> markers, List<LatLng> polylinePoints ) {
    
    double? minLat, maxLat, minLng, maxLng;

    for (var marker in markers) {
      final lat = marker.position.latitude;
      final lng = marker.position.longitude;

      minLat = (minLat == null) ? lat : (lat < minLat ? lat : minLat);
      maxLat = (maxLat == null) ? lat : (lat > maxLat ? lat : maxLat);
      minLng = (minLng == null) ? lng : (lng < minLng ? lng : minLng);
      maxLng = (maxLng == null) ? lng : (lng > maxLng ? lng : maxLng);
    }

    for (var point in polylinePoints) {
      final lat = point.latitude;
      final lng = point.longitude;

      minLat = (minLat == null) ? lat : (lat < minLat ? lat : minLat);
      maxLat = (maxLat == null) ? lat : (lat > maxLat ? lat : maxLat);
      minLng = (minLng == null) ? lng : (lng < minLng ? lng : minLng);
      maxLng = (maxLng == null) ? lng : (lng > maxLng ? lng : maxLng);
    }

    return LatLngBounds(
      southwest: LatLng(minLat!, minLng!),
      northeast: LatLng(maxLat!, maxLng!),
    );
  }

}