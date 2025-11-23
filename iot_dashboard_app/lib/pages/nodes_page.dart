// lib/pages/nodes_page.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../styles.dart';

class NodesPage extends StatefulWidget {
  final String? filterWarehouse;
  final String? filterSlot;
  const NodesPage({super.key, this.filterWarehouse, this.filterSlot});
  @override
  State<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends State<NodesPage> {
  @override
  void initState() {
    super.initState();
    final s = Provider.of<AppState>(context, listen: false);
    s.loadNodes(widget.filterWarehouse, widget.filterSlot);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    if (s.loadingNodes) return const Center(child: CircularProgressIndicator());
    if (s.nodes.isEmpty) return const Center(child: Text('No nodes found'));
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: s.nodes.length,
        itemBuilder: (_, i) {
          final n = s.nodes[i];
          final nodeId = n['nodeId'];
          final score = (n['score'] ?? 0.0) as double;
          final color = score > 80 ? Colors.red : score > 50 ? Colors.orange : primaryGreen;
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: color, child: Text(nodeId.toString().substring(0, nodeId.toString().length > 2 ? 2 : 1))),
              title: Text('Node $nodeId'),
              subtitle: Text('Risk ${score.toStringAsFixed(1)}%'),
              trailing: ElevatedButton(
                onPressed: () => s.showNodeDetails(context, n),
                style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black),
                child: const Text('Details'),
              ),
            ),
          );
        },
      ),
    );
  }
}
