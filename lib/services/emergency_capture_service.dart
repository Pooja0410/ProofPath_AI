import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:camera/camera.dart';
import 'package:geolocator/geolocator.dart';
import 'package:record/record.dart';

import '../models/incident_record.dart';
import 'media_persistence.dart';
import 'audio_path.dart';

/// Coordinates the device-side evidence capture started by an SOS incident.
///
/// The service deliberately records video without camera audio and records the
/// microphone separately. This lets both streams start at the same time on
/// supported devices without competing for the microphone resource.
class EmergencyCaptureService {
  EmergencyCaptureService._();

  static final EmergencyCaptureService instance = EmergencyCaptureService._();

  CameraController? _cameraController;
  AudioRecorder? _audioRecorder;
  StreamSubscription<Position>? _locationSubscription;

  Position? _currentPosition;
  String? _videoPath;
  String? _audioPath;
  DateTime? _startedAt;
  final List<IncidentLocationPoint> _locations = [];
  bool _isActive = false;
  bool _isStarting = false;
  bool _videoRecordingActive = false;
  bool _audioRecordingActive = false;
  bool _locationTrackingActive = false;

  final StreamController<Position> _locationController =
      StreamController<Position>.broadcast();

  Stream<Position> get locationStream => _locationController.stream;
  Position? get currentPosition => _currentPosition;
  String? get videoPath => _videoPath;
  String? get audioPath => _audioPath;
  bool get isActive => _isActive;
  bool get isVideoRecording => _videoRecordingActive && (_cameraController?.value.isRecordingVideo ?? false);
  bool get isAudioRecording => _audioRecordingActive;
  bool get isLocationTracking => _locationTrackingActive && _locationSubscription != null;
  CameraController? get cameraController => _cameraController;
  DateTime? get startedAt => _startedAt;
  String? get currentIncidentId =>
      _startedAt == null ? null : _incidentId(_startedAt!);
  List<IncidentLocationPoint> get recordedLocations => List.unmodifiable(_locations);

  Future<void> start() async {
    if (_isActive || _isStarting) return;
    _isStarting = true;
    _startedAt = DateTime.now();
    _videoPath = null;
    _audioPath = null;
    _locations.clear();
    _videoRecordingActive = false;
    _audioRecordingActive = false;
    _locationTrackingActive = false;

    try {
      final locationReady = await _prepareLocation();
      final cameraReady = await _prepareCamera();
      final audioReady = await _prepareAudio();

      // Start all three evidence channels as part of the same SOS activation.
      if (cameraReady) {
        await _startVideo();
      }
      if (audioReady) {
        await _startAudio();
      }
      if (locationReady) {
        await _startLocation();
      }

      _isActive = cameraReady || audioReady || locationReady;
    } finally {
      _isStarting = false;
    }
  }

  Future<bool> _prepareLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return false;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return false;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _locations.add(IncidentLocationPoint.fromPosition(_currentPosition!));
      _locationController.add(_currentPosition!);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _prepareCamera() async {
    if (_cameraController?.value.isInitialized == true) return true;

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) return false;

      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      final controller = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await controller.initialize();
      _cameraController = controller;
      return true;
    } catch (_) {
      await _cameraController?.dispose();
      _cameraController = null;
      return false;
    }
  }

  Future<bool> _prepareAudio() async {
    try {
      final recorder = AudioRecorder();
      if (!await recorder.hasPermission()) {
        await recorder.dispose();
        return false;
      }
      _audioRecorder = recorder;
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _startVideo() async {
    final controller = _cameraController;
    if (controller == null || !controller.value.isInitialized) return;

    try {
      if (!controller.value.isRecordingVideo) {
        await controller.startVideoRecording();
        _videoRecordingActive = controller.value.isRecordingVideo;
      }
    } catch (_) {
      // Keep the other SOS channels running if the camera is unavailable.
    }
  }

  Future<void> _startAudio() async {
    final recorder = _audioRecorder;
    if (recorder == null) return;

    try {
      final filePath = kIsWeb ? '' : await prepareAudioPath(_startedAt ?? DateTime.now());

      await recorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
          numChannels: 1,
        ),
        path: filePath,
      );
      _audioPath = filePath;
      _audioRecordingActive = await recorder.isRecording();
    } catch (_) {
      // Video/location can still continue if audio initialization fails.
    }
  }

  Future<void> _startLocation() async {
    await _locationSubscription?.cancel();

    const settings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 5,
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: settings,
    ).listen((position) {
      _currentPosition = position;
      _locations.add(IncidentLocationPoint.fromPosition(position));
      _locationController.add(position);
    });
    _locationTrackingActive = true;
  }

  Future<IncidentRecord> stop() async {
    final startedAt = _startedAt ?? DateTime.now();

    if (!_isActive && _cameraController == null && _audioRecorder == null) {
      return IncidentRecord(
        id: _incidentId(startedAt),
        startedAt: startedAt,
        endedAt: DateTime.now(),
        videoPath: _videoPath,
        audioPath: _audioPath,
        locations: List.unmodifiable(_locations),
      );
    }

    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _locationTrackingActive = false;

    final controller = _cameraController;
    if (controller != null && controller.value.isInitialized) {
      try {
        if (controller.value.isRecordingVideo) {
          final file = await controller.stopVideoRecording();
          _videoPath = await _persistVideo(file.path, startedAt);
          _videoRecordingActive = false;
        }
      } catch (_) {}
    }

    final recorder = _audioRecorder;
    if (recorder != null) {
      try {
        final path = await recorder.stop();
        if (path != null) _audioPath = path;
        _audioRecordingActive = false;
      } catch (_) {}
      await recorder.dispose();
    }
    _audioRecorder = null;

    await controller?.dispose();
    _cameraController = null;
    _videoRecordingActive = false;
    _audioRecordingActive = false;
    _locationTrackingActive = false;
    _isActive = false;
    _isStarting = false;

    return IncidentRecord(
      id: _incidentId(startedAt),
      startedAt: startedAt,
      endedAt: DateTime.now(),
      videoPath: _videoPath,
      audioPath: _audioPath,
      locations: List.unmodifiable(_locations),
    );
  }

  String _incidentId(DateTime time) =>
      'PP-${time.year}-${time.millisecondsSinceEpoch.toString().substring(4)}';

  Future<String?> _persistVideo(String sourcePath, DateTime startedAt) =>
      persistVideo(sourcePath, startedAt);

  Future<void> dispose() async {
    await stop();
    await _locationController.close();
  }
}
