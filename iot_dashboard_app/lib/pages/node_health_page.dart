// lib/pages/node_health_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../styles.dart';

class NodeHealthPage extends StatefulWidget {
  const NodeHealthPage({super.key});
  @override
  State<NodeHealthPage> createState() => _NodeHealthPageState();
}

class _NodeHealthPageState extends State<NodeHealthPage> {
  @override
  void initState() {
    super.initState();
    Provider.of<AppState>(context, listen: false).loadNodeHealth();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingNodeHealth) return const Center(child: CircularProgressIndicator());
    if (s.nodeHealth.isEmpty) return const Center(child: Text('No node health records'));
    return RefreshIndicator(
      onRefresh: () async => Provider.of<AppState>(context, listen: false).loadNodeHealth(),
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: s.nodeHealth.length,
        itemBuilder: (ctx, i) {
          final n = s.nodeHealth[i];
          final id = n['NodeID'] ?? n['nodeId'] ?? 'NA';
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: accentYellow, child: Text(id.toString().substring(0, id.toString().length > 2 ? 2 : 1))),
              title: Text('Node $id'),
              subtitle: Text('Readings: ${n['readingCount'] ?? 0} • Uptime: ${n['uptimeSec'] ?? 0}s'),
              trailing: ElevatedButton(onPressed: () => Provider.of<AppState>(context, listen: false).loadNodeHealth(), style: ElevatedButton.styleFrom(backgroundColor: primaryGreen), child: const Text('Refresh')),
            ),
          );
        },
      ),
    );
  }
}
