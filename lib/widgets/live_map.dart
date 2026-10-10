import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

import '../constants/app_colors.dart';

class LiveMap extends StatefulWidget {
  final double height;
  final BorderRadius borderRadius;
  final bool showControls;
  final bool showMarker;

  const LiveMap({
    super.key,
    required this.height,
    this.borderRadius = const BorderRadius.all(Radius.circular(24)),
    this.showControls = true,
    this.showMarker = true,
  });

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  final MapController _mapController = MapController();
  StreamSubscription<Position>? _locationSubscription;
  LatLng? _location;
  double _zoom = 15;
  bool _mapReady = false;

  @override
  void initState() {
    super.initState();
    _startLocationUpdates();
  }

  Future<void> _startLocationUpdates() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _updateLocation(position, moveMap: false);

      _locationSubscription = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      ).listen(_updateLocation);
    } catch (_) {
      // The map still renders even when location permission/service is unavailable.
    }
  }

  void _updateLocation(Position position, {bool moveMap = true}) {
    if (!mounted) return;
    final point = LatLng(position.latitude, position.longitude);
    setState(() => _location = point);
    if (moveMap && _mapReady) {
      _mapController.move(point, _zoom);
    }
  }

  @override
  void dispose() {
    _locationSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center = _location ?? const LatLng(18.5204, 73.8567);

    return SizedBox(
      height: widget.height,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: widget.borderRadius,
        child: FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: _location == null ? 12 : 15,
            minZoom: 3,
            maxZoom: 19,
            onMapReady: () {
              _mapReady = true;
              if (_location != null) {
                _mapController.move(_location!, _zoom);
              }
            },
            onPositionChanged: (position, _) => _zoom = position.zoom,
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.example.flutter_application_1',
            ),
            if (widget.showMarker && _location != null)
              MarkerLayer(
                markers: [
                  Marker(
                    point: _location!,
                    width: 52,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.sosRed,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 4),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.sosRed.withOpacity(0.35),
                            blurRadius: 14,
                            spreadRadius: 4,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 25,
                      ),
                    ),
                  ),
                ],
              ),
            RichAttributionWidget(
              attributions: [
                TextSourceAttribution('OpenStreetMap contributors'),
              ],
            ),
            if (widget.showControls)
              Positioned(
                right: 15,
                bottom: 15,
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  elevation: 3,
                  child: IconButton(
                    onPressed: _location == null || !_mapReady
                        ? null
                        : () => _mapController.move(_location!, 16),
                    icon: const Icon(
                      Icons.my_location,
                      color: AppColors.primary,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
