import 'package:flutter/material.dart';

import '../../constants/app_colors.dart';
import '../../models/incident_record.dart';
import '../../services/incident_history_service.dart';
import '../authority/authority_access_screen.dart';

class IncidentHistoryScreen extends StatefulWidget {
  const IncidentHistoryScreen({super.key});

  @override
  State<IncidentHistoryScreen> createState() => _IncidentHistoryScreenState();
}

class _IncidentHistoryScreenState extends State<IncidentHistoryScreen> {
  late Future<List<IncidentRecord>> _historyFuture;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  void _loadHistory() {
    _historyFuture = IncidentHistoryService.instance.getAll();
  }

  String _date(DateTime value) =>
      '${value.day.toString().padLeft(2, '0')} ${_month(value.month)} ${value.year}';

  String _month(int month) => const [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ][month - 1];

  String _time(DateTime value) =>
      '${((value.hour - 1) % 12) + 1}:${value.minute.toString().padLeft(2, '0')} ${value.hour >= 12 ? 'PM' : 'AM'}';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppColors.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Incident History', style: TextStyle(color: AppColors.textDark, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: FutureBuilder<List<IncidentRecord>>(
          future: _historyFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            final incidents = snapshot.data ?? [];
            return RefreshIndicator(
              onRefresh: () async => setState(_loadHistory),
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Your Incidents', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 5),
                    const Text('View your previous emergency records', style: TextStyle(color: AppColors.textLight, fontSize: 13)),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: _statCard('Total', '${incidents.length}', Icons.folder_copy_outlined, AppColors.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard('Evidence', '${incidents.fold<int>(0, (sum, i) => sum + (i.videoPath != null ? 1 : 0) + (i.audioPath != null ? 1 : 0) + (i.locations.isNotEmpty ? 1 : 0))}', Icons.video_library_outlined, AppColors.pink)),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard('Shared', '0', Icons.share_outlined, Colors.green)),
                      ],
                    ),
                    const SizedBox(height: 25),
                    const Text('Recent Incidents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textDark)),
                    const SizedBox(height: 12),
                    if (incidents.isEmpty)
                      _emptyState()
                    else
                      ...incidents.map((incident) => Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _incidentCard(
                              context: context,
                              incident: incident,
                              date: _date(incident.startedAt),
                              time: _time(incident.startedAt),
                            ),
                          )),
                    const SizedBox(height: 13),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
                      child: const Row(
                        children: [
                          Icon(Icons.security, color: AppColors.primary, size: 28),
                          SizedBox(width: 13),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Your evidence is protected', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
                            SizedBox(height: 5),
                            Text('Incident records and evidence are linked to their unique Incident ID.', style: TextStyle(fontSize: 12, color: AppColors.textLight)),
                          ])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20)),
        child: const Column(
          children: [
            Icon(Icons.history_outlined, size: 48, color: AppColors.textLight),
            SizedBox(height: 12),
            Text('No emergency records yet', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
            SizedBox(height: 5),
            Text('Completed SOS sessions will appear here automatically.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppColors.textLight)),
          ],
        ),
      );

  Widget _statCard(String title, String value, IconData icon, Color color) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(17)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(icon, color: color, size: 22),
          const SizedBox(height: 10),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
          Text(title, style: const TextStyle(fontSize: 11, color: AppColors.textLight)),
        ]),
      );

  Widget _incidentCard({required BuildContext context, required IncidentRecord incident, required String date, required String time}) {
    return GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AuthorityAccessScreen(initialIncidentId: incident.id))),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(17),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))]),
        child: Column(children: [
          Row(children: [
            Container(padding: const EdgeInsets.all(11), decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.shield_outlined, color: AppColors.primary)),
            const SizedBox(width: 13),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Incident Record', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textDark)),
              const SizedBox(height: 4),
              Text(incident.id, style: const TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.w600)),
            ])),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ]),
          const SizedBox(height: 15),
          const Divider(height: 1),
          const SizedBox(height: 14),
          Row(children: [Expanded(child: _detailItem(Icons.calendar_today_outlined, date)), Expanded(child: _detailItem(Icons.access_time, time))]),
          const SizedBox(height: 12),
          _detailItem(Icons.location_on_outlined, incident.locationLabel),
          const SizedBox(height: 12),
          Row(children: [
            const Icon(Icons.verified, size: 16, color: Colors.green),
            const SizedBox(width: 6),
            Text('${incident.videoPath != null ? 'Video' : ''}${incident.audioPath != null ? ' • Audio' : ''}${incident.locations.isNotEmpty ? ' • GPS' : ''}', style: const TextStyle(fontSize: 11, color: Colors.green, fontWeight: FontWeight.w600)),
          ]),
        ]),
      ),
    );
  }

  Widget _detailItem(IconData icon, String text) => Row(children: [Icon(icon, size: 16, color: AppColors.textLight), const SizedBox(width: 7), Expanded(child: Text(text, style: const TextStyle(fontSize: 11, color: AppColors.textLight), overflow: TextOverflow.ellipsis))]);
}
