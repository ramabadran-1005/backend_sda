// lib/pages/charts_page.dart
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';

class ChartsPage extends StatefulWidget {
  const ChartsPage({super.key});
  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  List master = [];
  List<String> nodeOptions = [];
  String? selectedNode;
  bool loading = true;

  Future<void> loadNodes() async {
    setState(() => loading = true);
    final s = Provider.of<AppState>(context, listen: false);
    await s.loadMaster();
    master = s.masterData;
    final Set<String> set = {};
    for (var r in master) {
      final id = (r['NodeID'] ?? r['nodeId'] ?? '').toString();
      if (id.isNotEmpty) set.add(id);
    }
    nodeOptions = set.toList()..sort();
    if (selectedNode == null && nodeOptions.isNotEmpty) selectedNode = nodeOptions.first;
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    loadNodes();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Node: '),
          const SizedBox(width: 8),
          DropdownButton<String>(value: selectedNode, items: nodeOptions.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(), onChanged: (v) => setState(() => selectedNode = v))
        ]),
        const SizedBox(height: 12),
        Expanded(
          child: selectedNode == null ? const Center(child: Text('No node')) : FutureBuilder<List<dynamic>>(
            future: Provider.of<AppState>(context, listen: false).getMasterForNode(selectedNode!),
            builder: (_, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final data = snap.data!;
              if (data.isEmpty) return const Center(child: Text('No data for selected node'));
              final s2620 = <FlSpot>[];
              final s2602 = <FlSpot>[];
              final s2600 = <FlSpot>[];
              for (int i = 0; i < data.length; i++) {
                s2620.add(FlSpot(i.toDouble(), double.tryParse((data[i]['TGS2620'] ?? data[i]['tgs2620'] ?? 0).toString()) ?? 0.0));
                s2602.add(FlSpot(i.toDouble(), double.tryParse((data[i]['TGS2602'] ?? data[i]['tgs2602'] ?? 0).toString()) ?? 0.0));
                s2600.add(FlSpot(i.toDouble(), double.tryParse((data[i]['TGS2600'] ?? data[i]['tgs2600'] ?? 0).toString()) ?? 0.0));
              }
              return Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(children: [
                    SizedBox(
                      height: 320,
                      child: LineChart(
                        LineChartData(
                          gridData: FlGridData(show: true),
                          titlesData: FlTitlesData(show: false),
                          lineBarsData: [
                            LineChartBarData(spots: s2620, isCurved: true, dotData: FlDotData(show: false)),
                            LineChartBarData(spots: s2602, isCurved: true, dotData: FlDotData(show: false)),
                            LineChartBarData(spots: s2600, isCurved: true, dotData: FlDotData(show: false)),
                          ],
                        ),
                      ),
                    ),
                  ]),
                ),
              );
            }),
        )
      ]),
    );
  }
}
