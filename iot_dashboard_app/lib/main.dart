// lib/main.dart
// Simplified mobile app (Version B) - REST API based (no Firebase)
// Includes: Dashboard, Nodes, Node Health, Charts, Reports, ML Predictions, Live Nodes
// Uses: http, fl_chart
//
// Make sure pubspec.yaml has: http, fl_chart, intl, shared_preferences (optional)
// e.g.
// dependencies:
//   flutter:
//     sdk: flutter
//   http: ^1.5.0
//   fl_chart: ^0.70.2
//   intl: ^0.18.0
//   shared_preferences: ^2.1.1
//
// Replace API_BASE with your actual backend base URL if different.

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';

const String API_BASE = "https://backend-sda.onrender.com"; // update if needed

// -------------------- Model --------------------
class MasterData {
  final String id;
  final int nodeId;
  final double tgs2620;
  final double tgs2602;
  final double tgs2600;
  final String timestamp;
  final Map<String, dynamic> raw;

  MasterData({
    required this.id,
    required this.nodeId,
    required this.tgs2620,
    required this.tgs2602,
    required this.tgs2600,
    required this.timestamp,
    required this.raw,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v) {
      if (v == null) return 0;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? 0;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is double) return v;
      if (v is int) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    final node = parseInt(json['NodeID'] ?? json['nodeId'] ?? json['NodeId']);
    final t1 = parseDouble(json['TGS2620'] ?? json['tgs2620'] ?? json['tgs2620_raw']);
    final t2 = parseDouble(json['TGS2602'] ?? json['tgs2602']);
    final t3 = parseDouble(json['TGS2600'] ?? json['tgs2600']);
    final ts = json['Timestamp']?.toString() ??
        json['timestamp']?.toString() ??
        json['receivedAt']?.toString() ??
        '';

    return MasterData(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? UniqueKey().toString(),
      nodeId: node,
      tgs2620: t1,
      tgs2602: t2,
      tgs2600: t3,
      timestamp: ts,
      raw: json,
    );
  }
}

// -------------------- API Service --------------------
class ApiService {
  final String base;

  ApiService({this.base = API_BASE});

