import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:travel_planner_app/core/constants.dart';
import 'package:travel_planner_app/features/map/model/place_result.dart';
import 'package:travel_planner_app/features/map/service/place_service.dart';
import 'package:travel_planner_app/features/map/service/direction_service.dart';
import 'package:travel_planner_app/features/map/service/location_service.dart';

class MapState {
  final LatLng? currentLocation;
  final LatLng? destination;
  final Set<Marker> markers;
  final Set<Polyline> polylines;
  final RouteInfo? routeInfo;
  final bool isLoading;
  final String? error;
  final String remainingDistance;
  final String remainingDuration;

  const MapState({
    this.currentLocation,
    this.destination,
    this.markers = const {},
    this.polylines = const {},
    this.routeInfo,
    this.isLoading = false,
    this.error,
    this.remainingDistance = '',
    this.remainingDuration = '',
  });

  MapState copyWith({
    LatLng? currentLocation,
    LatLng? destination,
    Set<Marker>? markers,
    Set<Polyline>? polylines,
    RouteInfo? routeInfo,
    bool? isLoading,
    String? error,
    bool clearRouteInfo = false,
    String? remainingDistance,
    String? remainingDuration,
  }) =>
      MapState(
        currentLocation: currentLocation ?? this.currentLocation,
        destination: destination ?? this.destination,
        markers: markers ?? this.markers,
        polylines: polylines ?? this.polylines,
        routeInfo: clearRouteInfo ? null : (routeInfo ?? this.routeInfo),
        isLoading: isLoading ?? this.isLoading,
        error: error,
        remainingDistance: remainingDistance ?? this.remainingDistance,
        remainingDuration: remainingDuration ?? this.remainingDuration,
      );
}

final placeServiceProvider = Provider(
  (_) => PlaceService(apiKey: AppConstants.apiKey),
);
final directionsServiceProvider = Provider(
  (_) => DirectionService(apiKey: AppConstants.apiKey),
);
final locationServiceProvider = Provider((_) => LocationService());

class MapNotifier extends Notifier<MapState> {
  GoogleMapController? _mapController;
  Timer? _animationTimer;

  static const Duration _routeAnimationDuration = Duration(seconds: 30);

  @override
  MapState build() {
    ref.onDispose(() {
      _animationTimer?.cancel();
    });
    return const MapState();
  }

  PlaceService get _placeService => ref.read(placeServiceProvider);
  DirectionService get _directionsService => ref.read(directionsServiceProvider);
  LocationService get _locationService => ref.read(locationServiceProvider);

  void setController(GoogleMapController controller) {
    _mapController = controller;
  }

