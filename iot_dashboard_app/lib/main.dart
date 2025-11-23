// lib/main.dart
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';
import 'package:google_fonts/google_fonts.dart';

const String API_BASE = 'http://10.100.75.165:4000'; // change only if needed
const Color primaryGreen = Color(0xFF184D19);
const Color accentYellow = Color(0xFFFFC107);

void main() => runApp(const NWarehouseApp());

class NWarehouseApp extends StatelessWidget {
  const NWarehouseApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NWarehouse Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        textTheme: GoogleFonts.poppinsTextTheme(),
        scaffoldBackgroundColor: const Color(0xFFF8F8F8),
        colorScheme: ColorScheme.fromSeed(seedColor: primaryGreen),
      ),
      home: const DashboardShell(),
    );
  }
}

/* -------------------- Helpers -------------------- */
Future<List<dynamic>> getList(String path) async {
  try {
    final res = await http.get(Uri.parse('$API_BASE$path'));
    if (res.statusCode == 200) return json.decode(res.body) as List<dynamic>;
  } catch (e) {
    debugPrint('GET $path error: $e');
  }
  return [];
}

Future<Map<String, dynamic>?> postJson(String path, Map<String, dynamic> body) async {
  try {
    final r = await http.post(Uri.parse('$API_BASE$path'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(body));
    if (r.statusCode == 200 || r.statusCode == 201) return json.decode(r.body) as Map<String, dynamic>;
  } catch (e) {
    debugPrint('POST $path error: $e');
  }
  return null;
}

int parseIntSafe(dynamic v) {
  if (v == null) return 0;
  if (v is int) return v;
  if (v is double) return v.toInt();
  return int.tryParse(v.toString()) ?? 0;
}

double parseDoubleSafe(dynamic v) {
  if (v == null) return 0.0;
  if (v is double) return v;
  if (v is int) return v.toDouble();
  return double.tryParse(v.toString()) ?? 0.0;
}

String parseStringSafe(dynamic v) {
  if (v == null) return '';
  return v.toString();
}

/// Numeric NodeID parser (format type 1 as confirmed)
/// - first digit = warehouse (1 digit)
/// - next two digits = slot (2 digits)
/// - remaining digits = node id
Map<String, int> parseNodeIdNumeric(String id) {
  final s = id.trim();
  if (s.isEmpty) return {'warehouse': 0, 'slot': 0, 'node': 0};
  final digits = RegExp(r'^\d+$').hasMatch(s) ? s : s.replaceAll(RegExp(r'\D+'), '');
  if (digits.length < 1) return {'warehouse': 0, 'slot': 0, 'node': 0};
  final w = int.tryParse(digits.substring(0, 1)) ?? 0;
  if (digits.length == 1) return {'warehouse': w, 'slot': 0, 'node': 0};
  if (digits.length == 2) {
    final slot = int.tryParse(digits.substring(1, 2)) ?? 0;
    return {'warehouse': w, 'slot': slot, 'node': 0};
  }
  // digits length >= 3
  final slot = int.tryParse(digits.substring(1, digits.length >= 3 ? 3 : digits.length)) ?? 0;
  final node = digits.length > 3 ? int.tryParse(digits.substring(3)) ?? 0 : (digits.length == 3 ? int.tryParse(digits.substring(2)) ?? 0 : 0);
  return {'warehouse': w, 'slot': slot, 'node': node};
}

/* -------------------- Dashboard Shell -------------------- */
class DashboardShell extends StatefulWidget {
  const DashboardShell({super.key});
  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  String activePage = 'Overview';
  final pages = <String, Widget>{
    'Overview': const OverviewPage(),
    'Warehouse': const WarehousePage(),
    'Slots': const SlotsPage(),
    'Nodes': const NodesPage(),
    'Node Health': const NodeHealthPage(),
    'Predictions': const PredictionsPage(),
    'Alerts': const AlertsPage(),
    'Reports': const ReportsPage(),
    'Charts': const ChartsPage(),
  };

  @override
  Widget build(BuildContext context) {
    final current = pages[activePage]!;
    return Scaffold(
      body: Row(children: [
        // Sidebar
        Container(
          width: 240,
          color: primaryGreen,
          child: Column(children: [
            const SizedBox(height: 28),
            Text('NWarehouse',
                style: GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.bold, color: accentYellow)),
            const SizedBox(height: 22),
            ...pages.keys.map((k) {
              final sel = k == activePage;
              return ListTile(
                leading: Icon(Icons.circle, size: 10, color: sel ? accentYellow : Colors.white54),
                title: Text(k, style: TextStyle(color: sel ? accentYellow : Colors.white70)),
                onTap: () => setState(() => activePage = k),
              );
            }).toList(),
            const Spacer(),
            const Divider(color: Colors.white24),
            const ListTile(
              leading: CircleAvatar(radius: 16, backgroundColor: accentYellow, child: Icon(Icons.person, color: primaryGreen)),
              title: Text('Admin', style: TextStyle(color: Colors.white)),
              subtitle: Text('SuperUser', style: TextStyle(color: Colors.white70)),
            ),
            const SizedBox(height: 12),
          ]),
        ),

        // Content
        Expanded(
          child: Column(children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text(activePage, style: GoogleFonts.poppins(fontSize: 20, color: primaryGreen, fontWeight: FontWeight.w600)),
                ElevatedButton.icon(
                  onPressed: () => setState(() {}),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Refresh'),
                  style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black),
                )
              ]),
            ),
            Expanded(child: current),
          ]),
        )
      ]),
    );
  }
}

