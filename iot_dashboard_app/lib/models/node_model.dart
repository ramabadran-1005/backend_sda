// lib/models/node_model.dart

class NodeModel {
  final String nodeId;

  // sensor readings
  final double tgs2620;
  final double tgs2602;
  final double tgs2600;

  // quality metrics
  final double drift2620;
  final double drift2602;
  final double drift2600;

  final double var2620;
  final double var2602;
  final double var2600;

  final double flat2620;
  final double flat2602;
  final double flat2600;

  // device metrics
  final int uptimeSec;
  final double jitterMs;
  final int rssi;
  final double cpuTemp;
  final int freeHeap;

  // time
  final String timestamp;

  NodeModel({
    required this.nodeId,
    required this.tgs2620,
    required this.tgs2602,
    required this.tgs2600,
    required this.drift2620,
    required this.drift2602,
    required this.drift2600,
    required this.var2620,
    required this.var2602,
    required this.var2600,
    required this.flat2620,
    required this.flat2602,
    required this.flat2600,
    required this.uptimeSec,
    required this.jitterMs,
    required this.rssi,
    required this.cpuTemp,
    required this.freeHeap,
    required this.timestamp,
  });

  factory NodeModel.fromJson(Map<String, dynamic> json) {
    double d(v) => v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;
    int i(v) => v is num ? v.toInt() : int.tryParse(v.toString()) ?? 0;

    return NodeModel(
      nodeId: json['NodeID']?.toString() ?? json['nodeId']?.toString() ?? "",

      tgs2620: d(json['TGS2620'] ?? json['tgs2620']),
      tgs2602: d(json['TGS2602'] ?? json['tgs2602']),
      tgs2600: d(json['TGS2600'] ?? json['tgs2600']),

      drift2620: d(json['Drift2620']),
      drift2602: d(json['Drift2602']),
      drift2600: d(json['Drift2600']),

      var2620: d(json['Var2620']),
      var2602: d(json['Var2602']),
      var2600: d(json['Var2600']),

      flat2620: d(json['Flat2620']),
      flat2602: d(json['Flat2602']),
      flat2600: d(json['Flat2600']),

      uptimeSec: i(json['Uptime_sec']),
      jitterMs: d(json['Jitter_ms']),
      rssi: i(json['RSSI_dBm']),
      cpuTemp: d(json['CPU_Temp_C']),
      freeHeap: i(json['FreeHeap_bytes']),

      timestamp: json['Timestamp']?.toString() ??
          json['timestamp']?.toString() ??
          '',
    );
  }
}
