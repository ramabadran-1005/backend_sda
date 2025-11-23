// lib/models/prediction_model.dart

class PredictionModel {
  final String nodeId;
  final double riskScore;
  final double tgs2620;
  final double tgs2602;
  final double tgs2600;
  final String timestamp;
  final String status;
  final String modelUsed;

  PredictionModel({
    required this.nodeId,
    required this.riskScore,
    required this.tgs2620,
    required this.tgs2602,
    required this.tgs2600,
    required this.timestamp,
    required this.status,
    required this.modelUsed,
  });

  factory PredictionModel.fromJson(Map<String, dynamic> json) {
    double d(v) => v is num ? v.toDouble() : double.tryParse(v.toString()) ?? 0.0;

    return PredictionModel(
      nodeId: json['nodeId']?.toString() ?? json['NodeID']?.toString() ?? "",
      riskScore: d(json['riskScore'] ?? json['risk'] ?? json['risk_score']),
      tgs2620: d(json['tgs2620'] ?? json['TGS2620']),
      tgs2602: d(json['tgs2602'] ?? json['TGS2602']),
      tgs2600: d(json['tgs2600'] ?? json['TGS2600']),
      timestamp: json['timestamp']?.toString() ?? json['Timestamp']?.toString() ?? "",
      status: json['status']?.toString() ?? "",
      modelUsed: json['modelUsed']?.toString() ?? "",
    );
  }
}
