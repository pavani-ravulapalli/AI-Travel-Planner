import 'package:google_maps_flutter/google_maps_flutter.dart';

class PlaceResult {
  final String placeId;
  final String description;
  final String primaryText;// main place name
  final String secondaryText;// address/area/city
  final LatLng? latLng;

  const PlaceResult({
    required this.placeId,
    required this.description,
    required this.primaryText,
    required this.secondaryText,
    this.latLng,
});

  PlaceResult copyWith({LatLng? latLng}) => PlaceResult(
      placeId: placeId,
      description: description,
      primaryText: primaryText,
      secondaryText: secondaryText,
      latLng: latLng,
  );
}