/* -------------------- Overview -------------------- */
class OverviewPage extends StatefulWidget {
  const OverviewPage({super.key});
  @override
  State<OverviewPage> createState() => _OverviewPageState();
}

class _OverviewPageState extends State<OverviewPage> {
  bool loading = true;
  int totalNodes = 0;
  int totalAlerts = 0;
  int totalPredictions = 0;
  int totalReports = 0;

  Future<void> load() async {
    setState(() => loading = true);
    final nodehealth = await getList('/api/nodehealth');
    final alerts = await getList('/api/alerts');
    final preds = await getList('/api/predictions/latest');
    final reps = await getList('/api/reports');

    // fallback to masterdata to estimate nodes if necessary
    if (nodehealth.isEmpty) {
      final md = await getList('/api/masterdata');
      final nodesSet = <String>{};
      for (var r in md) {
        final id = parseStringSafe(r['NodeID'] ?? r['nodeId']);
        if (id.isNotEmpty) nodesSet.add(id);
      }
      totalNodes = nodesSet.length;
    } else {
      totalNodes = nodehealth.length;
    }

    totalAlerts = alerts.length;
    totalPredictions = preds.length;
    totalReports = reps.length;
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Widget statCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(10), color: color.withOpacity(0.08)),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, size: 36, color: color),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color)),
        Text(title, style: const TextStyle(color: Colors.black54)),
      ]),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    return Padding(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: [
          statCard('Nodes', totalNodes.toString(), Icons.sensors, primaryGreen),
          statCard('Alerts', totalAlerts.toString(), Icons.warning, Colors.redAccent),
          statCard('Predictions', totalPredictions.toString(), Icons.analytics, accentYellow),
          statCard('Reports', totalReports.toString(), Icons.file_copy, Colors.teal),
        ],
      ),
    );
  }
}

/* -------------------- Warehouse Page -------------------- */
class WarehousePage extends StatefulWidget {
  const WarehousePage({super.key});
  @override
  State<WarehousePage> createState() => _WarehousePageState();
}

