import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/incident_record.dart';
import 'incident_location_screen.dart';
import 'evidence_viewer_screen.dart';

class IncidentDetailsScreen extends StatelessWidget {
  final IncidentRecord incident;

  const IncidentDetailsScreen({super.key, required this.incident});

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${_month(value.month)} ${value.year}';

  String _month(int month) => const [
        'January', 'February', 'March', 'April', 'May', 'June',
        'July', 'August', 'September', 'October', 'November', 'December'
      ][month - 1];

  String _time(DateTime value) =>
      '${((value.hour - 1) % 12) + 1}:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';

  String _duration(Duration duration) =>
      '${duration.inMinutes.toString().padLeft(2, '0')} min ${(duration.inSeconds % 60).toString().padLeft(2, '0')} sec';

  void _openEvidence(BuildContext context, EvidenceType type) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EvidenceViewerScreen(
          incident: incident,
          type: type,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasVideo = incident.videoPath != null;
    final hasAudio = incident.audioPath != null;
    final hasLocation = incident.locations.isNotEmpty;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark), onPressed: () => Navigator.pop(context)),
        title: const Text('Incident Details', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 5, 20, 30),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(gradient: const LinearGradient(colors: [AppColors.primary, AppColors.primaryDark]), borderRadius: BorderRadius.circular(22)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white.withOpacity(0.15), shape: BoxShape.circle), child: const Icon(Icons.fingerprint, color: Colors.white, size: 28)),
                  const Spacer(),
                  Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6), decoration: BoxDecoration(color: Colors.green.withOpacity(0.20), borderRadius: BorderRadius.circular(8)), child: const Text('COMPLETED', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold))),
                ]),
                const SizedBox(height: 16),
                const Text('Incident ID', style: TextStyle(color: Colors.white70, fontSize: 12)),
                const SizedBox(height: 5),
                Text(incident.id, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                const Text('Unique identifier for this incident', style: TextStyle(color: Colors.white70, fontSize: 12)),
              ]),
            ),
            const SizedBox(height: 22),
            const Text('Incident Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            _infoCard(),
            const SizedBox(height: 22),
            const Text('Captured Evidence', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 12),
            _evidenceCard(context, icon: Icons.videocam, title: 'Video Evidence', subtitle: hasVideo ? 'Video recording captured' : 'Video recording unavailable', iconColor: AppColors.sosRed, available: hasVideo, onTap: hasVideo ? () => _openEvidence(context, EvidenceType.video) : null),
            const SizedBox(height: 10),
            _evidenceCard(context, icon: Icons.mic, title: 'Audio Evidence', subtitle: hasAudio ? 'Audio recording captured' : 'Audio recording unavailable', iconColor: AppColors.primary, available: hasAudio, onTap: hasAudio ? () => _openEvidence(context, EvidenceType.audio) : null),
            const SizedBox(height: 10),
            _evidenceCard(context, icon: Icons.location_on, title: 'Location Data', subtitle: hasLocation ? '${incident.locations.length} GPS point(s) recorded' : 'GPS data unavailable', iconColor: Colors.green, available: hasLocation, onTap: hasLocation ? () => Navigator.push(context, MaterialPageRoute(builder: (_) => IncidentLocationScreen(incident: incident))) : null),
            const SizedBox(height: 22),
            Container(width: double.infinity, padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [Icon(Icons.verified_user, color: Colors.green), SizedBox(width: 10), Text('Evidence Security', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark))]),
              SizedBox(height: 12),
              Text('Evidence is linked to the incident record and securely preserved for authorized access.', style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.5)),
              SizedBox(height: 14),
              Row(children: [Icon(Icons.lock_outline, size: 16, color: Colors.green), SizedBox(width: 7), Text('Secure storage', style: TextStyle(fontSize: 12, color: AppColors.textDark)), Spacer(), Icon(Icons.check_circle, size: 16, color: Colors.green), SizedBox(width: 5), Text('Verified', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold))]),
            ])),
            const SizedBox(height: 22),
            OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.download_outlined), label: const Text('Export Incident Record'), style: OutlinedButton.styleFrom(foregroundColor: AppColors.primary, minimumSize: const Size(double.infinity, 54), side: const BorderSide(color: AppColors.primary), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)))),
          ]),
        ),
      ),
    );
  }

  Widget _infoCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: Column(children: [
          _infoRow(Icons.calendar_today_outlined, 'Date', _date(incident.startedAt)),
          const Divider(height: 24),
          _infoRow(Icons.access_time, 'Time', _time(incident.startedAt)),
          const Divider(height: 24),
          _infoRow(Icons.location_on_outlined, 'Location', incident.locationLabel),
          const Divider(height: 24),
          _infoRow(Icons.timer_outlined, 'Duration', _duration(incident.duration)),
        ]),
      );

  Widget _infoRow(IconData icon, String title, String value) => Row(children: [
        Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(color: AppColors.primary.withOpacity(0.10), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: AppColors.primary, size: 20)),
        const SizedBox(width: 12),
        Expanded(child: Text(title, style: const TextStyle(color: AppColors.textLight, fontSize: 13))),
        Flexible(child: Text(value, textAlign: TextAlign.right, style: const TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold, fontSize: 13))),
      ]);

  Widget _evidenceCard(BuildContext context, {required IconData icon, required String title, required String subtitle, required Color iconColor, required bool available, required VoidCallback? onTap}) => GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18)),
          child: Row(children: [
            Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: iconColor.withOpacity(0.10), borderRadius: BorderRadius.circular(13)), child: Icon(icon, color: iconColor, size: 23)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)), const SizedBox(height: 4), Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textLight))])),
            if (available) const Icon(Icons.play_circle_outline, color: AppColors.primary, size: 27) else const Icon(Icons.error_outline, color: Colors.grey, size: 23),
          ]),
        ),
      );
}
