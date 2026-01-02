/// Report analysis model
class ReportAnalysis {
  final String summary;
  final List<String>? keyFindings;
  final List<String>? abnormalValues;
  final List<String>? recommendations;
  final String? severity;  // 'normal', 'attention', 'urgent'

  ReportAnalysis({
    required this.summary,
    this.keyFindings,
    this.abnormalValues,
    this.recommendations,
    this.severity,
  });

  /// Create from JSON
  factory ReportAnalysis.fromJson(Map<String, dynamic> json) {
    return ReportAnalysis(
      summary: json['summary'] as String,
      keyFindings: json['key_findings'] != null
          ? List<String>.from(json['key_findings'] as List)
          : null,
      abnormalValues: json['abnormal_values'] != null
          ? List<String>.from(json['abnormal_values'] as List)
          : null,
      recommendations: json['recommendations'] != null
          ? List<String>.from(json['recommendations'] as List)
          : null,
      severity: json['severity'] as String?,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'summary': summary,
      if (keyFindings != null) 'key_findings': keyFindings,
      if (abnormalValues != null) 'abnormal_values': abnormalValues,
      if (recommendations != null) 'recommendations': recommendations,
      if (severity != null) 'severity': severity,
    };
  }

  /// Check if report is urgent
  bool get isUrgent => severity?.toLowerCase() == 'urgent';

  /// Check if report needs attention
  bool get needsAttention =>
      severity?.toLowerCase() == 'attention' ||
      severity?.toLowerCase() == 'urgent';

  /// Check if report is normal
  bool get isNormal => severity?.toLowerCase() == 'normal';
}