class _WarehousePageState extends State<WarehousePage> {
  List preds = [];
  List warehouses = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    // prefer predictions endpoint to compute warehouse metrics
    preds = await getList('/api/predictions/latest');
    if (preds.isEmpty) {
      // fallback: compute heuristics from masterdata
      final master = await getList('/api/masterdata');
      final Map<String, Map<String, dynamic>> latest = {};
      for (var r in master) {
        final idRaw = parseStringSafe(r['NodeID'] ?? r['nodeId']);
        if (idRaw.isEmpty) continue;
        if (!latest.containsKey(idRaw)) latest[idRaw] = r;
        else {
          try {
            final a = DateTime.tryParse(parseStringSafe(r['Timestamp'] ?? r['timestamp'] ?? '')) ?? DateTime(1970);
            final b = DateTime.tryParse(parseStringSafe(latest[idRaw]!['Timestamp'] ?? latest[idRaw]!['timestamp'] ?? '')) ?? DateTime(1970);
            if (a.isAfter(b)) latest[idRaw] = r;
          } catch (_) {}
        }
      }
      preds = [];
      for (var kv in latest.entries) {
        final r = kv.value;
        final t1 = parseDoubleSafe(r['TGS2620'] ?? r['tgs2620']);
        final t2 = parseDoubleSafe(r['TGS2602'] ?? r['tgs2602']);
        final t3 = parseDoubleSafe(r['TGS2600'] ?? r['tgs2600']);
        final denom = [t1, t2, t3].reduce((a, b) => a > b ? a : b);
        final d = denom > 0 ? denom : 1.0;
        final raw = 0.4 * (t1 / d) + 0.3 * (t2 / d) + 0.3 * (t3 / d);
        final riskScore = (raw * 100.0).clamp(0.0, 100.0);
        preds.add({
          'nodeId': kv.key,
          'tgs2620': t1,
          'tgs2602': t2,
          'tgs2600': t3,
          'riskScore': riskScore,
          'timestamp': r['Timestamp'] ?? r['timestamp'] ?? '',
          'createdAt': DateTime.now().toIso8601String()
        });
      }
    } else {
      preds = preds.map((p) {
        double r = parseDoubleSafe(p['riskScore'] ?? p['risk'] ?? p['risk_score'] ?? 0.0);
        if (r <= 1.0 && r >= 0.0) r = r * 100.0;
        p['riskScore'] = r;
        return p;
      }).toList();
    }

    // build a list of unique warehouses (by parsed nodeid)
    final Map<int, List<dynamic>> whMap = {};
    for (var p in preds) {
      final id = parseStringSafe(p['nodeId']?.toString() ?? p['NodeID']?.toString() ?? '');
      if (id.isEmpty) continue;
      final parsed = parseNodeIdNumeric(id);
      final w = parsed['warehouse'] ?? 0;
      whMap.putIfAbsent(w, () => []);
      whMap[w]!.add(p);
    }
    warehouses = whMap.entries.map((e) {
      final nodes = e.value;
      final avg = nodes.isEmpty ? 0.0 : nodes.map((n) => parseDoubleSafe(n['riskScore'])).reduce((a, b) => a + b) / nodes.length;
      return {'warehouse': e.key, 'avg': avg, 'count': nodes.length};
    }).toList();
    warehouses.sort((a, b) => (a['warehouse'] as int).compareTo(b['warehouse'] as int));
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  Widget warehouseTile(Map w) {
    final int wid = w['warehouse'] ?? 0;
    final double avg = parseDoubleSafe(w['avg']);
    final bool active = avg < 80; // just an example; you said green if active else red
    final color = active ? primaryGreen : Colors.redAccent;
    return InkWell(
      onTap: () {
        // navigate to Slots page and set global filter via Navigator push
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => SlotsPage(filterWarehouse: wid.toString())));
      },
      child: Card(
        child: SizedBox(
          height: 120,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            // gauge in the middle
            SizedBox(
              width: 100,
              height: 80,
              child: SfRadialGauge(axes: [
                RadialAxis(minimum: 0, maximum: 100, showLabels: false, showTicks: false, ranges: [
                  GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
                  GaugeRange(startValue: 30, endValue: 60, color: accentYellow),
                  GaugeRange(startValue: 60, endValue: 80, color: Colors.orange),
                  GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
                ], pointers: [NeedlePointer(value: avg)], annotations: [
                  GaugeAnnotation(widget: Text('${avg.toStringAsFixed(0)}%', style: TextStyle(color: color, fontWeight: FontWeight.bold)), positionFactor: 0.8)
                ])
              ]),
            ),
            const SizedBox(height: 4),
            Text('Warehouse $wid', style: const TextStyle(fontWeight: FontWeight.bold)),
            Text('${w['count']} nodes', style: const TextStyle(color: Colors.black54)),
          ]),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (warehouses.isEmpty) return const Center(child: Text('No warehouses found'));
    // display warehouses in a grid with icons in the middle
    return Padding(
      padding: const EdgeInsets.all(12),
      child: GridView.count(crossAxisCount: 3, crossAxisSpacing: 12, mainAxisSpacing: 12, children: warehouses.map((w) => warehouseTile(w as Map)).toList()),
    );
  }
}

/* -------------------- Slots Page -------------------- */
class SlotsPage extends StatefulWidget {
  final String? filterWarehouse; // optional pre-filter when navigated from WarehousePage
  const SlotsPage({super.key, this.filterWarehouse});
  @override
  State<SlotsPage> createState() => _SlotsPageState();
}

