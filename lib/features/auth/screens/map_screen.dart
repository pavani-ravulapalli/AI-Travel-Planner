import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_planner_app/core/constants.dart';
import 'package:travel_planner_app/features/auth/widgets/search_result.dart';
import 'package:travel_planner_app/features/map/provider/map_provider.dart';


class MapScreen extends ConsumerStatefulWidget {
  const MapScreen({super.key});

  @override
  ConsumerState<MapScreen> createState() => _MapScreenState();
}

  class _MapScreenState extends ConsumerState<MapScreen>{
  MapType _currentMapType = MapType.normal;
  static const _initial = CameraPosition(target: LatLng(27.7172, 85.3240),
  zoom: 13,
  );

  void _onMapTypeButtonPressed(){
    setState(() {
      _currentMapType=_currentMapType==MapType.normal
          ?MapType.satellite
          :MapType.normal;
    });
  }
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapProvider);
    final notifier = ref.read(mapProvider.notifier);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
           initialCameraPosition: _initial,
            mapType: _currentMapType,
              markers: state.markers,
            polylines: state.polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            mapToolbarEnabled: false,
            onMapCreated: ((controller) {
              notifier.setController(controller);
              if(AppConstants.mapStyle!= null) {
                controller.setMapStyle(AppConstants.mapStyle);
              }
              }),
        ),

          //search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 16,
            right: 16,
            child: const LocationSearchBar(),
          ),

          //loading overlay
          if(state.isLoading) const Center(child: CircularProgressIndicator()),

          //map type
          Positioned(
            bottom: state.routeInfo!=null?210:100,
            right: 16,
            child: FloatingActionButton(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              elevation: 4,
              onPressed: _onMapTypeButtonPressed,
              child: Icon(
                _currentMapType==MapType.normal
                    ?Icons.map
                    :Icons.map_outlined,
              ),
            ),
          ),

          //my current location
          Positioned(
              bottom: state.routeInfo!=null?140:32,
              right: 16,
              child: FloatingActionButton(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                elevation: 4,
                onPressed: notifier.fetchCurrentLocation,
              child: const Icon(Icons.my_location),
              ),
          ),
        ],
      ),
    );
  }
}
