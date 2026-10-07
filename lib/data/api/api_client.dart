import 'package:dio/dio.dart';
import '../../core/constants/app_constants.dart';

/// HTTP Client cho toàn bộ ứng dụng
/// Tương đương: RetrofitClient.java
///
/// Android gốc: Retrofit2 + OkHttp
/// Flutter: Dio
class ApiClient {
  ApiClient._();

  static Dio? _dio;
  static String? _currentBaseUrl;

  static Dio get instance {
    if (_dio == null || _currentBaseUrl != AppConstants.baseUrl) {
      _currentBaseUrl = AppConstants.baseUrl;
      _dio = _createDio();
    }
    return _dio!;
  }

  static Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        connectTimeout:
            const Duration(seconds: AppConstants.connectTimeoutSeconds),
        receiveTimeout:
            const Duration(seconds: AppConstants.receiveTimeoutSeconds),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    // Log interceptor (tương đương OkHttp LoggingInterceptor trong Android)
    dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: false,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
      ),
    );

    return dio;
  }

  /// Reset instance (dùng khi đổi baseUrl)
  static void reset() {
    _dio = null;
  }
}
