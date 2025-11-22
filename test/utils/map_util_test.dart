import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:medisupply_app/src/utils/map_util.dart';

void main() {
  late MapUtil mapUtil;

  setUp(() {
    mapUtil = MapUtil();
  });

  group('MapUtil', () {
    group('getBoundsFromMarkersAndPolylines', () {
      test('returns correct bounds for single marker', () {
        final markers = {
          const Marker(
            markerId: MarkerId('test'),
            position: LatLng(10.0, 20.0),
          ),
        };
        final polylinePoints = <LatLng>[];

        final bounds = mapUtil.getBoundsFromMarkersAndPolylines(markers, polylinePoints);

        expect(bounds.southwest.latitude, equals(10.0));
        expect(bounds.southwest.longitude, equals(20.0));
        expect(bounds.northeast.latitude, equals(10.0));
        expect(bounds.northeast.longitude, equals(20.0));
      });

      test('returns correct bounds for multiple markers', () {
        final markers = {
          const Marker(
            markerId: MarkerId('marker1'),
            position: LatLng(10.0, 20.0),
          ),
          const Marker(
            markerId: MarkerId('marker2'),
            position: LatLng(15.0, 25.0),
          ),
        };
        final polylinePoints = <LatLng>[];

        final bounds = mapUtil.getBoundsFromMarkersAndPolylines(markers, polylinePoints);

        expect(bounds.southwest.latitude, equals(10.0));
        expect(bounds.southwest.longitude, equals(20.0));
        expect(bounds.northeast.latitude, equals(15.0));
        expect(bounds.northeast.longitude, equals(25.0));
      });

      test('includes polyline points in bounds calculation', () {
        final markers = {
          const Marker(
            markerId: MarkerId('marker1'),
            position: LatLng(10.0, 20.0),
          ),
        };
        final polylinePoints = [
          const LatLng(5.0, 15.0),
          const LatLng(12.0, 30.0),
        ];

        final bounds = mapUtil.getBoundsFromMarkersAndPolylines(markers, polylinePoints);

        expect(bounds.southwest.latitude, equals(5.0));
        expect(bounds.southwest.longitude, equals(15.0));
        expect(bounds.northeast.latitude, equals(12.0));
        expect(bounds.northeast.longitude, equals(30.0));
      });

      test('handles empty markers and polyline points', () {
        final markers = <Marker>{};
        final polylinePoints = <LatLng>[];

        // The method assumes at least one marker exists, so it should throw
        expect(
          () => mapUtil.getBoundsFromMarkersAndPolylines(markers, polylinePoints),
          throwsA(isA<TypeError>()),
        );
      });

      test('correctly calculates bounds with mixed markers and polylines', () {
        final markers = {
          const Marker(
            markerId: MarkerId('marker1'),
            position: LatLng(10.0, 20.0),
          ),
          const Marker(
            markerId: MarkerId('marker2'),
            position: LatLng(15.0, 25.0),
          ),
        };
        final polylinePoints = [
          const LatLng(8.0, 18.0),
          const LatLng(12.0, 22.0),
          const LatLng(17.0, 27.0),
        ];

        final bounds = mapUtil.getBoundsFromMarkersAndPolylines(markers, polylinePoints);

        expect(bounds.southwest.latitude, equals(8.0));
        expect(bounds.southwest.longitude, equals(18.0));
        expect(bounds.northeast.latitude, equals(17.0));
        expect(bounds.northeast.longitude, equals(27.0));
      });

      test('handles negative coordinates', () {
        final markers = {
          const Marker(
            markerId: MarkerId('marker1'),
            position: LatLng(-10.0, -20.0),
          ),
        };
        final polylinePoints = [
          const LatLng(-15.0, -25.0),
        ];

        final bounds = mapUtil.getBoundsFromMarkersAndPolylines(markers, polylinePoints);

        expect(bounds.southwest.latitude, equals(-15.0));
        expect(bounds.southwest.longitude, equals(-25.0));
        expect(bounds.northeast.latitude, equals(-10.0));
        expect(bounds.northeast.longitude, equals(-20.0));
      });
    });
  });
}