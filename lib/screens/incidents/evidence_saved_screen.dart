import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/incident_record.dart';
import '../authority/authority_access_screen.dart';

class EvidenceSavedScreen extends StatelessWidget {
  final IncidentRecord incident;
  const EvidenceSavedScreen({super.key, required this.incident});

  @override
  Widget build(BuildContext context) {
    final hasVideo = incident.videoPath != null && incident.videoPath!.isNotEmpty;
    final hasAudio = incident.audioPath != null && incident.audioPath!.isNotEmpty;
    final hasLocation = incident.locations.isNotEmpty;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            const SizedBox(height: 34),
            Center(child: Container(width: 88, height: 88, decoration: BoxDecoration(color: Colors.green.withOpacity(.12), shape: BoxShape.circle), child: const Icon(Icons.fact_check_outlined, size: 48, color: Colors.green))),
            const SizedBox(height: 22),
            const Text('Emergency Ended', textAlign: TextAlign.center, style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textDark)),
            const SizedBox(height: 9),
            const Text('Your incident record has been created. Review the evidence summary below. Evidence details remain behind the Authority Access step.', textAlign: TextAlign.center, style: TextStyle(fontSize: 14, height: 1.5, color: AppColors.textLight)),
            const SizedBox(height: 26),
            Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Incident Reference', style: TextStyle(color: AppColors.textLight, fontSize: 12)),
              const SizedBox(height: 6),
              SelectableText(incident.id, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.primary)),
              const SizedBox(height: 6),
              const Text('Keep this ID. It is required to look up this incident.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
              const SizedBox(height: 18),
              _row(Icons.videocam_outlined, 'Video recording', hasVideo, hasVideo ? 'Recording available' : 'Not recorded'),
              _row(Icons.mic_none, 'Audio recording', hasAudio, hasAudio ? 'Recording available' : 'Not recorded'),
              _row(Icons.location_on_outlined, 'Location points', hasLocation, hasLocation ? '${incident.locations.length} point(s) recorded' : 'No location points recorded'),
            ])),
            const SizedBox(height: 18),
            Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: AppColors.primary.withOpacity(.07), borderRadius: BorderRadius.circular(16)), child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(Icons.lock_outline, color: AppColors.primary), SizedBox(width: 10), Expanded(child: Text('For privacy, this screen only confirms the incident record and capture summary. Enter the Incident ID in Authority Access before opening the detailed evidence view.', style: TextStyle(fontSize: 12, height: 1.45, color: AppColors.textDark)))])),
            const SizedBox(height: 22),
            SizedBox(height: 54, child: ElevatedButton.icon(onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => AuthorityAccessScreen(initialIncidentId: incident.id))), icon: const Icon(Icons.admin_panel_settings_outlined), label: const Text('Continue to Authority Access'), style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15))))),
            const SizedBox(height: 10),
            TextButton(onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst), child: const Text('Return to Home')),
          ]),
        ),
      ),
    );
  }

  Widget _row(IconData icon, String title, bool available, String status) => Padding(padding: const EdgeInsets.only(top: 13), child: Row(children: [Icon(icon, color: available ? Colors.green : Colors.grey), const SizedBox(width: 11), Expanded(child: Text(title, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.textDark))), Text(status, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: available ? Colors.green : Colors.grey))]));
}
