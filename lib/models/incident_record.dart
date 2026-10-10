import 'package:geolocator/geolocator.dart';

class IncidentRecord {
  final String id;
  final DateTime startedAt;
  final DateTime endedAt;
  final String? videoPath;
  final String? audioPath;
  final List<IncidentLocationPoint> locations;

  const IncidentRecord({
    required this.id,
    required this.startedAt,
    required this.endedAt,
    required this.videoPath,
    required this.audioPath,
    required this.locations,
  });

  Duration get duration => endedAt.difference(startedAt);
  double? get latitude => locations.isEmpty ? null : locations.last.latitude;
  double? get longitude => locations.isEmpty ? null : locations.last.longitude;
  String get locationLabel => locations.isEmpty
      ? 'Location unavailable'
      : '${latitude!.toStringAsFixed(5)}, ${longitude!.toStringAsFixed(5)}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'startedAt': startedAt.toIso8601String(),
        'endedAt': endedAt.toIso8601String(),
        'videoPath': videoPath,
        'audioPath': audioPath,
        'locations': locations.map((e) => e.toJson()).toList(),
      };

  factory IncidentRecord.fromJson(Map<String, dynamic> json) {
    return IncidentRecord(
      id: json['id'] as String,
      startedAt: DateTime.parse(json['startedAt'] as String),
      endedAt: DateTime.parse(json['endedAt'] as String),
      videoPath: json['videoPath'] as String?,
      audioPath: json['audioPath'] as String?,
      locations: ((json['locations'] as List?) ?? const [])
          .whereType<Map>()
          .map((e) => IncidentLocationPoint.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}

class IncidentLocationPoint {
  final double latitude;
  final double longitude;
  final double accuracy;
  final DateTime timestamp;

  const IncidentLocationPoint({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    required this.timestamp,
  });

  factory IncidentLocationPoint.fromPosition(Position position) {
    return IncidentLocationPoint(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      timestamp: position.timestamp,
    );
  }

  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'timestamp': timestamp.toIso8601String(),
      };

  factory IncidentLocationPoint.fromJson(Map<String, dynamic> json) {
    return IncidentLocationPoint(
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      accuracy: (json['accuracy'] as num?)?.toDouble() ?? 0,
      timestamp: DateTime.parse(json['timestamp'] as String),
    );
  }
}
