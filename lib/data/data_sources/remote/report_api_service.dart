import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'api_client.dart';
import '../../models/report/medical_report.dart';
import '../../../core/constants/api_constants.dart';

/// Report API service - Handles all medical report endpoints
class ReportApiService {
  final ApiClient _apiClient;

  ReportApiService(this._apiClient);

  // ══════════════════════════════════════════════════════════════════════════
  // ANALYZE REPORT
  // ══════════════════════════════════════════════════════════════════════════

  /// Upload and analyze medical report (PDF or image)
  /// POST /analyze-report
  /// 
  /// [filePath] - Path to the file (PDF or image)
  /// [consent] - Whether to merge analysis into medical profile
  Future<Map<String, dynamic>> analyzeReport({
    required String filePath,
    bool consent = false,
  }) async {
    try {
      // Create multipart form data
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split('/').last,
        ),
        'consent': consent,
      });

      final response = await _apiClient.post(
        ApiConstants.analyzeReport,
        data: formData,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // REPORT HISTORY
  // ══════════════════════════════════════════════════════════════════════════

  /// Get report history
  /// GET /reports/history
  /// 
  /// [limit] - Maximum number of reports to fetch (default: 50)
  /// [order] - Sort order: 'asc' or 'desc' (default: 'desc')
  Future<List<MedicalReport>> getReportHistory({
    int limit = 50,
    String order = 'desc',
  }) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.reportHistory,
        queryParameters: {
          'limit': limit,
          'order': order,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final items = data['items'] as List;

      return items.map((json) => MedicalReport.fromJson(json)).toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // GET SPECIFIC REPORT
  // ══════════════════════════════════════════════════════════════════════════

  /// Get a specific report by ID
  /// GET /reports/{report_id}
  Future<MedicalReport> getReportById(String reportId) async {
    try {
      final response = await _apiClient.get(
        ApiConstants.getReportById(reportId),
      );

      return MedicalReport.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DOWNLOAD DOCTOR SUMMARY PDF
  // ══════════════════════════════════════════════════════════════════════════

  /// Export doctor summary as PDF
  /// GET /doctor-summary-pdf
  /// 
  /// Returns the PDF file as bytes that can be saved or shared
  Future<List<int>> downloadDoctorSummaryPdf() async {
    try {
      final response = await _apiClient.get(
        ApiConstants.doctorSummaryPdf,
        options: Options(
          responseType: ResponseType.bytes,
        ),
      );

      return response.data as List<int>;
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // HELPER: SAVE PDF TO FILE
  // ══════════════════════════════════════════════════════════════════════════

  /// Helper method to download and save PDF to device
  /// 
  /// Example usage:
  /// ```dart
  /// final filePath = await reportService.downloadAndSavePdf();
  /// print('PDF saved to: $filePath');
  /// ```
  Future<String> downloadAndSavePdf() async {
    try {
      // Get PDF bytes
      final pdfBytes = await downloadDoctorSummaryPdf();

      // Get app directory
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/doctor_summary_${DateTime.now().millisecondsSinceEpoch}.pdf';

      // Write to file
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      return filePath;
    } catch (e) {
      throw Exception('Failed to save PDF: $e');
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // ERROR HANDLING
  // ══════════════════════════════════════════════════════════════════════════

  String _handleError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      String message = 'An error occurred';

      if (data is Map<String, dynamic>) {
        message = data['detail'] ?? data['message'] ?? message;
      } else if (data is String) {
        message = data;
      }

      switch (statusCode) {
        case 400:
          return 'Invalid file or request: $message';
        case 401:
          return 'Unauthorized. Please login again.';
        case 404:
          return 'Report not found';
        case 413:
          return 'File too large. Maximum size is 10MB.';
        case 500:
          return 'Server error. Please try again later.';
        default:
          return message;
      }
    } else if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Connection timeout. Please check your internet connection.';
    } else if (error.type == DioExceptionType.unknown) {
      return 'No internet connection. Please check your network.';
    }

    return 'An unexpected error occurred';
  }
}