  Future<List<MasterData>> fetchMasterData({int limit = 500}) async {
    try {
      final uri = Uri.parse('$base/api/masterdata?limit=$limit');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      final List arr = json.decode(res.body) as List;
      return arr.map((e) => MasterData.fromJson(e as Map<String, dynamic>)).toList();
    } catch (e) {
      debugPrint('fetchMasterData error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchPredictions() async {
    try {
      final uri = Uri.parse('$base/api/predictions/latest');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      return json.decode(res.body) as List;
    } catch (e) {
      debugPrint('fetchPredictions error: $e');
      return [];
    }
  }

  Future<List<dynamic>> fetchReports() async {
    try {
      final uri = Uri.parse('$base/api/reports');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      return json.decode(res.body) as List;
    } catch (e) {
      debugPrint('fetchReports error: $e');
      return [];
    }
  }

  Future<bool> createReport({Map<String, dynamic>? body}) async {
    try {
      final uri = Uri.parse('$base/api/reports/generate');
      final res = await http.post(uri,
          headers: {'Content-Type': 'application/json'},
          body: json.encode(body ?? {'type': 'FullMasterdataReport', 'fullDump': true})).timeout(const Duration(seconds: 15));
      return res.statusCode == 201 || res.statusCode == 200;
    } catch (e) {
      debugPrint('createReport error: $e');
      return false;
    }
  }

  Future<List<dynamic>> fetchAlerts() async {
    try {
      final uri = Uri.parse('$base/api/alerts?limit=100');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return [];
      return json.decode(res.body) as List;
    } catch (e) {
      debugPrint('fetchAlerts error: $e');
      return [];
    }
  }

  /// Optional: call /api/live-nodes if server supports it (you added this earlier).
  Future<Map<String, dynamic>?> fetchLiveNodesFromServer({int windowSec = 15}) async {
    try {
      final uri = Uri.parse('$base/api/live-nodes?window=$windowSec');
      final res = await http.get(uri).timeout(const Duration(seconds: 10));
      if (res.statusCode != 200) return null;
      return json.decode(res.body) as Map<String, dynamic>;
    } catch (e) {
      debugPrint('fetchLiveNodesFromServer error: $e');
      return null;
    }
  }
}

// -------------------- App --------------------
void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nwarehouse Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.teal),
      home: const DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final ApiService api = ApiService();
  int liveNodeCount = 0;
  int masterCount = 0;
  int alertsCount = 0;
  int predsCount = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _refreshStats();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _refreshStats());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    final m = await api.fetchMasterData(limit: 500);
    final a = await api.fetchAlerts();
    final p = await api.fetchPredictions();

    setState(() {
      masterCount = m.length;
      alertsCount = a.length;
      predsCount = p.length;
      liveNodeCount = _computeLiveNodesCountFromMaster(m, windowMs: 60000);
    });
  }

  int _computeLiveNodesCountFromMaster(List<MasterData> m, {int windowMs = 60000}) {
    final now = DateTime.now().millisecondsSinceEpoch;
    final Map<int, int> lastSeen = {};
    for (final e in m) {
      final id = e.nodeId;
      final ts = _parseTimestampMillis(e);
      if (ts > 0) {
        final prev = lastSeen[id] ?? 0;
        if (ts > prev) lastSeen[id] = ts;
      }
    }
    return lastSeen.entries.where((kv) => now - kv.value < windowMs).length;
  }

  int _parseTimestampMillis(MasterData e) {
    try {
      if (e.raw.containsKey('receivedAt') && e.raw['receivedAt'] is String) {
        final dt = DateTime.tryParse(e.raw['receivedAt'])?.millisecondsSinceEpoch;
        if (dt != null && dt > 0) return dt;
      }
      final cand = e.raw['Timestamp'] ?? e.raw['timestamp'] ?? e.timestamp;
      if (cand == null) return 0;
      final dt = DateTime.tryParse(cand.toString())?.millisecondsSinceEpoch;
      if (dt != null) return dt;
    } catch (_) {}
    return 0;
  }

  void _openDrawerPage(Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nwarehouse Mobile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshStats,
          )
        ],
      ),
      drawer: Drawer(
        child: SafeArea(
          child: Column(
            children: [
              DrawerHeader(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text('Nwarehouse', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                    SizedBox(height: 6),
                    Text('Mobile Dashboard', style: TextStyle(fontSize: 12)),
                  ],
                ),
              ),
              ListTile(
                leading: const Icon(Icons.dashboard),
                title: const Text('Dashboard'),
                onTap: () => Navigator.pop(context),
              ),
              ListTile(
                leading: const Icon(Icons.device_hub),
                title: const Text('Nodes'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerPage(const NodeListPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.health_and_safety),
                title: const Text('Node Health'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerPage(const NodeHealthPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.show_chart),
                title: const Text('Charts'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerPage(const ChartsPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.flash_on),
                title: const Text('Live Nodes'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerPage(const LiveNodesPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.article),
                title: const Text('Reports'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerPage(const ReportsPage());
                },
              ),
              ListTile(
                leading: const Icon(Icons.psychology),
                title: const Text('ML Predictions'),
                onTap: () {
                  Navigator.pop(context);
                  _openDrawerPage(const MLPage());
                },
              ),
            ],
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refreshStats(),
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.sensors, color: Colors.teal),
                title: const Text('Master Data Records'),
                subtitle: Text('$masterCount'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.warning, color: Colors.red),
                title: const Text('Alerts'),
                subtitle: Text('$alertsCount'),
              ),
            ),
            Card(
              child: ListTile(
                leading: const Icon(Icons.assessment, color: Colors.orange),
                title: const Text('Latest Predictions'),
                subtitle: Text('$predsCount'),
              ),
            ),
            GestureDetector(
              onTap: () => _openDrawerPage(const LiveNodesPage()),
              child: Card(
                color: Colors.deepPurple.shade50,
                child: ListTile(
                  leading: const Icon(Icons.flash_on, color: Colors.deepPurple),
                  title: const Text('Live Nodes'),
                  subtitle: Text('Active now: $liveNodeCount'),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Recent nodes (preview)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            FutureBuilder<List<MasterData>>(
              future: ApiService().fetchMasterData(limit: 25),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data ?? [];
                return Column(
                  children: list.map((e) {
                    return Card(
                      child: ListTile(
                        title: Text('Node ${e.nodeId}'),
                        subtitle: Text('TGS2620: ${e.tgs2620} | TGS2602: ${e.tgs2602}'),
                        trailing: Text(_formatTs(e.timestamp)),
                        onTap: () {
                          _openDrawerPage(NodeDetailPage(nodeId: e.nodeId));
                        },
                      ),
                    );
                  }).toList(),
                );
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

String _formatTs(String ts) {
  try {
    final dt = DateTime.tryParse(ts);
    if (dt == null) return ts.isEmpty ? '--' : ts;
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(dt.toLocal());
  } catch (e) {
    return ts;
  }
}

// -------------------- Node List --------------------
class NodeListPage extends StatefulWidget {
  const NodeListPage({super.key});

  @override
  State<NodeListPage> createState() => _NodeListPageState();
}

class _NodeListPageState extends State<NodeListPage> {
  final ApiService api = ApiService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Nodes')),
      body: FutureBuilder<List<MasterData>>(
        future: api.fetchMasterData(limit: 1000),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final nodes = (snap.data ?? []).map((e) => e.nodeId).toSet().toList()..sort();
          return ListView.builder(
            itemCount: nodes.length,
            itemBuilder: (_, i) => ListTile(
              title: Text('Node ${nodes[i]}'),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (_) => NodeDetailPage(nodeId: nodes[i])));
              },
            ),
          );
        },
      ),
    );
  }
}

// -------------------- Node Detail --------------------
class NodeDetailPage extends StatelessWidget {
  final int nodeId;
  const NodeDetailPage({required this.nodeId, super.key});

  @override
  Widget build(BuildContext context) {
    final ApiService api = ApiService();
    return Scaffold(
      appBar: AppBar(title: Text('Node $nodeId')),
      body: FutureBuilder<List<MasterData>>(
        future: api.fetchMasterData(limit: 1000),
        builder: (context, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          final all = snap.data ?? [];
          final rows = all.where((e) => e.nodeId == nodeId).toList();
          if (rows.isEmpty) return const Center(child: Text('No data'));
          final latest = rows.first;
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Latest reading', style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Node: ${latest.nodeId}'),
                      Text('TGS2620: ${latest.tgs2620}'),
                      Text('TGS2602: ${latest.tgs2602}'),
                      Text('TGS2600: ${latest.tgs2600}'),
                      Text('Timestamp: ${_formatTs(latest.timestamp)}'),
                    ]),
                  ),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: () {
                    // Optionally: navigate to charts filtered by node
                    Navigator.of(context).push(MaterialPageRoute(builder: (_) => ChartsPage(initialNode: nodeId)));
                  },
                  child: const Text('Open Charts for this Node'),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}

// -------------------- Node Health --------------------
class NodeHealthPage extends StatefulWidget {
  const NodeHealthPage({super.key});

  @override
  State<NodeHealthPage> createState() => _NodeHealthPageState();
}

class _NodeHealthPageState extends State<NodeHealthPage> {
  final ApiService api = ApiService();
  String? selectedNode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Node Health')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            FutureBuilder<List<MasterData>>(
              future: api.fetchMasterData(limit: 500),
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final all = snap.data ?? [];
                final ids = all.map((e) => e.nodeId.toString()).toSet().toList()..sort();
                return DropdownButton<String>(
                  hint: const Text('Select Node'),
                  value: selectedNode,
                  items: ids.map((e) => DropdownMenuItem(value: e, child: Text('Node $e'))).toList(),
                  onChanged: (v) => setState(() => selectedNode = v),
                );
              },
            ),
            const SizedBox(height: 12),
            if (selectedNode != null)
              Expanded(
                child: FutureBuilder<List<MasterData>>(
                  future: api.fetchMasterData(limit: 1000),
                  builder: (context, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final all = snap.data ?? [];
                    final data = all.where((e) => e.nodeId.toString() == selectedNode).toList();
                    if (data.isEmpty) return const Text('No records found');
                    return ListView(
                      children: data.map((e) => Card(child: ListTile(
                        title: Text('TS: ${_formatTs(e.timestamp)}'),
                        subtitle: Text('TGS2620: ${e.tgs2620} | TGS2602: ${e.tgs2602}'),
                      ))).toList(),
                    );
                  },
                ),
              )
          ],
        ),
      ),
    );
  }
}