class _SlotsPageState extends State<SlotsPage> {
  List slots = [];
  bool loading = true;
  String? warehouseFilter;

  Future<void> load() async {
    setState(() => loading = true);
    final preds = await getList('/api/predictions/latest');
    final master = await getList('/api/masterdata');

    // choose source: preds then master
    final rows = preds.isNotEmpty ? preds : master;
    final Map<int, Map<int, List<dynamic>>> map = {};
    for (var r in rows) {
      final id = parseStringSafe(r['nodeId']?.toString() ?? r['NodeID']?.toString() ?? '');
      if (id.isEmpty) continue;
      final parsed = parseNodeIdNumeric(id);
      final w = parsed['warehouse'] ?? 0;
      final s = parsed['slot'] ?? 0;
      if (widget.filterWarehouse != null && widget.filterWarehouse!.isNotEmpty) {
        final fw = int.tryParse(widget.filterWarehouse!) ?? -1;
        if (fw != -1 && fw != w) continue;
      }
      map.putIfAbsent(w, () => {});
      map[w]!.putIfAbsent(s, () => []);
      map[w]![s]!.add(r);
    }

    final out = <Map<String, dynamic>>[];
    for (final w in map.keys) {
      final sm = map[w]!;
      for (final s in sm.keys) {
        final nodes = sm[s]!;
        final avg = nodes.isEmpty ? 0.0 : nodes.map((n) => parseDoubleSafe(n['riskScore'])).reduce((a, b) => a + b) / nodes.length;
        out.add({'warehouse': w, 'slot': s, 'avg': avg, 'count': nodes.length});
      }
    }
    out.sort((a, b) {
      final aw = a['warehouse'] as int;
      final bw = b['warehouse'] as int;
      final as = a['slot'] as int;
      final bs = b['slot'] as int;
      if (aw != bw) return aw.compareTo(bw);
      return as.compareTo(bs);
    });

    slots = out;
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    warehouseFilter = widget.filterWarehouse;
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (slots.isEmpty) return const Center(child: Text('No slots found'));
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: slots.length,
        itemBuilder: (_, i) {
          final s = slots[i];
          final avg = parseDoubleSafe(s['avg']);
          final color = avg > 80 ? Colors.red : avg > 50 ? Colors.orange : primaryGreen;
          return Card(
            child: ListTile(
              leading: SizedBox(width: 60, child: SfRadialGauge(axes: [
                RadialAxis(minimum: 0, maximum: 100, showLabels: false, showTicks: false, pointers: [NeedlePointer(value: avg)], ranges: [
                  GaugeRange(startValue: 0, endValue: 30, color: Colors.green),
                  GaugeRange(startValue: 30, endValue: 60, color: accentYellow),
                  GaugeRange(startValue: 60, endValue: 80, color: Colors.orange),
                  GaugeRange(startValue: 80, endValue: 100, color: Colors.red),
                ])
              ])),
              title: Text('Warehouse ${s['warehouse']} - Slot ${s['slot']}'),
              subtitle: Text('${s['count']} nodes • Avg ${avg.toStringAsFixed(1)}%'),
              trailing: ElevatedButton(
                onPressed: () {
                  // navigate to Nodes page filtered
                  Navigator.of(context).push(MaterialPageRoute(builder: (_) => NodesPage(filterWarehouse: s['warehouse'].toString(), filterSlot: s['slot'].toString())));
                },
                child: const Text('Open'),
                style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* -------------------- Nodes Page -------------------- */
class NodesPage extends StatefulWidget {
  final String? filterWarehouse;
  final String? filterSlot;
  const NodesPage({super.key, this.filterWarehouse, this.filterSlot});
  @override
  State<NodesPage> createState() => _NodesPageState();
}

class _NodesPageState extends State<NodesPage> {
  List nodes = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    final preds = await getList('/api/predictions/latest');
    final master = await getList('/api/masterdata');
    final rows = preds.isNotEmpty ? preds : master;

    final Map<String, dynamic> map = {};
    for (var r in rows) {
      final idRaw = parseStringSafe(r['nodeId']?.toString() ?? r['NodeID']?.toString() ?? '');
      if (idRaw.isEmpty) continue;
      final parsed = parseNodeIdNumeric(idRaw);
      final w = parsed['warehouse']?.toString() ?? '0';
      final s = parsed['slot']?.toString() ?? '0';
      if (widget.filterWarehouse != null && widget.filterWarehouse!.isNotEmpty && widget.filterWarehouse != w) continue;
      if (widget.filterSlot != null && widget.filterSlot!.isNotEmpty && widget.filterSlot != s) continue;
      final nodeKey = idRaw;
      map[nodeKey] = r; // latest
    }

    nodes = map.entries.map((e) {
      final r = e.value;
      final score = parseDoubleSafe(r['riskScore'] ?? r['risk']);
      return {'nodeId': e.key, 'score': score, 'row': r};
    }).toList();

    nodes.sort((a, b) => (a['nodeId'] as String).compareTo(b['nodeId'] as String));
    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (nodes.isEmpty) return const Center(child: Text('No nodes found'));
    return Padding(
      padding: const EdgeInsets.all(12),
      child: ListView.builder(
        itemCount: nodes.length,
        itemBuilder: (_, i) {
          final n = nodes[i];
          final nodeId = n['nodeId'];
          final score = parseDoubleSafe(n['score']);
          final color = score > 80 ? Colors.red : score > 50 ? Colors.orange : primaryGreen;
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: color, child: Text(nodeId.toString().substring(0, nodeId.toString().length > 2 ? 2 : 1))),
              title: Text('Node $nodeId'),
              subtitle: Text('Risk ${score.toStringAsFixed(1)}%'),
              trailing: ElevatedButton(
                onPressed: () {
                  // open node detail page (simple dialog with row)
                  showDialog(context: context, builder: (_) {
                    final row = n['row'] ?? {};
                    return AlertDialog(
                      title: Text('Node $nodeId'),
                      content: SizedBox(
                        width: 500,
                        child: SingleChildScrollView(
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text('Risk: ${score.toStringAsFixed(2)}%'),
                            const SizedBox(height: 8),
                            Text('TGS2620: ${row['tgs2620'] ?? row['TGS2620'] ?? ''}'),
                            Text('TGS2602: ${row['tgs2602'] ?? row['TGS2602'] ?? ''}'),
                            Text('TGS2600: ${row['tgs2600'] ?? row['TGS2600'] ?? ''}'),
                            Text('Drift2620: ${row['Drift2620'] ?? ''}'),
                            Text('Var2620: ${row['Var2620'] ?? ''}'),
                            Text('Flat2620: ${row['Flat2620'] ?? ''}'),
                            Text('Uptime_sec: ${row['Uptime_sec'] ?? ''}'),
                            Text('Jitter_ms: ${row['Jitter_ms'] ?? ''}'),
                            Text('RSSI_dBm: ${row['RSSI_dBm'] ?? ''}'),
                            Text('CPU_Temp_C: ${row['CPU_Temp_C'] ?? ''}'),
                            Text('FreeHeap_bytes: ${row['FreeHeap_bytes'] ?? ''}'),
                          ]),
                        ),
                      ),
                      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
                    );
                  });
                },
                child: const Text('Details'),
                style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black),
              ),
            ),
          );
        },
      ),
    );
  }
}

