import 'dart:async';
import 'dart:math' show Random, asin, cos, pi, sin, sqrt;

import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:latlng/latlng.dart';
import 'package:location/location.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  MapController controller = MapController.withPosition(
    initPosition: GeoPoint(
      latitude: 47.4358055,
      longitude: 8.4737324,
    ),
    // Limit the map area to Switzerland
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  Location _location = Location();
  List<LatLng> _points = [];

  @override
  void initState() {
    super.initState();
    _startLocationTracking();
  }

  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

    double offset = 0.0001; // 10 meters of randomness
    double lat = 47.4358055; // starting coordinates
    double lng = 8.4737324;
    LatLng lastPoint = LatLng(lat, lng);

    Timer.periodic(Duration(seconds: 1), (timer) async {
      // Apply a random offset to the latitude and longitude
      double latOffset = Random().nextDouble() * offset * 2 - offset;
      double lngOffset = Random().nextDouble() * offset * 2 - offset;
      lat += latOffset;
      lng += lngOffset;
      double distance(LatLng p1, LatLng p2) {
        const nauticalMile = 1852;
        const radius = 6371 * nauticalMile;
        final lat1 = p1.latitude, lon1 = p1.longitude;
        final lat2 = p2.latitude, lon2 = p2.longitude;
        final dLat = (lat2 - lat1) * (pi / 180);
        final dLon = (lon2 - lon1) * (pi / 180);
        final a = sin(dLat / 2) * sin(dLat / 2) +
            cos(lat1 * (pi / 180)) *
                cos(lat2 * (pi / 180)) *
                sin(dLon / 2) *
                sin(dLon / 2);
        final c = 2 * asin(sqrt(a));
        return radius * c;
      }

      LatLng currentPoint = LatLng(lat, lng);
      if (_points.isEmpty || distance(lastPoint, currentPoint) >= 5) {
        setState(() {
          // Add the user's location to the points list if it's at least 5 meters away
          // from the previous point
          _points.add(currentPoint);
        });
        lastPoint = currentPoint;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Track My Walk',
      home: Scaffold(
        appBar: AppBar(
          title: Text('Track My Walk'),
        ),
        body: Center(
          child: OSMFlutter(
            controller: controller,
            trackMyPosition: false,
            initZoom: 12,
            minZoomLevel: 8,
            maxZoomLevel: 14,
            stepZoom: 1.0,
            userLocationMarker: UserLocationMaker(
              personMarker: const MarkerIcon(
                icon: Icon(
                  Icons.location_history_rounded,
                  color: Colors.red,
                  size: 48,
                ),
              ),
              directionArrowMarker: const MarkerIcon(
                icon: Icon(
                  Icons.double_arrow,
                  size: 48,
                ),
              ),
            ),
            roadConfiguration: const RoadOption(
              roadColor: Colors.yellowAccent,
            ),
            markerOption: MarkerOption(
                defaultMarker: const MarkerIcon(
              icon: Icon(
                Icons.person_pin_circle,
                color: Colors.blue,
                size: 56,
              ),
            )),
          ),
        ),
      ),
    );
  }
}









/** controller.changeLocation(GeoPoint(
            latitude: locationData.latitude!,
            longitude: locationData.longitude!,
          ));
          // Add the user's location to the points list for drawing the polyline
          _points.add(LatLng(locationData.latitude!, locationData.longitude!));
   */
/**
  Future<void> _startLocationTracking() async {
    bool serviceEnabled = await _location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    PermissionStatus permissionStatus = await _location.hasPermission();
    if (permissionStatus == PermissionStatus.denied) {
      permissionStatus = await _location.requestPermission();
      if (permissionStatus != PermissionStatus.granted) {
        return;
      }
    }

// Calculates distance between two LatLng points in meters
    double distance(LatLng p1, LatLng p2) {
      const nauticalMile = 1852;
      const radius = 6371 * nauticalMile;
      final lat1 = p1.latitude, lon1 = p1.longitude;
      final lat2 = p2.latitude, lon2 = p2.longitude;
      final dLat = (lat2 - lat1) * (pi / 180);
      final dLon = (lon2 - lon1) * (pi / 180);
      final a = sin(dLat / 2) * sin(dLat / 2) +
          cos(lat1 * (pi / 180)) *
              cos(lat2 * (pi / 180)) *
              sin(dLon / 2) *
              sin(dLon / 2);
      final c = 2 * asin(sqrt(a));
      return radius * c;
    }

// ...

    _location.onLocationChanged.listen((LocationData locationData) {
      if (_points.isEmpty ||
          distance(_points.last,
                  LatLng(locationData.latitude!, locationData.longitude!)) >=
              5) {
        setState(() {
          // Add the user's location to the points list if it's at least 5 meters away
          // from the previous point
          _points.add(LatLng(locationData.latitude!, locationData.longitude!));
        });
      }
    });
    // ...
  } */
