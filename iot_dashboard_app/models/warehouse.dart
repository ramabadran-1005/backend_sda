import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

// ---------------- RISK METER ----------------
Widget riskMeter(double riskValue, {String label = 'Risk'}) {
  Color color;
  if (riskValue < 30) color = Colors.green;
  else if (riskValue < 60) color = Colors.yellow;
  else if (riskValue < 80) color = Colors.orange;
  else color = Colors.red;

  return Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      SizedBox(
        height: 150,
        width: 150,
        child: SfRadialGauge(
          axes: [
            RadialAxis(
              minimum: 0,
              maximum: 100,
              showTicks: false,
              showLabels: false,
              ranges: [
                GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
                GaugeRange(startValue: 30, endValue: 60, color: Colors.yellow),
                GaugeRange(startValue: 60, endValue: 80, color: Colors.orange),
                GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
              ],
              pointers: [NeedlePointer(value: riskValue)],
              annotations: [
                GaugeAnnotation(
                  widget: Text(
                    "${riskValue.toStringAsFixed(1)}%",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color),
                  ),
                  angle: 90,
                  positionFactor: 0.7,
                )
              ],
            ),
          ],
        ),
      ),
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: color))
    ],
  );
}

// ---------------- WAREHOUSE PAGE ----------------
class WarehousePage extends StatefulWidget {
  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  Future<List<dynamic>> getPredictions() async {
    final url = Uri.parse('http://10.100.75.165:4000/api/predictions/latest');
    final res = await http.get(url);
    if (res.statusCode == 200) return json.decode(res.body);
    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Warehouse Overview")),
      body: SafeArea(
        child: FutureBuilder<List<dynamic>>(
          future: getPredictions(),
          builder: (context, snap) {
            if (!snap.hasData) return Center(child: CircularProgressIndicator());
            final preds = snap.data!;
            if (preds.isEmpty) return Center(child: Text("No data available"));

            // Build warehouse-slot-node hierarchy
            final Map<int, Map<int, List<dynamic>>> hierarchy = {};
            for (final p in preds) {
              final id = p['nodeId']?.toString() ?? '';
              final parsed = parseNodeId(id);
              final w = parsed['warehouse'];
              final s = parsed['slot'];
              hierarchy.putIfAbsent(w, () => {});
              hierarchy[w]!.putIfAbsent(s, () => []);
              hierarchy[w]![s]!.add(p);
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                children: hierarchy.entries.map((wh) {
                  final warehouseNum = wh.key;
                  final slotGroups = wh.value;

                  final allNodes = slotGroups.values.expand((e) => e).toList();
                  final avgRisk = allNodes.isEmpty
                      ? 0
                      : allNodes
                              .map((n) => (n['riskScore'] ?? 0.0) * 1.0)
                              .reduce((a, b) => a + b) /
                          allNodes.length;

                  return Card(
                    color: Colors.teal.shade50,
                    margin: const EdgeInsets.all(8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: ExpansionTile(
                      leading: riskMeter(avgRisk, label: "WH $warehouseNum"),
                      title: Text(
                        "Warehouse $warehouseNum",
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.teal.shade900),
                      ),
                      children: slotGroups.entries.map((sl) {
                        final slotNum = sl.key;
                        final slotNodes = sl.value;
                        final slotRisk = slotNodes.isEmpty
                            ? 0
                            : slotNodes
                                    .map((n) => (n['riskScore'] ?? 0.0) * 1.0)
                                    .reduce((a, b) => a + b) /
                                slotNodes.length;

                        return Card(
                          color: Colors.yellow.shade50,
                          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          child: ExpansionTile(
                            leading: riskMeter(slotRisk, label: "Slot $slotNum"),
                            title: Text("Slot $slotNum", style: TextStyle(fontWeight: FontWeight.w600, color: Colors.orange.shade800)),
                            children: slotNodes.map((n) {
                              final nodeRisk = (n['riskScore'] ?? 0.0) * 1.0;
                              final nodeId = n['nodeId']?.toString() ?? 'unknown';
                              return ListTile(
                                title: Text("Node $nodeId", style: TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text("Risk: ${nodeRisk.toStringAsFixed(1)}%"),
                                trailing: riskMeter(nodeRisk, label: ""),
                              );
                            }).toList(),
                          ),
                        );
                      }).toList(),
                    ),
                  );
                }).toList(),
              ),
            );
          },
        ),
      ),
    );
  }
}