  Future<void> fetchCurrentLocation() async {
    state = state.copyWith(isLoading: true, error: null);
    final latLng = await _locationService.getCurrentLocation();
    if (latLng == null) {
      state = state.copyWith(isLoading: false, error: 'location unavailable');
      return;
    }

    final marker = await _buildMarker(
      id: 'current',
      position: latLng,
      color: Colors.blue,
      label: 'you',
    );

    state = state.copyWith(
      currentLocation: latLng,
      isLoading: false,
      markers: {
        ...state.markers.where((m) => m.markerId.value != 'current'),
        marker,
      },
    );

    _mapController?.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: latLng, zoom: AppConstants.defaultZoom),
      ),
    );
  }

  Future<void> selectDestination(PlaceResult place) async {
    state = state.copyWith(isLoading: true, error: null);
    final latLng = await _placeService.getLatLng(place.placeId);
    if (latLng == null) {
      state = state.copyWith(isLoading: false, error: 'destination unavailable');
      return;
    }

    final destMarker = await _buildMarker(
      id: 'destination',
      position: latLng,
      color: Colors.red,
      label: place.description,
    );

    state = state.copyWith(
      destination: latLng,
      markers: {
        ...state.markers.where((m) => m.markerId.value != 'destination'),
        destMarker,
      },
      isLoading: false,
    );
    if (state.currentLocation != null) {
      await _drawRoute(state.currentLocation!, latLng);
    } else {
      _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: latLng, zoom: AppConstants.defaultZoom),
        ),
      );
    }
  }

  Future<void> _drawRoute(LatLng origin, LatLng destination) async {
    state = state.copyWith(isLoading: true);
    final routeInfo = await _directionsService.getRoute(origin, destination);
    if (routeInfo == null) {
      state = state.copyWith(isLoading: false, error: 'Could not fetch route');
      return;
    }

    final polyline = Polyline(
      polylineId: const PolylineId('route'),
      points: routeInfo.polylinePoints,
      color: const Color(0xFF1A73E8),
      width: 5,
      startCap: Cap.roundCap,
      endCap: Cap.roundCap,
      jointType: JointType.round,
    );

    state = state.copyWith(
      polylines: {polyline},
      routeInfo: routeInfo,
      isLoading: false,
    );

    _fitCameraToRoute(routeInfo.polylinePoints);

    await Future.delayed(const Duration(seconds: 2));
    _animateMarkerAlongRoute(routeInfo.polylinePoints);
  }

  void _fitCameraToRoute(List<LatLng> points) {
    if (points.isEmpty || _mapController == null) return;

    double minLat = points.first.latitude;
    double maxLat = points.first.latitude;
    double minLng = points.first.longitude;
    double maxLng = points.first.longitude;

    for (final p in points) {
      if (p.latitude < minLat) minLat = p.latitude;
      if (p.latitude > maxLat) maxLat = p.latitude;
      if (p.longitude < minLng) minLng = p.longitude;
      if (p.longitude > maxLng) maxLng = p.longitude;
    }

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLng),
          northeast: LatLng(maxLat, maxLng),
        ),
        AppConstants.routeZoomPadding,
      ),
    );
  }

  void _animateMarkerAlongRoute(List<LatLng> points) {
    _animationTimer?.cancel();
    if (points.length < 2) return;

    final totalMs = _routeAnimationDuration.inMilliseconds;

    double totalLength = 0;
    for (int i = 0; i < points.length - 1; i++) {
      totalLength += _distance(points[i], points[i + 1]);
    }

    final progress = <double>[0];
    double accumulated = 0;
    for (int i = 0; i < points.length - 1; i++) {
      accumulated += _distance(points[i], points[i + 1]);
      progress.add(accumulated / totalLength);
    }

    const tickMs = 16;
    int elapsed = 0;

    _animationTimer = Timer.periodic(const Duration(milliseconds: tickMs), (
      timer,
    ) async {
      elapsed += tickMs;
      if (elapsed >= totalMs) {
        timer.cancel();
        _updateMovingMarker(
          points.last,
          _bearing(points[points.length - 2], points.last),
        );
        return;
      }

      final t = elapsed / totalMs;
      final remaining = 1.0 - t;

      final currentRouteInfo = state.routeInfo;
      if (currentRouteInfo != null) {
        final totalDistanceKm = _parseDistance(currentRouteInfo.distance);
        final totalDurationMin = _parseDuration(currentRouteInfo.duration);

        final remainingDist = totalDistanceKm * remaining;
        final remainingDur = totalDurationMin * remaining;

        state = state.copyWith(
          remainingDistance: remainingDist < 1
              ? '${(remainingDist * 1000).toStringAsFixed(0)} m'
              : '${remainingDist.toStringAsFixed(1)} km',
          remainingDuration: remainingDur < 1
              ? 'less than a min'
              : '${remainingDur.toStringAsFixed(0)} min',
        );
      }

      int segIndex = 0;
      for (int i = 0; i < progress.length - 1; i++) {
        if (t >= progress[i] && t <= progress[i + 1]) {
          segIndex = i;
          break;
        }
      }

      final segStart = progress[segIndex];
      final segEnd = progress[segIndex + 1];
      final segT = segEnd > segStart ? (t - segStart) / (segEnd - segStart) : 0.0;

      final from = points[segIndex];
      final to = points[segIndex + 1];

      final lat = from.latitude + (to.latitude - from.latitude) * segT;
      final lng = from.longitude + (to.longitude - from.longitude) * segT;
      final pos = LatLng(lat, lng);
      final heading = _bearing(from, to);

      _updateMovingMarker(pos, heading);

      if (currentRouteInfo != null) {
        final totalDistance = _parseDistance(currentRouteInfo.distance);
        if (totalDistance >= 20) {
          _mapController?.animateCamera(CameraUpdate.newLatLng(pos));
        } else {
          _mapController?.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                target: pos,
                zoom: 15.5,
                tilt: 45.0,
                bearing: heading,
              ),
            ),
          );
        }
      }
    });
  }

  double _distance(LatLng p1, LatLng p2) {
    return math.sqrt(
      math.pow(p1.latitude - p2.latitude, 2) +
          math.pow(p1.longitude - p2.longitude, 2),
    );
  }

  double _parseDistance(String text) {
    final value = double.tryParse(text.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0;
    return text.contains('m') && !text.contains('km') ? value / 1000 : value;
  }

  double _parseDuration(String text) {
    double total = 0;
    final hourMatch = RegExp(r'(\d+)\s*hour').firstMatch(text);
    final minMatch = RegExp(r'(\d+)\s*min').firstMatch(text);
    if (hourMatch != null) total += double.parse(hourMatch.group(1)!) * 60;
    if (minMatch != null) total += double.parse(minMatch.group(1)!);
    return total;
  }

  void _updateMovingMarker(LatLng pos, double heading) async {
    final marker = Marker(
      markerId: const MarkerId('moving'),
      position: pos,
      rotation: heading,
      anchor: const Offset(0.5, 0.5),
      flat: true,
      icon: await _buildCarIcon(),
      zIndexInt: 2,
    );

    state = state.copyWith(
      markers: {
        ...state.markers.where((m) => m.markerId.value != 'moving'),
        marker,
      },
    );
  }

  double _bearing(LatLng from, LatLng to) {
    final lat1 = from.latitude * math.pi / 180;
    final lat2 = to.latitude * math.pi / 180;
    final dLng = (to.longitude - from.longitude) * math.pi / 180;

    final y = math.sin(dLng) * math.cos(lat2);
    final x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLng);

    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  Future<BitmapDescriptor> _buildCarIcon() async {
    const size = 80.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final bodyPaint = Paint()..color = const Color(0xFF1A73E8);
    final shadowPaint = Paint()..color = Colors.black26;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(10, 14, 60, 58),
        const Radius.circular(10),
      ),
      shadowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(8, 10, 64, 56),
        const Radius.circular(10),
      ),
      bodyPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(18, 12, 44, 22),
        const Radius.circular(4),
      ),
      Paint()..color = Colors.white.withValues(alpha: 0.85),
    );

    final wheelPaint = Paint()..color = Colors.black87;
    canvas.drawCircle(const Offset(18, 66), 8, wheelPaint);
    canvas.drawCircle(const Offset(62, 66), 8, wheelPaint);
    canvas.drawCircle(const Offset(18, 14), 8, wheelPaint);
    canvas.drawCircle(const Offset(62, 14), 8, wheelPaint);

    final image = await recorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  Future<Marker> _buildMarker({
    required String id,
    required LatLng position,
    required Color color,
    String? label,
  }) async {
    final icon = await _createMarkerBitmap(color: color, label: label ?? '');
    return Marker(
      markerId: MarkerId(id),
      position: position,
      icon: icon,
      infoWindow: label != null ? InfoWindow(title: label) : InfoWindow.noText,
    );
  }

  Future<BitmapDescriptor> _createMarkerBitmap({
    required Color color,
    required String label,
  }) async {
    const size = 120.0;
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      Paint()..color = color,
    );
    canvas.drawCircle(
      const Offset(size / 2, size / 2),
      size / 2,
      Paint()
        ..color = Colors.white
        ..style = PaintingStyle.stroke
        ..strokeWidth = 6,
    );

    final textPainter = TextPainter(
      text: TextSpan(
        text: label.isNotEmpty ? label[0].toUpperCase() : '.',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 36,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    textPainter.paint(
      canvas,
      Offset(
        size / 2 - textPainter.width / 2,
        size / 2 - textPainter.height / 2,
      ),
    );

    final image = await recorder.endRecording().toImage(
          size.toInt(),
          size.toInt(),
        );
    final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
    return BitmapDescriptor.bytes(bytes!.buffer.asUint8List());
  }

  void clearRoute() {
    _animationTimer?.cancel();

    state = state.copyWith(
      destination: null,
      polylines: {},
      clearRouteInfo: true,
      remainingDuration: '',
      remainingDistance: '',
      markers: state.markers
          .where((m) =>
              m.markerId.value != 'destination' && m.markerId.value != 'moving')
          .toSet(),
    );
  }
}

final mapProvider = NotifierProvider<MapNotifier, MapState>(MapNotifier.new);
