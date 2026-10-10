import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../constants/app_colors.dart';
import '../../models/incident_record.dart';

class IncidentLocationScreen extends StatelessWidget {
  final IncidentRecord incident;

  const IncidentLocationScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final points = incident.locations
        .map((p) => LatLng(p.latitude, p.longitude))
        .toList();
    final center = points.isNotEmpty
        ? points.last
        : const LatLng(18.5204, 73.8567);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Location Evidence',
          style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: FlutterMap(
                options: MapOptions(
                  initialCenter: center,
                  initialZoom: points.isNotEmpty ? 16 : 12,
                ),
                children: [
                  TileLayer(
                    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.proofpath.ai',
                  ),
                  if (points.length > 1)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: points,
                          strokeWidth: 5,
                          color: AppColors.primary,
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (points.isNotEmpty)
                        Marker(
                          point: points.first,
                          width: 44,
                          height: 44,
                          child: const Icon(Icons.trip_origin, color: Colors.green, size: 34),
                        ),
                      if (points.isNotEmpty)
                        Marker(
                          point: points.last,
                          width: 50,
                          height: 50,
                          child: const Icon(Icons.location_pin, color: AppColors.sosRed, size: 44),
                        ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Recorded GPS Data', style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 10),
                  Text('Points recorded: ${incident.locations.length}', style: const TextStyle(color: AppColors.textLight)),
                  const SizedBox(height: 5),
                  Text('Last location: ${incident.locationLabel}', style: const TextStyle(color: AppColors.textLight)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