/* -------------------- Node Health -------------------- */
class NodeHealthPage extends StatefulWidget {
  const NodeHealthPage({super.key});
  @override
  State<NodeHealthPage> createState() => _NodeHealthPageState();
}

class _NodeHealthPageState extends State<NodeHealthPage> {
  List nodes = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    try {
      await postJson('/api/nodehealth/refresh', {});
    } catch (_) {}
    nodes = await getList('/api/nodehealth');

    // fallback to masterdata
    if (nodes.isEmpty) {
      final master = await getList('/api/masterdata');
      final map = <String, Map<String, dynamic>>{};
      for (var r in master) {
        final id = parseStringSafe(r['NodeID'] ?? r['nodeId']);
        if (id.isEmpty) continue;
        map.putIfAbsent(id, () => {'NodeID': id, 'readingCount': 0, 'uptimeSec': r['Uptime_sec'] ?? 0});
        map[id]!['readingCount'] = (map[id]!['readingCount'] as int) + 1;
        if (r['Uptime_sec'] != null) map[id]!['uptimeSec'] = r['Uptime_sec'];
      }
      nodes = map.values.map((v) {
        v['updatedAt'] = DateTime.now().toIso8601String();
        return v;
      }).toList();
    }

    setState(() => loading = false);
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (nodes.isEmpty) return const Center(child: Text('No node health records'));
    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: nodes.length,
        itemBuilder: (ctx, i) {
          final n = nodes[i];
          final id = n['NodeID'] ?? n['nodeId'] ?? n['_id'] ?? 'NA';
          final score = parseDoubleSafe(n['score'] ?? n['riskScore']);
          final color = score > 80 ? Colors.red : score > 50 ? Colors.orange : primaryGreen;
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: accentYellow, child: Text(id.toString().substring(0, id.toString().length > 2 ? 2 : 1))),
              title: Text('Node $id'),
              subtitle: Text('Readings: ${n['readingCount'] ?? 0} • Uptime: ${n['uptimeSec'] ?? 0}s'),
              trailing: ElevatedButton(onPressed: load, style: ElevatedButton.styleFrom(backgroundColor: primaryGreen), child: const Text('Refresh')),
            ),
          );
        },
      ),
    );
  }
}

