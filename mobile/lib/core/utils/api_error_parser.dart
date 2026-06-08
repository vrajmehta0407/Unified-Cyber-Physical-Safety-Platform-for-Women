import 'package:dio/dio.dart';

String parseApiError(DioException e) {
  final data = e.response?.data;
  if (data is Map && data['detail'] != null) {
    final detail = data['detail'];
    if (detail is String) return detail;
    if (detail is List && detail.isNotEmpty) return detail.first.toString();
  }
  return 'Something went wrong. Please try again.';
}
