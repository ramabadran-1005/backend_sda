import 'package:flutter/material.dart';
import '../models/master_data_model.dart';

class SensorTile extends StatelessWidget {
  final MasterData node;
  const SensorTile({super.key, required this.node});

  Color getColor(num v) {
    if (v > 80) return Colors.red;
    if (v > 50) return Colors.orange;
    return Colors.green;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: getColor(node.tgs2620),
                  child: const Icon(Icons.sensors, color: Colors.white),
                ),
                const SizedBox(width: 8),
                Text("Node ${node.nodeId}",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            Text("TGS2620: ${node.tgs2620}"),
            Text("TGS2602: ${node.tgs2602}"),
            Text("TGS2600: ${node.tgs2600}"),
          ],
        ),
      ),
    );
  }
}
