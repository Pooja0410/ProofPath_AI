import 'dart:async';

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';

import '../../constants/app_colors.dart';
import '../../services/emergency_capture_service.dart';
import '../../services/incident_history_service.dart';
import 'evidence_capture_screen.dart';
import '../incidents/evidence_saved_screen.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> with WidgetsBindingObserver {
  Timer? _timer;
  final EmergencyCaptureService _captureService =
      EmergencyCaptureService.instance;

  int _seconds = 0;

  bool _captureReady = false;
  bool _waitingForLocationSettings = false;
  bool _captureStartInProgress = false;
  bool _endDialogOpen = false;
  bool _isEndingEmergency = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _startTimer();
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareAndStartCapture());
  }

  Future<void> _prepareAndStartCapture() async {
    if (!mounted || _captureStartInProgress) return;

    // Android does not show a runtime permission prompt when permission is
    // already granted but the phone-wide Location service is switched off.
    // Explain the difference and let the user open system Location settings.
    final locationEnabled = await Geolocator.isLocationServiceEnabled();
    if (!locationEnabled && mounted) {
      final choice = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => AlertDialog(
          title: const Text('Enable Location Services'),
          content: const Text(
            'ProofPath AI has location permission, but Location is turned off '
            'on your phone. Turn on Location to capture GPS coordinates for '
            'this emergency.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, 'continue'),
              child: const Text('Continue Without GPS'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, 'settings'),
              icon: const Icon(Icons.location_on_outlined),
              label: const Text('Open Settings'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      if (choice == 'settings') {
        _waitingForLocationSettings = true;
        await Geolocator.openLocationSettings();
        // Android may return to the app after the user enables Location;
        // didChangeAppLifecycleState retries capture when that happens.
        return;
      }
    }

    await _startCapture();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && _waitingForLocationSettings) {
      _waitingForLocationSettings = false;
      _prepareAndStartCapture();
    }
  }

  Future<void> _startCapture() async {
    if (!mounted || _captureStartInProgress) return;
    _captureStartInProgress = true;
    try {
      await _captureService.start();
      if (mounted) {
        setState(() {
          _captureReady = _captureService.isVideoRecording ||
              _captureService.isAudioRecording ||
              _captureService.isLocationTracking;
        });
      }
    } finally {
      _captureStartInProgress = false;
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (!mounted) return;

        setState(() {
          _seconds++;
          _captureReady = _captureService.isVideoRecording ||
              _captureService.isAudioRecording ||
              _captureService.isLocationTracking;
        });
      },
    );
  }

  String get _formattedTime {
    final minutes = (_seconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_seconds % 60).toString().padLeft(2, '0');

    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  Future<void> _endEmergency() async {
    // Ignore rapid/repeated taps while the confirmation dialog or end flow is active.
    if (_endDialogOpen || _isEndingEmergency || !mounted) return;
    _endDialogOpen = true;

    final shouldEnd = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        title: const Text(
          'End Emergency?',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Evidence capture and location tracking will stop.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Continue'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.sosRed,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('END'),
          ),
        ],
      ),
    );

    _endDialogOpen = false;

    // Continue must leave capture and the emergency timer running.
    if (shouldEnd != true || !mounted) return;
    if (_isEndingEmergency) return;
    _isEndingEmergency = true;
    _timer?.cancel();

    try {
      final incident = await _captureService.stop();
      await IncidentHistoryService.instance.add(incident);
      if (!mounted) return;

      // Replace this screen so Back cannot return to the ended emergency.
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => EvidenceSavedScreen(incident: incident),
        ),
      );
    } catch (e, stackTrace) {
      debugPrint('Error ending emergency: $e');
      debugPrintStack(stackTrace: stackTrace);
      if (mounted) {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not finish saving the emergency evidence. Please try again.'),
          ),
        );
      }
    } finally {
      _isEndingEmergency = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cameraController = _captureService.cameraController;
    final cameraReady = cameraController?.value.isInitialized == true;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7FF),
      body: SafeArea(
        child: Column(
          children: [
            // HEADER
            Padding(
              padding: const EdgeInsets.fromLTRB(
                18,
                14,
                18,
                10,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.lock_outline_rounded,
                    ),
                  ),

                  const Expanded(
                    child: Text(
                      'Emergency Mode',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ),

                  const SizedBox(width: 48),
                ],
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(
                  20,
                  8,
                  20,
                  25,
                ),
                child: Column(
                  children: [
                    // EMERGENCY STATUS
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8EB),
                        borderRadius:
                            BorderRadius.circular(24),
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: 54,
                            height: 54,
                            decoration:
                                const BoxDecoration(
                              color: AppColors.sosRed,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.warning_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),

                          const SizedBox(height: 10),

                          const Text(
                            'EMERGENCY ACTIVE',
                            style: TextStyle(
                              color: AppColors.sosRed,
                              fontWeight: FontWeight.w900,
                              fontSize: 16,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 6),

                          Text(
                            _formattedTime,
                            style: const TextStyle(
                              color: AppColors.textDark,
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                            ),
                          ),

                          const Text(
                            'Evidence capture in progress',
                            style: TextStyle(
                              color: AppColors.textLight,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 18),

                    // CAMERA PREVIEW
                    Container(
                      height: 220,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius:
                            BorderRadius.circular(26),
                        color: const Color(0xFF202235),
                      ),
                      child: Stack(
                        children: [
                          if (cameraReady)
                            Positioned.fill(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(26),
                                child: CameraPreview(cameraController!),
                              ),
                            )
                          else
                            const Center(
                              child: Icon(
                                Icons.videocam_rounded,
                                color: Colors.white24,
                                size: 70,
                              ),
                            ),

                          Positioned(
                            top: 14,
                            left: 14,
                            child: Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    // ignore: deprecated_member_use
                                    .withOpacity(0.55),
                                borderRadius:
                                    BorderRadius.circular(20),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: _captureService.isVideoRecording
                                    ? const [
                                        Icon(Icons.circle, color: AppColors.sosRed, size: 10),
                                        SizedBox(width: 6),
                                        Text('REC', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                                      ]
                                    : const [
                                        Icon(Icons.videocam_off, color: Colors.white70, size: 14),
                                        SizedBox(width: 6),
                                        Text('CAMERA OFF', style: TextStyle(color: Colors.white70, fontSize: 11)),
                                      ],
                              ),
                            ),
                          ),

                          const Positioned(
                            bottom: 14,
                            right: 14,
                            child: Text(
                              'VIDEO CAPTURE',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 11,
                                fontWeight:
                                    FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // CAPTURE STATUS
                    _statusRow(
                      icon: Icons.mic_rounded,
                      title: 'Audio Recording',
                      subtitle: _captureService.isAudioRecording
                          ? 'Microphone is recording'
                          : 'Microphone permission required or recording inactive',
                      enabled: _captureService.isAudioRecording,
                    ),

                    const SizedBox(height: 10),

                    _statusRow(
                      icon: Icons.videocam_rounded,
                      title: 'Video Recording',
                      subtitle: _captureService.isVideoRecording
                          ? 'Camera is recording evidence'
                          : 'Camera permission required or recording inactive',
                      enabled: _captureService.isVideoRecording,
                    ),

                    const SizedBox(height: 10),

                    _statusRow(
                      icon: Icons.location_on_rounded,
                      title: 'GPS Tracking',
                      subtitle: _captureService.isLocationTracking
                          ? 'Live location is being tracked'
                          : 'Location permission required or tracking inactive',
                      enabled: _captureService.isLocationTracking,
                    ),

                    const SizedBox(height: 10),

                    _statusRow(
                      icon: Icons.cloud_upload_rounded,
                      title: 'Evidence Preservation',
                      subtitle: _captureReady
                          ? 'Active evidence channels are being captured locally'
                          : 'Waiting for permission and an active capture channel',
                      enabled: _captureReady,
                    ),

                    const SizedBox(height: 20),

                    // LOCATION CARD
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                              color: AppColors.primary
                                  // ignore: deprecated_member_use
                                  .withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.my_location_rounded,
                              color: AppColors.primary,
                            ),
                          ),

                          const SizedBox(width: 12),

                          const Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Location Protected',
                                  style: TextStyle(
                                    fontWeight:
                                        FontWeight.bold,
                                    color:
                                        AppColors.textDark,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Your live location is being shared securely.',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color:
                                        AppColors.textLight,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const Icon(
                            Icons.check_circle_rounded,
                            color: Color(0xFF2EAA67),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 15),

                    // INCIDENT ID
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppColors.primaryDark,
                            AppColors.primary,
                          ],
                        ),
                        borderRadius:
                            BorderRadius.circular(22),
                      ),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'INCIDENT ID',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 7),

                          Text(
                            _captureService.currentIncidentId ?? 'Preparing incident…',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1,
                            ),
                          ),

                          const SizedBox(height: 6),

                          const Text(
                            'Keep this ID for secure incident access.',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),

                  //VIEW LIVE EVIDENCE BUTTON
                    const SizedBox(height: 15),
                    ElevatedButton.icon(
                     onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                               EvidenceCaptureScreen(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('View Live Evidence'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(double.infinity, 55),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),

                    const SizedBox(height: 25),

                    // END BUTTON
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: OutlinedButton(
                        onPressed: (_isEndingEmergency || _endDialogOpen) ? null : _endEmergency,
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(
                            color: AppColors.sosRed,
                            width: 1.5,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'END EMERGENCY',
                          style: TextStyle(
                            color: AppColors.sosRed,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statusRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool enabled,
  }) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFEAF8F0)
                  : Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: enabled
                  ? const Color(0xFF2EAA67)
                  : Colors.grey,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),

          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 9,
              vertical: 5,
            ),
            decoration: BoxDecoration(
              color: enabled
                  ? const Color(0xFFEAF8F0)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              enabled ? 'ON' : 'OFF',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.bold,
                color: enabled
                    ? const Color(0xFF2EAA67)
                    : Colors.grey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}