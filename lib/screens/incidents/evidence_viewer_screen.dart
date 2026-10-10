import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../constants/app_colors.dart';
import '../../models/incident_record.dart';
import '../../services/video_controller_factory.dart';

class EvidenceViewerScreen extends StatefulWidget {
  final IncidentRecord incident;
  final EvidenceType type;

  const EvidenceViewerScreen({
    super.key,
    required this.incident,
    required this.type,
  });

  @override
  State<EvidenceViewerScreen> createState() => _EvidenceViewerScreenState();
}

enum EvidenceType { video, audio }

class _EvidenceViewerScreenState extends State<EvidenceViewerScreen> {
  VideoPlayerController? _videoController;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _loading = true;
  String? _error;

  String? get _path => widget.type == EvidenceType.video
      ? widget.incident.videoPath
      : widget.incident.audioPath;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final path = _path;
      if (path == null || path.isEmpty) {
        throw Exception('Evidence file is not available for this incident.');
      }

      if (widget.type == EvidenceType.video) {
        final controller = createVideoController(path);
        _videoController = controller;
        await controller.initialize();
        await controller.setLooping(false);
      }
    } catch (e) {
      _error = 'Unable to load this evidence. $e';
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _playAudio() async {
    final path = _path;
    if (path == null) return;

    try {
      if (kIsWeb || path.startsWith('blob:') || path.startsWith('http')) {
        await _audioPlayer.play(UrlSource(path));
      } else {
        await _audioPlayer.play(DeviceFileSource(path));
      }
      if (mounted) setState(() {});
    } catch (e) {
      if (mounted) {
        setState(() => _error = 'Unable to play the audio recording. $e');
      }
    }
  }

  Future<void> _stopAudio() async => _audioPlayer.stop();

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isVideo = widget.type == EvidenceType.video;
    final title = isVideo ? 'Video Evidence' : 'Audio Evidence';
    final icon = isVideo ? Icons.videocam_rounded : Icons.mic_rounded;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(title, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [AppColors.primaryDark, AppColors.primary]),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(11),
                      decoration: BoxDecoration(color: Colors.white.withOpacity(.15), shape: BoxShape.circle),
                      child: Icon(icon, color: Colors.white, size: 25),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('SECURED EVIDENCE', style: TextStyle(color: Colors.white70, fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 1)),
                        const SizedBox(height: 5),
                        Text(widget.incident.id, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                      ]),
                    ),
                    const Icon(Icons.verified_user, color: Colors.white),
                  ],
                ),
              ),
              const SizedBox(height: 18),
              if (_loading)
                Container(
                  height: 320,
                  width: double.infinity,
                  decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(22)),
                  child: const Center(child: CircularProgressIndicator(color: Colors.white)),
                )
              else if (_error != null)
                _errorCard(_error!)
              else if (isVideo)
                _videoPlayer()
              else
                _audioPlayerCard(),
              const SizedBox(height: 18),
              _metadataCard(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _videoPlayer() {
    final controller = _videoController!;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(22)),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          AspectRatio(aspectRatio: controller.value.aspectRatio, child: VideoPlayer(controller)),
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 12),
            child: Row(children: [
              IconButton(
                color: Colors.white,
                iconSize: 30,
                onPressed: () async {
                  if (controller.value.isPlaying) {
                    await controller.pause();
                  } else {
                    await controller.play();
                  }
                  if (mounted) setState(() {});
                },
                icon: Icon(controller.value.isPlaying ? Icons.pause_circle : Icons.play_circle),
              ),
              Expanded(
                child: VideoProgressIndicator(controller, allowScrubbing: true, colors: const VideoProgressColors(playedColor: AppColors.sosRed)),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _audioPlayerCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)),
      child: Column(children: [
        Container(width: 80, height: 80, decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle), child: const Icon(Icons.mic, color: AppColors.primary, size: 40)),
        const SizedBox(height: 15),
        const Text('Emergency audio recording', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.textDark)),
        const SizedBox(height: 6),
        const Text('Recorded separately from the video for clearer evidence capture.', textAlign: TextAlign.center, style: TextStyle(color: AppColors.textLight, fontSize: 12)),
        const SizedBox(height: 18),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          ElevatedButton.icon(onPressed: _playAudio, icon: const Icon(Icons.play_arrow), label: const Text('Play'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white)),
          const SizedBox(width: 10),
          OutlinedButton.icon(onPressed: _stopAudio, icon: const Icon(Icons.stop), label: const Text('Stop')),
        ]),
      ]),
    );
  }

  Widget _metadataCard() => Container(
    width: double.infinity,
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Evidence Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.textDark)),
      const SizedBox(height: 14),
      _row('Incident', widget.incident.id),
      _row('Captured', _dateTime(widget.incident.startedAt)),
      _row('Duration', _duration(widget.incident.duration)),
      _row('GPS points', '${widget.incident.locations.length}'),
    ]),
  );

  Widget _row(String label, String value) => Padding(
    padding: const EdgeInsets.only(bottom: 9),
    child: Row(children: [Expanded(child: Text(label, style: const TextStyle(color: AppColors.textLight, fontSize: 12))), Text(value, style: const TextStyle(color: AppColors.textDark, fontSize: 12, fontWeight: FontWeight.w600))]),
  );

  Widget _errorCard(String message) => Container(width: double.infinity, padding: const EdgeInsets.all(24), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22)), child: Column(children: [const Icon(Icons.error_outline, color: AppColors.sosRed, size: 48), const SizedBox(height: 12), const Text('Evidence unavailable', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)), const SizedBox(height: 8), Text(message, textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.textLight))]));

  String _dateTime(DateTime value) => '${value.day.toString().padLeft(2, '0')}/${value.month.toString().padLeft(2, '0')}/${value.year} ${value.hour.toString().padLeft(2, '0')}:${value.minute.toString().padLeft(2, '0')}';
  String _duration(Duration value) => '${value.inMinutes.toString().padLeft(2, '0')} min ${(value.inSeconds % 60).toString().padLeft(2, '0')} sec';
}
