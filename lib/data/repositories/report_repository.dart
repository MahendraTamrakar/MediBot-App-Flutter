import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../data_sources/remote/report_api_service.dart';
import '../models/report/medical_report.dart';

/// Report repository - Business logic for medical report operations
/// 
/// Coordinates:
/// - Report API service (remote data)
/// - File handling and validation
/// - Local caching of reports
class ReportRepository {
  final ReportApiService _reportApiService;

  ReportRepository({
    required ReportApiService reportApiService,
  }) : _reportApiService = reportApiService;

  // ══════════════════════════════════════════════════════════════════════════
  // UPLOAD AND ANALYZE
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload and analyze a medical report
  /// 
  /// [filePath] - Path to the report file (PDF or image)
  /// [consent] - Whether to merge analysis into medical profile
  /// 
  /// Returns the analysis result
  Future<Map<String, dynamic>> uploadReport({
    required String filePath,
    bool consent = false,
  }) async {
    try {
      // Validate file
      _validateFile(filePath);

      // Upload and analyze
      final result = await _reportApiService.analyzeReport(
        filePath: filePath,
        consent: consent,
      );

      return result;
    } catch (e) {
      throw Exception('Failed to upload report: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REPORT HISTORY
  // ══════════════════════════════════════════════════════════════════════════

  /// Get report history
  /// 
  /// [limit] - Maximum number of reports to fetch
  /// [order] - Sort order: 'asc' or 'desc'
  /// 
  /// Returns list of medical reports
  Future<List<MedicalReport>> getReportHistory({
    int limit = 50,
    String order = 'desc',
  }) async {
    try {
      final reports = await _reportApiService.getReportHistory(
        limit: limit,
        order: order,
      );

      return reports;
    } catch (e) {
      throw Exception('Failed to get report history: $e');
    }
  }

  /// Get most recent report
  /// 
  /// Returns the most recently uploaded report or null if none
  Future<MedicalReport?> getMostRecentReport() async {
    try {
      final reports = await getReportHistory(limit: 1, order: 'desc');

      if (reports.isEmpty) return null;

      return reports.first;
    } catch (e) {
      return null;
    }
  }

  /// Get a specific report by ID
  /// 
  /// [reportId] - The report ID to fetch
  Future<MedicalReport> getReportById(String reportId) async {
    try {
      final report = await _reportApiService.getReportById(reportId);

      return report;
    } catch (e) {
      throw Exception('Failed to get report: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DOCTOR SUMMARY
  // ══════════════════════════════════════════════════════════════════════════

  /// Download doctor summary PDF
  /// 
  /// Returns the path to the saved PDF file
  Future<String> downloadDoctorSummary() async {
    try {
      final pdfPath = await _reportApiService.downloadAndSavePdf();

      return pdfPath;
    } catch (e) {
      throw Exception('Failed to download doctor summary: $e');
    }
  }

  /// Share doctor summary PDF
  /// 
  /// Downloads the PDF and returns the file path for sharing
  Future<File> getDoctorSummaryFile() async {
    try {
      final pdfBytes = await _reportApiService.downloadDoctorSummaryPdf();

      // Save to temporary directory
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/doctor_summary_${DateTime.now().millisecondsSinceEpoch}.pdf';

      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      return file;
    } catch (e) {
      throw Exception('Failed to get doctor summary file: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // VALIDATION
  // ══════════════════════════════════════════════════════════════════════════

  void _validateFile(String filePath) {
    final file = File(filePath);

    // Check if file exists
    if (!file.existsSync()) {
      throw Exception('File does not exist');
    }

    // Check file size (max 10MB)
    final fileSize = file.lengthSync();
    const maxSize = 10 * 1024 * 1024; // 10MB

    if (fileSize > maxSize) {
      throw Exception('File too large. Maximum size is 10MB');
    }

    // Check file extension
    final extension = filePath.split('.').last.toLowerCase();
    final allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png', 'gif'];

    if (!allowedExtensions.contains(extension)) {
      throw Exception('Invalid file type. Allowed: PDF, JPG, PNG, GIF');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get report statistics
  /// 
  /// Returns total reports and reports by type
  Future<Map<String, dynamic>> getReportStatistics() async {
    try {
      final reports = await getReportHistory();

      int pdfCount = 0;
      int imageCount = 0;

      for (final report in reports) {
        if (report.isPdf) {
          pdfCount++;
        } else {
          imageCount++;
        }
      }

      return {
        'total_reports': reports.length,
        'pdf_reports': pdfCount,
        'image_reports': imageCount,
      };
    } catch (e) {
      throw Exception('Failed to get report statistics: $e');
    }
  }

  /// Check if user has any reports
  Future<bool> hasReports() async {
    try {
      final reports = await getReportHistory(limit: 1);
      return reports.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get urgent reports (reports with urgent analysis)
  /// 
  /// Returns reports that need immediate attention
  Future<List<MedicalReport>> getUrgentReports() async {
    try {
      final reports = await getReportHistory();

      final urgentReports = reports.where((report) {
        return report.analysis?.isUrgent ?? false;
      }).toList();

      return urgentReports;
    } catch (e) {
      throw Exception('Failed to get urgent reports: $e');
    }
  }
}