class MasterData {
  final int nodeId;
  final int tgs2620;
  final int tgs2602;
  final int tgs2600;
  final String drift2620;
  final String drift2602;
  final String drift2600;
  final String var2620;
  final String var2602;
  final String var2600;
  final String flat2620;
  final String flat2602;
  final String flat2600;
  final String uptimeSec;
  final String jitterMs;
  final String rssiDbm;
  final String cpuTempC;
  final String freeHeapBytes;
  final String timestamp;

  MasterData({
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
    required this.rssiDbm,
    required this.cpuTempC,
    required this.freeHeapBytes,
    required this.timestamp,
  });

  factory MasterData.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? 0;
      return 0;
    }

    final nodeId = parseInt(json['NodeID']);
    if (nodeId < 100) {
      throw Exception('Ignore nodeId < 100');
    }

    return MasterData(
      nodeId: nodeId,
      tgs2620: parseInt(json['TGS2620']),
      tgs2602: parseInt(json['TGS2602']),
      tgs2600: parseInt(json['TGS2600']),
      drift2620: json['Drift2620']?.toString() ?? 'None',
      drift2602: json['Drift2602']?.toString() ?? 'None',
      drift2600: json['Drift2600']?.toString() ?? 'None',
      var2620: json['Var2620']?.toString() ?? 'None',
      var2602: json['Var2602']?.toString() ?? 'None',
      var2600: json['Var2600']?.toString() ?? 'None',
      flat2620: json['Flat2620']?.toString() ?? 'None',
      flat2602: json['Flat2602']?.toString() ?? 'None',
      flat2600: json['Flat2600']?.toString() ?? 'None',
      uptimeSec: json['Uptime_sec']?.toString() ?? 'None',
      jitterMs: json['Jitter_ms']?.toString() ?? 'None',
      rssiDbm: json['RSSI_dBm']?.toString() ?? 'None',
      cpuTempC: json['CPU_Temp_C']?.toString() ?? 'None',
      freeHeapBytes: json['FreeHeap_bytes']?.toString() ?? 'None',
      timestamp: json['Timestamp']?.toString() ?? '',
    );
  }
}
