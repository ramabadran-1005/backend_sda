import 'package:flutter/material.dart';
import '../models/master_data_model.dart';

class NodeDetailScreen extends StatelessWidget {
  const NodeDetailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final node = ModalRoute.of(context)!.settings.arguments as MasterData;
    return Scaffold(
      appBar: AppBar(title: Text('Node ${node.nodeId}')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${node.name}'),
            Text('Location: ${node.location ?? "Unknown"}'),
            Text('CPU Temp: ${node.cpuTempC} °C'),
            Text('RSSI: ${node.rssiDbm} dBm'),
            Text('Uptime: ${node.uptimeSec} s'),
          ],
        ),
      ),
    );
  }
}
