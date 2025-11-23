// lib/models/report_model.dart

class ReportModel {
  final String type;
  final String createdAt;
  final Map<String, dynamic> summary;
  final String? pdfUrl;
  final String? csvUrl;

  ReportModel({
    required this.type,
    required this.createdAt,
    required this.summary,
    this.pdfUrl,
    this.csvUrl,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      type: json['type']?.toString() ?? "Report",
      createdAt: json['createdAt']?.toString() ?? "",
      summary: json['summary'] ?? {},
      pdfUrl: json['pdfUrl']?.toString(),
      csvUrl: json['csvUrl']?.toString(),
    );
  }
}