/* -------------------- Predictions -------------------- */
class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});
  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  List preds = [];
  bool loading = true;

  Future<void> load() async {
    setState(() => loading = true);
    preds = await getList('/api/predictions/latest');
    if (preds.isEmpty) {
      // fallback - compute from masterdata
      final master = await getList('/api/masterdata');
      final latest = <String, dynamic>{};
      for (var r in master) {
        final id = parseStringSafe(r['NodeID'] ?? r['nodeId']);
        if (id.isEmpty) continue;
        if (!latest.containsKey(id)) latest[id] = r;
        else {
          try {
            final a = DateTime.tryParse(parseStringSafe(r['Timestamp'] ?? r['timestamp'] ?? '')) ?? DateTime(1970);
            final b = DateTime.tryParse(parseStringSafe(latest[id]['Timestamp'] ?? latest[id]['timestamp'] ?? '')) ?? DateTime(1970);
            if (a.isAfter(b)) latest[id] = r;
          } catch (_) {}
        }
      }
      preds = [];
      for (var e in latest.entries) {
        final r = e.value;
        final t1 = parseDoubleSafe(r['TGS2620']);
        final t2 = parseDoubleSafe(r['TGS2602']);
        final t3 = parseDoubleSafe(r['TGS2600']);
        final denom = [t1, t2, t3].reduce((a, b) => a > b ? a : b);
        final d = denom > 0 ? denom : 1.0;
        final raw = 0.4 * (t1 / d) + 0.3 * (t2 / d) + 0.3 * (t3 / d);
        final risk = (raw * 100.0).clamp(0.0, 100.0);
        preds.add({'nodeId': e.key, 'tgs2620': t1, 'tgs2602': t2, 'tgs2600': t3, 'riskScore': risk, 'timestamp': r['Timestamp'] ?? ''});
      }
    } else {
      preds = preds.map((p) {
        double r = parseDoubleSafe(p['riskScore'] ?? p['risk'] ?? p['risk_score'] ?? 0.0);
        if (r <= 1.0 && r >= 0.0) r = r * 100.0;
        p['riskScore'] = r;
        return p;
      }).toList();
    }
    setState(() => loading = false);
  }

  Future<void> requestPrediction(dynamic row) async {
    final seq = [
      [parseDoubleSafe(row['TGS2620'] ?? row['tgs2620']), parseDoubleSafe(row['TGS2602'] ?? row['tgs2602']), parseDoubleSafe(row['TGS2600'] ?? row['tgs2600'])]
    ];
    final payload = {'sequence': seq, 'nodeId': row['NodeID'] ?? row['nodeId'] ?? row['nodeId']};
    await postJson('/api/predictions/predict', payload);
    await load();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
    if (preds.isEmpty) return const Center(child: Text('No predictions'));
    return RefreshIndicator(
      onRefresh: load,
      child: ListView.builder(
        padding: const EdgeInsets.all(12),
        itemCount: preds.length,
        itemBuilder: (ctx, i) {
          final p = preds[i];
          final nodeId = p['nodeId'] ?? p['NodeID'] ?? 'NA';
          final score = parseDoubleSafe(p['riskScore']);
          final status = score > 80 ? 'Critical' : score > 50 ? 'High' : score > 20 ? 'Medium' : 'Healthy';
          final color = score > 80 ? Colors.red : score > 50 ? Colors.orange : score > 20 ? accentYellow : primaryGreen;
          return Card(
            child: ListTile(
              leading: CircleAvatar(backgroundColor: color, child: Text(nodeId.toString().substring(0, nodeId.toString().length > 2 ? 2 : 1))),
              title: Text('Node $nodeId'),
              subtitle: Text('Risk ${score.toStringAsFixed(1)}%  • $status'),
              trailing: IconButton(icon: const Icon(Icons.refresh), onPressed: () => requestPrediction(p)),
            ),
          );
        },
      ),
    );
  }
}

