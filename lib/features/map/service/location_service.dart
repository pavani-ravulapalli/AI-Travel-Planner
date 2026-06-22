import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  ///Requests permission and returns current [LatLng].
  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if(!serviceEnabled) return null;

    LocationPermission permission = await Geolocator.checkPermission();
    if(permission == LocationPermission.denied){
      permission = await Geolocator.requestPermission();
      if(permission ==LocationPermission.denied) return null;
    }
    if (permission == LocationPermission.deniedForever) return null;

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
    );
    return LatLng(position.latitude, position.longitude);
  }

  ///emits live position updates (use for real-time tracking).
Stream<LatLng> positionStream(){
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).map((p) => LatLng(p.latitude, p.longitude));
}

  Future<String> getCurrentCity() async {
    final location = await getCurrentLocation();

    if (location == null) {
      return "Unknown";
    }

    final placemarks = await placemarkFromCoordinates(
      location.latitude,
      location.longitude,
    );

    if (placemarks.isEmpty) {
      return "Unknown";
    }

    return placemarks.first.locality ??
        placemarks.first.subAdministrativeArea ??
        "Unknown";
  }
}

