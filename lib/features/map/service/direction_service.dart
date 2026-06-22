import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'dart:convert';

class RouteInfo{
  final List<LatLng> polylinePoints;
  final String distance;
  final String duration;

  const RouteInfo({
    required this.polylinePoints,
    required this.distance,
    required this.duration,
  });
}

class DirectionService {
  final String apiKey;
  const DirectionService({required this.apiKey});

  Future<RouteInfo?> getRoute(LatLng origin, LatLng destination) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/directions/json?'
      'origin=${origin.latitude},${origin.longitude}&'
      'destination=${destination.latitude},${destination.longitude}&'
      'key=$apiKey',
    );

    try{
      final response = await http.get(url);
      final data = json.decode(response.body);

      if(data['status'] != 'OK') {
        debugPrint('Direction error: ${data['status']}');
        return null;
      }

      final legs = data['routes'][0]['legs'] as List;

      //----decode every step's polyline (not overview_polyline)---
    //overview_polyline is aggressively simplified and skips curves.
    //Decoding each step gives the full road-accurate geometry.
    final List<LatLng> allPoints = [];
    //error: the static method decodepolyline can't be accessed through an instance.
    for(final leg in legs){
      for(final step in leg['steps'] as List) {
        final encoded = step['polyline']['points'] as String;
        final points = PolylinePoints.decodePolyline(encoded)
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
        allPoints.addAll(points);
      }
    }

    final leg = legs[0];
    return RouteInfo(polylinePoints: allPoints,
    distance: leg['distance']['text'],
    duration: leg['duration']['text'],
    );
    }
    catch(e){
      debugPrint('Directions fetch error: $e');
      return null;
    }
  }
}