/* -------------------- Alerts -------------------- */
class AlertsPage extends StatefulWidget {
  const AlertsPage({super.key});
  @override
  State<AlertsPage> createState() => _AlertsPageState();
}

class _AlertsPageState extends State<AlertsPage> {
  List alerts = [];
  bool loading = true;
  final nodeCtrl = TextEditingController();
  final sensorCtrl = TextEditingController();

  Future<void> load() async {
    setState(() => loading = true);
    alerts = await getList('/api/alerts');

    // fallback: create sample from masterdata if empty
    if (alerts.isEmpty) {
      final m = await getList('/api/masterdata');
      if (m.isNotEmpty) {
        final row = m.first;
        final node = parseStringSafe(row['NodeID'] ?? row['nodeId']);
        await postJson('/api/alerts', {'nodeId': node.isEmpty ? 'unknown' : node, 'sensorType': 'TGS2620', 'message': 'generated sample', 'timestamp': DateTime.now().toIso8601String()});
        alerts = await getList('/api/alerts');
      }
    }

    setState(() => loading = false);
  }

  Future<void> createAlert() async {
    final node = nodeCtrl.text.isEmpty ? 'unknown' : nodeCtrl.text;
    final sensor = sensorCtrl.text.isEmpty ? 'unknown' : sensorCtrl.text;
    await postJson('/api/alerts', {'nodeId': node, 'sensorType': sensor, 'timestamp': DateTime.now().toIso8601String()});
    nodeCtrl.clear();
    sensorCtrl.clear();
    await load();
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    nodeCtrl.dispose();
    sensorCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
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
              Align(alignment: Alignment.centerRight, child: ElevatedButton(onPressed: createAlert, child: const Text('Create Alert')))
            ]),
          ),
        ),
        const SizedBox(height: 12),
        Expanded(child: ListView.builder(itemCount: alerts.length, itemBuilder: (ctx, i) {
          final a = alerts[i];
          final node = parseStringSafe(a['nodeId'] ?? a['NodeID'] ?? '');
          final sensor = parseStringSafe(a['sensorType'] ?? a['sensor'] ?? '');
          final ts = parseStringSafe(a['timestamp'] ?? a['createdAt'] ?? '');
          return Card(child: ListTile(leading: const Icon(Icons.report_problem, color: Colors.redAccent), title: Text('$sensor • Node $node'), subtitle: Text(ts)));
        }))
      ]),
    );
  }
}

