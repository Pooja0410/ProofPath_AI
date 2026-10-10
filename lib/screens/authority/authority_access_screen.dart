import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/incident_record.dart';
import '../../services/incident_history_service.dart';
import '../incidents/incident_details_screen.dart';

class AuthorityAccessScreen extends StatefulWidget {
  const AuthorityAccessScreen({super.key, this.initialIncidentId});

  final String? initialIncidentId;

  @override
  State<AuthorityAccessScreen> createState() => _AuthorityAccessScreenState();
}

class _AuthorityAccessScreenState extends State<AuthorityAccessScreen> {
  final TextEditingController _incidentController = TextEditingController();
  IncidentRecord? _verifiedIncident;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _incidentController.text = widget.initialIncidentId ?? '';
  }

  @override
  void dispose() {
    _incidentController.dispose();
    super.dispose();
  }

  Future<void> verifyIncident() async {
    final id = _incidentController.text.trim().toUpperCase();
    if (id.isEmpty) {
      _showMessage('Enter the Incident ID to continue.');
      return;
    }

    setState(() {
      _checking = true;
      _verifiedIncident = null;
    });

    final incidents = await IncidentHistoryService.instance.getAll();
    IncidentRecord? match;
    for (final incident in incidents) {
      if (incident.id.toUpperCase() == id) {
        match = incident;
        break;
      }
    }

    if (!mounted) return;
    setState(() {
      _checking = false;
      _verifiedIncident = match;
    });

    if (match == null) {
      _showMessage('No incident was found for that ID on this device. Check the ID and try again.');
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _openEvidence() {
    final incident = _verifiedIncident;
    if (incident == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => IncidentDetailsScreen(incident: incident)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final incident = _verifiedIncident;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Authority Access', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 82,
                  height: 82,
                  decoration: BoxDecoration(color: AppColors.primary.withOpacity(.10), shape: BoxShape.circle),
                  child: const Icon(Icons.admin_panel_settings_outlined, size: 43, color: AppColors.primary),
                ),
              ),
              const SizedBox(height: 18),
              const Text('Authorize Your Access', textAlign: TextAlign.center, style: TextStyle(fontSize: 23, fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 8),
              const Text(
                'To review emergency evidence, verify the unique Incident ID first. Once matched, you can open the video, audio and recorded location linked to that incident.',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textLight, fontSize: 13, height: 1.5),
              ),
              const SizedBox(height: 22),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Incident ID', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                  const SizedBox(height: 9),
                  TextField(
                    controller: _incidentController,
                    textCapitalization: TextCapitalization.characters,
                    onChanged: (_) {
                      if (_verifiedIncident != null) setState(() => _verifiedIncident = null);
                    },
                    decoration: InputDecoration(
                      hintText: 'PP-2026-000184',
                      prefixIcon: const Icon(Icons.fingerprint, color: AppColors.primary),
                      filled: true,
                      fillColor: AppColors.background,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppColors.primary, width: 1.5)),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton.icon(
                      onPressed: _checking ? null : verifyIncident,
                      icon: _checking
                          ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : const Icon(Icons.verified_user_outlined),
                      label: Text(_checking ? 'Checking Incident…' : 'Verify Incident ID'),
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                    ),
                  ),
                ]),
              ),
              const SizedBox(height: 18),
              if (incident != null) ...[
                Container(
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(color: Colors.green.withOpacity(.08), borderRadius: BorderRadius.circular(18), border: Border.all(color: Colors.green.withOpacity(.25))),
                  child: Row(children: [
                    const Icon(Icons.check_circle, color: Colors.green, size: 28),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('Incident ID Matched', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 4),
                      Text(incident.id, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
                    ])),
                  ]),
                ),
                const SizedBox(height: 16),
                const Text('Evidence Available', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                const SizedBox(height: 11),
                _evidenceTile(Icons.videocam_outlined, 'Video Evidence', incident.videoPath != null && incident.videoPath!.isNotEmpty ? 'Recording linked to this incident' : 'No video recording saved', AppColors.sosRed, incident.videoPath != null && incident.videoPath!.isNotEmpty),
                const SizedBox(height: 9),
                _evidenceTile(Icons.mic_none, 'Audio Evidence', incident.audioPath != null && incident.audioPath!.isNotEmpty ? 'Recording linked to this incident' : 'No audio recording saved', AppColors.primary, incident.audioPath != null && incident.audioPath!.isNotEmpty),
                const SizedBox(height: 9),
                _evidenceTile(Icons.location_on_outlined, 'Location Evidence', incident.locations.isNotEmpty ? '${incident.locations.length} GPS point(s) recorded' : 'No GPS points saved', Colors.green, incident.locations.isNotEmpty),
                const SizedBox(height: 16),
                SizedBox(
                  height: 54,
                  child: ElevatedButton.icon(
                    onPressed: _openEvidence,
                    icon: const Icon(Icons.lock_open_rounded),
                    label: const Text('Authorize & View Evidence'),
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryDark, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                  ),
                ),
              ],
              const SizedBox(height: 18),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.primary.withOpacity(.07), borderRadius: BorderRadius.circular(18)),
                child: const Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Icon(Icons.shield_outlined, color: AppColors.primary),
                  SizedBox(width: 11),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Evidence Access Notice', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    SizedBox(height: 5),
                    Text('Use this screen only when you are authorized to review the incident. This prototype checks records stored on this device; production authority verification must be enforced by a secure backend.', style: TextStyle(fontSize: 12, color: AppColors.textLight, height: 1.45)),
                  ])),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _evidenceTile(IconData icon, String title, String subtitle, Color color, bool available) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
      child: Row(children: [
        Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: color.withOpacity(.10), borderRadius: BorderRadius.circular(12)), child: Icon(icon, color: color)),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: AppColors.textLight)),
        ])),
        Icon(available ? Icons.check_circle : Icons.remove_circle_outline, color: available ? Colors.green : Colors.grey, size: 20),
      ]),
    );
  }
}
