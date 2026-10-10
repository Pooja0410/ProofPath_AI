import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants/app_colors.dart';
import '../../services/emergency_capture_service.dart';

class EvidenceCaptureScreen extends StatefulWidget {
  const EvidenceCaptureScreen({super.key});

  @override
  State<EvidenceCaptureScreen> createState() => _EvidenceCaptureScreenState();
}

class _EvidenceCaptureScreenState extends State<EvidenceCaptureScreen> {
  Timer? _refreshTimer;
  final EmergencyCaptureService _service = EmergencyCaptureService.instance;
  Position? _position;
  int _seconds = 0;

  @override
  void initState() {
    super.initState();
    _position = _service.currentPosition;
    _refreshTimer = Timer.periodic(const Duration(milliseconds: 500), (_) {
      if (!mounted) return;
      setState(() {
        _position = _service.currentPosition;
        _seconds = _service.isActive && _service.recordedLocations.isNotEmpty
            ? DateTime.now().difference(
                _service.recordedLocations.first.timestamp,
              ).inSeconds
            : _seconds;
      });
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  String get formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _service.cameraController;
    final cameraReady = controller?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Evidence Capture', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            _statusBanner(),
            const SizedBox(height: 18),
            Container(
              height: 280,
              width: double.infinity,
              decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(24)),
              clipBehavior: Clip.antiAlias,
              child: Stack(children: [
                if (cameraReady)
                  Positioned.fill(child: CameraPreview(controller!))
                else
                  const Center(child: Icon(Icons.videocam_outlined, color: Colors.white54, size: 70)),
                if (_service.isVideoRecording)
                  Positioned(top: 16, left: 16, child: _pill(Icons.fiber_manual_record, 'REC', AppColors.sosRed)),
                Positioned(top: 16, right: 16, child: _darkPill(formattedTime)),
                Positioned(bottom: 16, left: 16, right: 16, child: Row(children: [
                  const Icon(Icons.location_on, color: Colors.white, size: 18),
                  const SizedBox(width: 5),
                  Text(_service.isLocationTracking ? 'GPS tracking active' : 'GPS tracking OFF', style: const TextStyle(color: Colors.white, fontSize: 12)),
                  const Spacer(),
                  const Icon(Icons.lock, color: Colors.white, size: 17),
                  const SizedBox(width: 5),
                  const Text('Secure', style: TextStyle(color: Colors.white, fontSize: 12)),
                ])),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Capture Status', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            _statusCard(icon: Icons.videocam, title: 'Video Recording', subtitle: _service.isVideoRecording ? 'Camera is recording live evidence' : 'Video capture is not active', status: _service.isVideoRecording ? 'ON' : 'OFF', iconColor: _service.isVideoRecording ? AppColors.sosRed : Colors.grey),
            const SizedBox(height: 10),
            _statusCard(icon: Icons.mic, title: 'Audio Recording', subtitle: _service.isAudioRecording ? 'Microphone is recording live evidence' : 'Microphone recording is not active', status: _service.isAudioRecording ? 'ON' : 'OFF', iconColor: _service.isAudioRecording ? AppColors.primary : Colors.grey),
            const SizedBox(height: 10),
            _statusCard(icon: Icons.location_on, title: 'GPS Location', subtitle: !_service.isLocationTracking ? 'Location permission/service unavailable' : (_position == null ? 'Waiting for a location fix' : '${_position!.latitude.toStringAsFixed(5)}, ${_position!.longitude.toStringAsFixed(5)}'), status: _service.isLocationTracking ? 'ON' : 'OFF', iconColor: _service.isLocationTracking ? Colors.green : Colors.grey),
            const SizedBox(height: 10),
            _statusCard(icon: Icons.cloud_done, title: 'Evidence Preservation', subtitle: 'Only active capture channels will be saved with this incident', status: _service.isActive ? 'READY' : 'OFF', iconColor: _service.isActive ? Colors.orange : Colors.grey),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
              child: Row(children: [
                const Icon(Icons.info_outline, color: AppColors.primary),
                const SizedBox(width: 10),
                Expanded(child: Text('Video and audio are captured separately. GPS points are collected throughout the emergency session.', style: TextStyle(color: AppColors.textLight, fontSize: 12, height: 1.45))),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  Widget _statusBanner() => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
    decoration: BoxDecoration(color: AppColors.sosRed.withValues(alpha: .10), borderRadius: BorderRadius.circular(14)),
    child: Row(children: [const CircleAvatar(radius: 5, backgroundColor: AppColors.sosRed), const SizedBox(width: 10), const Text('LIVE EVIDENCE CAPTURE', style: TextStyle(color: AppColors.sosRed, fontWeight: FontWeight.bold, fontSize: 13)), const Spacer(), Text(formattedTime, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold))]),
  );

  Widget _pill(IconData icon, String text, Color color) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)), child: Row(children: [Icon(icon, color: Colors.white, size: 12), const SizedBox(width: 5), Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))]));
  Widget _darkPill(String text) => Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(8)), child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)));

  Widget _statusCard({required IconData icon, required String title, required String subtitle, required String status, required Color iconColor}) => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: iconColor.withValues(alpha: .10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: iconColor, size: 23)),
      const SizedBox(width: 13),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight))])),
      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: iconColor.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)), child: Text(status, style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: iconColor))),
    ]),
  );
}