/* -------------------- Reports -------------------- */
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});
  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  List reports = [];
  bool loading = true;

  DateTime? fromDate;
  DateTime? toDate;
  String reportType = 'warehouse'; // warehouse | slot | node | all
  final idCtrl = TextEditingController(); // id filter (warehouse id or slot or node depending on selection)

  Future<void> load() async {
    setState(() => loading = true);
    reports = await getList('/api/reports');
    // fallback: create simple auto-report from masterdata
    if (reports.isEmpty) {
      final md = await getList('/api/masterdata');
      if (md.isNotEmpty) {
        final unique = <String>{};
        for (var r in md) {
          final id = parseStringSafe(r['NodeID'] ?? r['nodeId']);
          if (id.isNotEmpty) unique.add(id);
        }
        final auto = {'type': 'AutoReport', 'createdAt': DateTime.now().toIso8601String(), 'summary': {'totalReadings': md.length, 'uniqueNodes': unique.length}};
        reports = [auto];
      }
    }
    setState(() => loading = false);
  }

  Future<void> generate() async {
    // build payload
    final payload = <String, dynamic>{};
    if (fromDate != null) payload['from'] = fromDate!.toIso8601String();
    if (toDate != null) payload['to'] = toDate!.toIso8601String();
    payload['type'] = reportType;
    final idText = idCtrl.text.trim();
    if (idText.isNotEmpty) payload['id'] = idText;
    final res = await postJson('/api/reports/generate', payload);
    if (res != null && res['reportId'] != null) {
      // refresh
      await load();
      // show success
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Report generated')));
    } else {
      // fallback: produce client-side summary as dialog (if backend failed)
      final md = await getList('/api/masterdata');
      final summary = {'totalReadings': md.length, 'uniqueNodes': (md.map((e) => parseStringSafe(e['NodeID'] ?? e['nodeId'])).toSet()).length};
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Auto Report (fallback)'), content: Text('Total readings: ${summary['totalReadings']}\nUnique nodes: ${summary['uniqueNodes']}'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
    }
  }

  @override
  void initState() {
    super.initState();
    load();
  }

  @override
  void dispose() {
    idCtrl.dispose();
    super.dispose();
  }

  Widget dateButton(String label, DateTime? date, VoidCallback onTap) {
    return ElevatedButton(onPressed: onTap, style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black), child: Text(date == null ? label : '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}'));
  }

  @override
  Widget build(BuildContext context) {
    if (loading) return const Center(child: CircularProgressIndicator());
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
          ElevatedButton(onPressed: generate, style: ElevatedButton.styleFrom(backgroundColor: accentYellow, foregroundColor: Colors.black), child: const Text('Generate')),
          const SizedBox(width: 8),
          ElevatedButton(onPressed: load, child: const Text('Refresh')),
        ]),
        const SizedBox(height: 12),
        Expanded(child: reports.isEmpty ? const Center(child: Text('No reports')) : ListView.builder(itemCount: reports.length, itemBuilder: (ctx, i) {
          final r = reports[i];
          final summary = r['summary'] ?? {};
          return Card(child: ListTile(
            leading: const Icon(Icons.picture_as_pdf, color: Colors.teal),
            title: Text(r['type'] ?? 'Report'),
            subtitle: Text('Created: ${r['createdAt'] ?? r['createdAt'] ?? ''}\nSummary: ${summary.toString()}'),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              if (r['pdfUrl'] != null) IconButton(icon: const Icon(Icons.download), onPressed: () => _openUrl(r['pdfUrl'])),
              if (r['csvUrl'] != null) IconButton(icon: const Icon(Icons.table_chart), onPressed: () => _openUrl(r['csvUrl'])),
            ]),
          ));
        }))
      ]),
    );
  }

  void _openUrl(String url) {
    // For web Flutter, can use html.window.open but keep it simple: show dialog with URL
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Report URL'), content: SelectableText(url), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close'))]));
  }
}

/* -------------------- Charts -------------------- */
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
    master = await getList('/api/masterdata');
    final Set<String> set = {};
    for (var r in master) {
      final id = parseStringSafe(r['NodeID'] ?? r['nodeId']);
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
            future: getList('/api/masterdata?nodeId=$selectedNode'),
            builder: (_, snap) {
              if (!snap.hasData) return const Center(child: CircularProgressIndicator());
              final data = snap.data!;
              if (data.isEmpty) return const Center(child: Text('No data for selected node'));
              final s2620 = <FlSpot>[];
              final s2602 = <FlSpot>[];
              final s2600 = <FlSpot>[];
              for (int i = 0; i < data.length; i++) {
                s2620.add(FlSpot(i.toDouble(), parseDoubleSafe(data[i]['TGS2620'] ?? data[i]['tgs2620'])));
                s2602.add(FlSpot(i.toDouble(), parseDoubleSafe(data[i]['TGS2602'] ?? data[i]['tgs2602'])));
                s2600.add(FlSpot(i.toDouble(), parseDoubleSafe(data[i]['TGS2600'] ?? data[i]['tgs2600'])));
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
                            LineChartBarData(spots: s2620, isCurved: true, color: Colors.red, dotData: FlDotData(show: false)),
                            LineChartBarData(spots: s2602, isCurved: true, color: Colors.green, dotData: FlDotData(show: false)),
                            LineChartBarData(spots: s2600, isCurved: true, color: Colors.blue, dotData: FlDotData(show: false)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [legend(Colors.red, 'TGS2620'), legend(Colors.green, 'TGS2602'), legend(Colors.blue, 'TGS2600')]),
                  ]),
                ),
              );
            }),
        )
      ]),
    );
  }

  Widget legend(Color c, String name) => Row(children: [Container(width: 16, height: 8, color: c), const SizedBox(width: 6), Text(name)]);
}
