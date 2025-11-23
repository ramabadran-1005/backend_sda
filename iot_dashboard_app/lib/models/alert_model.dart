// lib/models/alert_model.dart

class AlertModel {
  final String nodeId;
  final String sensorType;
  final String message;
  final String timestamp;

  AlertModel({
    required this.nodeId,
    required this.sensorType,
    required this.message,
    required this.timestamp,
  });

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      nodeId: json['nodeId']?.toString() ?? "",
      sensorType: json['sensorType']?.toString() ?? "",
      message: json['message']?.toString() ?? "",
      timestamp: json['timestamp']?.toString() ??
          json['createdAt']?.toString() ??
          "",
    );
  }
}
