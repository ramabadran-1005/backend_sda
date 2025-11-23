// lib/pages/reports_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../styles.dart';

class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  DateTime? fromDate;
  DateTime? toDate;
  String reportType = 'warehouse';
  final idCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<AppState>(context, listen: false).loadReports();
  }

  @override
  void dispose() {
    idCtrl.dispose();
    super.dispose();
  }

  Widget dateButton(String label, DateTime? date, VoidCallback onTap) => ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: Text(date == null ? label : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'));

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingReports) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          dateButton('From', fromDate, () async {
            final d = await showDatePicker(context: context, initialDate: fromDate ?? DateTime.now().subtract(const Duration(days: 7)), firstDate: DateTime(2020), lastDate: DateTime.now());
            if (d != null) setState(() => fromDate = d);
          }),
          const SizedBox(width: 8),
          dateButton('To', toDate, () async {
            final d = await showDatePicker(context: context, initialDate: toDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime.now());
            if (d != null) setState(() => toDate = d);
          }),
          const SizedBox(width: 12),
          DropdownButton<String>(value: reportType, items: ['warehouse', 'slot', 'node', 'all'].map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => reportType = v ?? 'warehouse')),
          const SizedBox(width: 12),
          SizedBox(width: 160, child: TextField(controller: idCtrl, decoration: const InputDecoration(labelText: 'Filter ID (optional)'))),
          const SizedBox(width: 12),
          ElevatedButton(onPressed: () => Provider.of<AppState>(context, listen: false).generateReport(fromDate, toDate, reportType, idCtrl.text).then((_) => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report generated')))), style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black), child: const Text('Generate')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: () => Provider.of<AppState>(context, listen: false).loadReports(), child: const Text('Refresh')),
        ]),
        const SizedBox(height: 12),
        Expanded(child: s.reports.isEmpty ? const Center(child: Text('No reports')) : ListView.builder(itemCount: s.reports.length, itemBuilder: (ctx, i) {
          final r = s.reports[i];
          final summary = r['summary'] ?? {};
          return Card(child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.teal),
            title: Text(r['type'] ?? 'Report'),
            subtitle: Text('Created: ${r['createdAt'] ?? ''}\nSummary: ${summary.toString()}'),
          ));
        }))
      ]),
    );
  }
}
