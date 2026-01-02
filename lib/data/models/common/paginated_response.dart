/// Generic paginated response model
/// 
/// Use this for any API endpoint that returns paginated data.
/// 
/// Example usage:
/// ```dart
/// final response = PaginatedResponse<ChatSession>.fromJson(
///   jsonData,
///   (json) => ChatSession.fromJson(json),
/// );
/// 
/// print('Page ${response.page} of ${response.totalPages}');
/// for (final session in response.data) {
///   print(session.title);
/// }
/// ```
class PaginatedResponse<T> {
  /// The list of items for this page
  final List<T> data;

  /// Current page number (1-indexed)
  final int page;

  /// Number of items per page
  final int pageSize;

  /// Total number of items across all pages
  final int totalItems;

  /// Total number of pages
  final int totalPages;

  /// Whether there are more pages after this one
  final bool hasNext;

  /// Whether there are pages before this one
  final bool hasPrevious;

  PaginatedResponse({
    required this.data,
    required this.page,
    required this.pageSize,
    required this.totalItems,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrevious,
  });

  /// Create from JSON with a factory function for items
  /// 
  /// The `fromJsonT` parameter is a function that converts
  /// a JSON object to type T.
  /// 
  /// Example:
  /// ```dart
  /// PaginatedResponse.fromJson(
  ///   jsonData,
  ///   (json) => ChatSession.fromJson(json),
  /// )
  /// ```
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    return PaginatedResponse<T>(
      data: (json['data'] as List<dynamic>)
          .map((item) => fromJsonT(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      pageSize: json['page_size'] as int,
      totalItems: json['total_items'] as int,
      totalPages: json['total_pages'] as int,
      hasNext: json['has_next'] as bool,
      hasPrevious: json['has_previous'] as bool,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) toJsonT) {
    return {
      'data': data.map((item) => toJsonT(item)).toList(),
      'page': page,
      'page_size': pageSize,
      'total_items': totalItems,
      'total_pages': totalPages,
      'has_next': hasNext,
      'has_previous': hasPrevious,
    };
  }

  /// Check if this is the first page
  bool get isFirstPage => page == 1;

  /// Check if this is the last page
  bool get isLastPage => !hasNext;

  /// Get next page number (or null if no next page)
  int? get nextPage => hasNext ? page + 1 : null;

  /// Get previous page number (or null if no previous page)
  int? get previousPage => hasPrevious ? page - 1 : null;

  /// Check if data is empty
  bool get isEmpty => data.isEmpty;

  /// Check if data is not empty
  bool get isNotEmpty => data.isNotEmpty;

  /// Get number of items in this page
  int get itemCount => data.length;

  /// Create a copy with modified fields
  PaginatedResponse<T> copyWith({
    List<T>? data,
    int? page,
    int? pageSize,
    int? totalItems,
    int? totalPages,
    bool? hasNext,
    bool? hasPrevious,
  }) {
    return PaginatedResponse<T>(
      data: data ?? this.data,
      page: page ?? this.page,
      pageSize: pageSize ?? this.pageSize,
      totalItems: totalItems ?? this.totalItems,
      totalPages: totalPages ?? this.totalPages,
      hasNext: hasNext ?? this.hasNext,
      hasPrevious: hasPrevious ?? this.hasPrevious,
    );
  }

  /// Create an empty paginated response
  factory PaginatedResponse.empty() {
    return PaginatedResponse<T>(
      data: [],
      page: 1,
      pageSize: 0,
      totalItems: 0,
      totalPages: 0,
      hasNext: false,
      hasPrevious: false,
    );
  }

  @override
  String toString() {
    return 'PaginatedResponse(page: $page/$totalPages, items: ${data.length}/$totalItems)';
  }
}