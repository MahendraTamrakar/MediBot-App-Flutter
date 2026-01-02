import 'package:medibot/data/models/report/report_anaysis.dart';

/// Medical report model
class MedicalReport {
  final String id;
  final String originalFilename;
  final String reportType;  // 'pdf' or 'image'
  final DateTime createdAt;
  final String? extractedText;
  final ReportAnalysis? analysis;

  MedicalReport({
    required this.id,
    required this.originalFilename,
    required this.reportType,
    required this.createdAt,
    this.extractedText,
    this.analysis,
  });

  /// Create from JSON
  factory MedicalReport.fromJson(Map<String, dynamic> json) {
    return MedicalReport(
      id: json['id'] as String,
      originalFilename: json['original_filename'] as String,
      reportType: json['report_type'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      extractedText: json['extracted_text'] as String?,
      analysis: json['analysis'] != null
          ? ReportAnalysis.fromJson(json['analysis'] as Map<String, dynamic>)
          : null,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'original_filename': originalFilename,
      'report_type': reportType,
      'created_at': createdAt.toIso8601String(),
      if (extractedText != null) 'extracted_text': extractedText,
      if (analysis != null) 'analysis': analysis!.toJson(),
    };
  }

  /// Check if report is image
  bool get isImage => reportType == 'image';

  /// Check if report is PDF
  bool get isPdf => reportType == 'pdf';
}