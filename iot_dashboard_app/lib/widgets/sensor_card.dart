import 'package:flutter/material.dart';
import '../models/master_data_model.dart';

class SensorCard extends StatelessWidget {
  final MasterData node;
  const SensorCard({required this.node});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NodeID: ${node.nodeId}', style: TextStyle(fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Text('Timestamp: ${node.timestamp}'),
            SizedBox(height: 5),
            Text('TGS2620: ${node.tgs2620}, TGS2602: ${node.tgs2602}, TGS2600: ${node.tgs2600}'),
            Text('Drift2620: ${node.drift2620}, Drift2602: ${node.drift2602}, Drift2600: ${node.drift2600}'),
            Text('Var2620: ${node.var2620}, Var2602: ${node.var2602}, Var2600: ${node.var2600}'),
            Text('Flat2620: ${node.flat2620}, Flat2602: ${node.flat2602}, Flat2600: ${node.flat2600}'),
            Text('Uptime: ${node.uptimeSec}, Jitter: ${node.jitterMs}, RSSI: ${node.rssiDbm}'),
            Text('CPU Temp: ${node.cpuTempC}, Free Heap: ${node.freeHeapBytes}'),
          ],
        ),
      ),
    );
  }
}