// -------------------- Charts Page --------------------
class ChartsPage extends StatefulWidget {
  final int? initialNode;
  const ChartsPage({this.initialNode, super.key});

  @override
  State<ChartsPage> createState() => _ChartsPageState();
}

class _ChartsPageState extends State<ChartsPage> {
  final ApiService api = ApiService();
  List<MasterData> master = [];
  List<int> nodeIds = [];
  int? selectedNode;
  Timer? _timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    selectedNode = widget.initialNode;
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);
    final m = await api.fetchMasterData(limit: 1000);
    final ids = m.map((e) => e.nodeId).toSet().toList()..sort();
    setState(() {
      master = m;
      nodeIds = ids;
      if (selectedNode == null && ids.isNotEmpty) selectedNode = ids.first;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final dataForNode = master.where((e) => e.nodeId == selectedNode).toList();
    // sort by timestamp ascending for charts
    dataForNode.sort((a, b) {
      final ta = DateTime.tryParse(a.timestamp)?.millisecondsSinceEpoch ?? 0;
      final tb = DateTime.tryParse(b.timestamp)?.millisecondsSinceEpoch ?? 0;
      return ta.compareTo(tb);
    });

    // prepare spots
    final List<FlSpot> s2620 = [];
    final List<FlSpot> s2602 = [];
    final List<FlSpot> s2600 = [];
    for (var i = 0; i < dataForNode.length; i++) {
      s2620.add(FlSpot(i.toDouble(), dataForNode[i].tgs2620));
      s2602.add(FlSpot(i.toDouble(), dataForNode[i].tgs2602));
      s2600.add(FlSpot(i.toDouble(), dataForNode[i].tgs2600));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sensor Charts')),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            if (nodeIds.isEmpty)
              const Text('No nodes available')
            else
              Row(
                children: [
                  Expanded(
                    child: DropdownButton<int>(
                      value: selectedNode,
                      isExpanded: true,
                      items: nodeIds.map((id) => DropdownMenuItem(value: id, child: Text('Node $id'))).toList(),
                      onChanged: (v) => setState(() => selectedNode = v),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _load,
                    child: const Icon(Icons.refresh),
                  )
                ],
              ),
            const SizedBox(height: 12),
            Expanded(
              child: loading
                  ? const Center(child: CircularProgressIndicator())
                  : dataForNode.isEmpty
                      ? const Center(child: Text('No data for selected node'))
                      : Card(
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: LineChart(
                              LineChartData(
                                gridData: FlGridData(show: true),
                                titlesData: FlTitlesData(show: true, bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false))),
                                borderData: FlBorderData(show: true),
                                minX: 0,
                                maxX: dataForNode.length > 0 ? (dataForNode.length - 1).toDouble() : 0,
                                lineBarsData: [
                                  LineChartBarData(spots: s2620, isCurved: true, dotData: FlDotData(show: false), color: Colors.red),
                                  LineChartBarData(spots: s2602, isCurved: true, dotData: FlDotData(show: false), color: Colors.blue),
                                  LineChartBarData(spots: s2600, isCurved: true, dotData: FlDotData(show: false), color: Colors.purple),
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------- REPORTS ----------------
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  final api = ApiService();
  late Future<List<dynamic>> futureReports;

  @override
  void initState() {
    super.initState();
    futureReports = api.fetchReports();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reports")),
      body: FutureBuilder<List<dynamic>>(
        future: futureReports,
        builder: (_, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final reports = snapshot.data!;
          if (reports.isEmpty) {
            return const Center(child: Text("No reports found"));
          }

          return ListView.builder(
            itemCount: reports.length,
            itemBuilder: (_, index) {
              final r = reports[index];

              final type = r["type"]?.toString() ?? "Unknown";
              final created = r["createdAt"]?.toString() ?? "--";

              return Card(
                margin: const EdgeInsets.all(10),
                child: ListTile(
                  title: Text("Report: $type"),
                  subtitle: Text(created),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await api.createReport();
          setState(() {
            futureReports = api.fetchReports();
          });
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}


// -------------------- ML Page --------------------
class MLPage extends StatefulWidget {
  const MLPage({super.key});

  @override
  State<MLPage> createState() => _MLPageState();
}

class _MLPageState extends State<MLPage> {
  final ApiService api = ApiService();
  List<dynamic> preds = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    load();
  }

  Future<void> load() async {
    setState(() => loading = true);
    final p = await api.fetchPredictions();
    setState(() {
      preds = p;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ML Predictions')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : preds.isEmpty
              ? const Center(child: Text('No predictions yet'))
              : ListView.builder(
                  itemCount: preds.length,
                  itemBuilder: (_, i) {
                    final r = preds[i] as Map<String, dynamic>;
                    final node = r['nodeId']?.toString() ?? 'unknown';
                    final score = (r['riskScore'] ?? r['risk'] ?? 0).toString();
                    return ListTile(title: Text('Node $node'), subtitle: Text('Risk: $score'));
                  },
                ),
    );
  }
}

// -------------------- Live Nodes Page --------------------
class LiveNodesPage extends StatefulWidget {
  const LiveNodesPage({super.key});

  @override
  State<LiveNodesPage> createState() => _LiveNodesPageState();
}

class _LiveNodesPageState extends State<LiveNodesPage> {
  final ApiService api = ApiService();
  List<int> liveNodes = [];
  bool loading = true;
  Timer? _timer;
  final int windowMs = 60000; // 60 seconds live window

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => loading = true);

    // Prefer server endpoint if available
    final fromServer = await api.fetchLiveNodesFromServer(windowSec: (windowMs ~/ 1000));
    if (fromServer != null && fromServer['nodes'] != null) {
      try {
        final nodes = (fromServer['nodes'] as List).map((e) {
          final nid = e['nodeId'] ?? e['NodeID'] ?? e['node'];
          return int.tryParse(nid?.toString() ?? '') ?? 0;
        }).where((id) => id > 0).toList();
        setState(() {
          liveNodes = nodes;
          loading = false;
        });
        return;
      } catch (_) {}
    }

    // Fallback: compute from masterdata
    final m = await api.fetchMasterData(limit: 2000);
    final now = DateTime.now().millisecondsSinceEpoch;
    final Map<int, int> lastSeen = {};
    for (final d in m) {
      final id = d.nodeId;
      final dt = DateTime.tryParse(d.timestamp)?.millisecondsSinceEpoch ?? 0;
      if (dt == 0 && d.raw.containsKey('receivedAt')) {
        final dt2 = DateTime.tryParse(d.raw['receivedAt']?.toString() ?? '')?.millisecondsSinceEpoch ?? 0;
        if (dt2 > 0) {
          if ((lastSeen[id] ?? 0) < dt2) lastSeen[id] = dt2;
          continue;
        }
      }
      if ((lastSeen[id] ?? 0) < dt) lastSeen[id] = dt;
    }
    final alive = lastSeen.entries.where((kv) => now - kv.value < windowMs).map((kv) => kv.key).toList();
    setState(() {
      liveNodes = alive;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Live Nodes')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : liveNodes.isEmpty
              ? const Center(child: Text('No active nodes right now'))
              : ListView.builder(
                  itemCount: liveNodes.length,
                  itemBuilder: (_, i) {
                    final id = liveNodes[i];
                    return Card(
                      margin: const EdgeInsets.all(10),
                      child: ListTile(
                        leading: const Icon(Icons.memory, color: Colors.green),
                        title: Text('Node $id'),
                        subtitle: const Text('Active within last 60 seconds'),
                        onTap: () {
                          Navigator.of(context).push(MaterialPageRoute(builder: (_) => NodeDetailPage(nodeId: id)));
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
