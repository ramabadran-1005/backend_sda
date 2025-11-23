// lib/pages/alerts_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  final nodeCtrl = TextEditingController();
  final sensorCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    Provider.of<AppState>(context, listen: false).loadAlerts();
  }

  @override
  void dispose() {
    nodeCtrl.dispose();
    sensorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingAlerts) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Column(children: [
              Row(children: [
                Expanded(child: TextField(controller: nodeCtrl, decoration: const InputDecoration(labelText: 'NodeId'))),
                const SizedBox(width: 8),
                Expanded(child: TextField(controller: sensorCtrl, decoration: const InputDecoration(labelText: 'Sensor'))),
              ]),
              const SizedBox(height: 8),
              Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: () => Provider.of<AppState>(context, listen: false).createAlert(nodeCtrl.text, sensorCtrl.text).then((_) { nodeCtrl.clear(); sensorCtrl.clear(); }), child: const Text('Create Alert')))
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: ListView.builder(itemCount: s.alerts.length, itemBuilder: (ctx, i) {
          final a = s.alerts[i];
          final node = (a['nodeId'] ?? a['NodeID'] ?? '').toString();
          final sensor = (a['sensorType'] ?? a['sensor'] ?? '').toString();
          final ts = (a['timestamp'] ?? a['createdAt'] ?? '').toString();
          return Card(child: ListTile(leading: const Icon(Icons.report_problem, color: Colors.redAccent), title: Text('$sensor • Node $node'), subtitle: Text(ts)));
        }))
      ]),
    );
  }
}
