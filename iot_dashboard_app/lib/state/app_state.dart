// lib/state/app_state.dart
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class AppState extends ChangeNotifier {
  // top-level caches
  bool loadingOverview = true;
  bool loadingWarehouses = true;
  bool loadingSlots = true;
  bool loadingNodes = true;
  bool loadingNodeHealth = true;
  bool loadingPredictions = true;
  bool loadingAlerts = true;
  bool loadingReports = true;
  bool loadingMaster = true;

  List<dynamic> warehouses = [];
  List<dynamic> slots = [];
  List<dynamic> nodes = [];
  List<dynamic> nodeHealth = [];
  List<dynamic> predictions = [];
  List<dynamic> alerts = [];
  List<dynamic> reports = [];
  List<dynamic> masterData = [];

  // overview counts
  int totalNodes = 0;
  int totalAlerts = 0;
  int totalPredictions = 0;
  int totalReports = 0;

  // loaders
  Future<void> loadWarehouses() async {
    loadingWarehouses = true; notifyListeners();
    await loadPredictions(); // ensure preds loaded
    // if predictions present, build warehouses
    final map = <int, List<dynamic>>{};
    for (var p in predictions) {
      final id = (p['nodeId'] ?? p['NodeID'] ?? '').toString();
      if (id.isEmpty) continue;
      // parse numeric first digit as warehouse
      final w = int.tryParse(id[0]) ?? 0;
      map.putIfAbsent(w, () => []);
      map[w]!.add(p);
    }
    warehouses = map.entries.map((e) {
      final nodes = e.value;
      final avg = nodes.isEmpty ? 0.0 : nodes.map((n) => double.tryParse((n['riskScore'] ?? n['risk'] ?? 0).toString()) ?? 0.0).reduce((a, b) => a + b) / nodes.length;
      return {'warehouse': e.key, 'avg': avg, 'count': nodes.length};
    }).toList();
    warehouses.sort((a,b) => (a['warehouse'] as int).compareTo(b['warehouse'] as int));
    loadingWarehouses = false; notifyListeners();
  }

  Future<void> loadSlots([String? filterWarehouse]) async {
    loadingSlots = true; notifyListeners();
    final rows = predictions.isNotEmpty ? predictions : masterData;
    final map = <int, Map<int, List<dynamic>>>{};
    for (var r in rows) {
      final id = (r['nodeId'] ?? r['NodeID'] ?? r['NodeId'] ?? '').toString();
      if (id.isEmpty) continue;
      if (id.length < 4) continue; // treat <3 digits invalid
      final w = int.tryParse(id.substring(0,1)) ?? 0;
      final s = int.tryParse(id.substring(1,3)) ?? 0;
      if (filterWarehouse != null && filterWarehouse.isNotEmpty && int.tryParse(filterWarehouse) != w) continue;
      map.putIfAbsent(w, () => {});
      map[w]!.putIfAbsent(s, () => []);
      map[w]![s]!.add(r);
    }
    final out = <Map<String,dynamic>>[];
    for (final w in map.keys) {
      final sm = map[w]!;
      for (final s in sm.keys) {
        final nodes = sm[s]!;
        final avg = nodes.isEmpty ? 0.0 : nodes.map((n) => double.tryParse((n['riskScore'] ?? n['risk'] ?? 0).toString()) ?? 0.0).reduce((a,b)=>a+b)/nodes.length;
        out.add({'warehouse': w, 'slot': s, 'avg': avg, 'count': nodes.length});
      }
    }
    out.sort((a,b){
      if(a['warehouse']!=b['warehouse']) return (a['warehouse'] as int).compareTo(b['warehouse'] as int);
      return (a['slot'] as int).compareTo(b['slot'] as int);
    });
    slots = out;
    loadingSlots = false; notifyListeners();
  }

  Future<void> loadNodes([String? filterWarehouse, String? filterSlot]) async {
    loadingNodes = true; notifyListeners();
    final rows = predictions.isNotEmpty ? predictions : masterData;
    final Map<String, dynamic> map = {};
    for (var r in rows) {
      final id = (r['nodeId'] ?? r['NodeID'] ?? '').toString();
      if (id.isEmpty) continue;
      if (id.length < 4) continue;
      final w = id.substring(0,1);
      final s = id.substring(1,3);
      if (filterWarehouse != null && filterWarehouse.isNotEmpty && filterWarehouse != w) continue;
      if (filterSlot != null && filterSlot.isNotEmpty && filterSlot != s) continue;
      map[id] = r;
    }
    nodes = map.entries.map((e) {
      final r = e.value;
      final score = double.tryParse((r['riskScore'] ?? r['risk'] ?? 0).toString()) ?? 0.0;
      return {'nodeId': e.key, 'score': score, 'row': r};
    }).toList();
    nodes.sort((a,b) => (a['nodeId'] as String).compareTo(b['nodeId'] as String));
    loadingNodes = false; notifyListeners();
  }

  Future<void> loadNodeHealth() async {
    loadingNodeHealth = true; notifyListeners();
    final res = await ApiService.getList('/api/nodehealth');
    nodeHealth = res;
    // fallback: build from master data if empty
    if (nodeHealth.isEmpty) {
      await loadMaster();
      final map = <String, Map<String,dynamic>>{};
      for (var r in masterData) {
        final id = (r['NodeID'] ?? r['nodeId'] ?? '').toString();
        if (id.isEmpty) continue;
        map.putIfAbsent(id, ()=>{'NodeID': id, 'readingCount': 0, 'uptimeSec': r['Uptime_sec'] ?? 0});
        map[id]!['readingCount'] = (map[id]!['readingCount'] as int) + 1;
      }
      nodeHealth = map.values.toList();
    }
    loadingNodeHealth = false; notifyListeners();
  }

  Future<void> loadPredictions() async {
    loadingPredictions = true; notifyListeners();
    final res = await ApiService.getList('/api/predictions/latest');
    predictions = res.map((p){
      double r = double.tryParse((p['riskScore'] ?? p['risk'] ?? 0).toString()) ?? 0.0;
      if (r <= 1.0 && r >= 0.0) r = r * 100.0;
      p['riskScore'] = r;
      return p;
    }).toList();
    totalPredictions = predictions.length;
    loadingPredictions = false; notifyListeners();
  }

  Future<void> requestPrediction(dynamic row) async {
    await ApiService.post('/api/predictions/predict', {'sequence': [[row['TGS2620'] ?? row['tgs2620'] ?? 0, row['TGS2602'] ?? row['tgs2602'] ?? 0, row['TGS2600'] ?? row['tgs2600'] ?? 0]], 'nodeId': row['NodeID'] ?? row['nodeId']});
    await loadPredictions();
  }

  Future<void> loadAlerts() async {
    loadingAlerts = true; notifyListeners();
    alerts = await ApiService.getList('/api/alerts');
    totalAlerts = alerts.length;
    loadingAlerts = false; notifyListeners();
  }

  Future<void> createAlert(String nodeId, String sensorType) async {
    await ApiService.post('/api/alerts', {'nodeId': nodeId, 'sensorType': sensorType, 'timestamp': DateTime.now().toIso8601String()});
    await loadAlerts();
  }

  Future<void> loadReports() async {
    loadingReports = true; notifyListeners();
    reports = await ApiService.getList('/api/reports');
    totalReports = reports.length;
    loadingReports = false; notifyListeners();
  }

  Future<void> generateReport(DateTime? from, DateTime? to, String type, String id) async {
    final payload = <String, dynamic>{};
    if (from != null) payload['from'] = from.toIso8601String();
    if (to != null) payload['to'] = to.toIso8601String();
    payload['type'] = type;
    if (id.isNotEmpty) payload['id'] = id;
    await ApiService.post('/api/reports/generate', payload);
    await loadReports();
  }

  Future<void> loadMaster() async {
    loadingMaster = true; notifyListeners();
    masterData = await ApiService.getList('/api/masterdata');
    loadingMaster = false; notifyListeners();
  }

  Future<List<dynamic>> getMasterForNode(String nodeId) async {
    final res = await ApiService.getList('/api/masterdata?nodeId=$nodeId');
    return res;
  }

  // convenience for overview
  Future<void> loadOverview() async {
    loadingOverview = true; notifyListeners();
    await loadNodeHealth();
    await loadAlerts();
    await loadPredictions();
    await loadReports();
    totalNodes = nodeHealth.isNotEmpty ? nodeHealth.length : ((masterData.map((e)=> (e['NodeID'] ?? e['nodeId'] ?? '').toString()).toSet()).length);
    loadingOverview = false; notifyListeners();
  }

  // UI helper for node details dialog
  void showNodeDetails(BuildContext ctx, dynamic n) {
    showDialog(context: ctx, builder: (_) {
      final row = n['row'] ?? {};
      final score = (n['score'] ?? 0.0) as double;
      return AlertDialog(
        title: Text('Node ${n['nodeId']}'),
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
        actions: [TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Close'))],
      );
    });
  }

  // helper to call predictions request (used by UI)
  Future<void> requestPredictionFromUI(dynamic row) async {
    await requestPrediction(row);
  }
}
