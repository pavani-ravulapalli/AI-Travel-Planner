import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:travel_planner_app/features/map/model/place_result.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_planner_app/core/constants.dart';

class PlaceService {
  final String apiKey;
  const PlaceService({required this.apiKey});

  Future<List<PlaceResult>> getSuggestions(String input) async {
    print("searching for :$input");
    if (input.trim().isEmpty) return [];
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/autocomplete/json'
          '?input=${Uri.encodeComponent(input)}&key=$apiKey&language=en',
    );
    print("Api url: $url");
    try{
      final response = await http.get(url);
      print("Status code:${response.statusCode}");
      print("response body:${response.body}");
      final data=json.decode(response.body);
      if (data['status']=='OK'){
        return (data['predictions'] as List)
            .map(
            (p) => PlaceResult(
              placeId: p['place_id'],
              description: p['description'],
              primaryText: p['structured_formatting']['main_text'] ?? p['description'],
              secondaryText: p['structured_formatting']['secondary_text'] ?? '',
            ),
        )
            .toList();
      }
    }catch(e){
      debugPrint('Autocomplete error: $e');
    }
    return[];
  }

  Future<LatLng?> getLatLng(String placeId) async {
    final url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/details/json'
          '?place_id=$placeId&fields=geometry&key=$apiKey',
    );
    try{
      final response = await http.get(url);
      final data = json.decode(response.body);
      if(data['status'] == 'OK'){
        final loc = data['result']['geometry']['location'];
        return LatLng(loc['lat'],loc['lng']);
      }
    }catch(e){
      debugPrint('place details error: $e');
    }
    return null;
  }
}
