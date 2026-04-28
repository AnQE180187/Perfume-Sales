import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Interceptor that caches GET responses to SharedPreferences for offline support.
class CacheInterceptor extends Interceptor {
  final SharedPreferences prefs;
  
  // Prefix to avoid collisions with other storage keys
  static const _cachePrefix = 'api_cache_';
  
  // Routes we should cache (banners, product lists)
  static const _cacheablePaths = {
    '/banners',
    '/products',
    '/products/personalized',
    '/products/recommended',
  };

  CacheInterceptor(this.prefs);

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Only cache successful GET requests on specific paths
    if (response.requestOptions.method == 'GET' && 
        _shouldCache(response.requestOptions.path)) {
      final key = '$_cachePrefix${response.requestOptions.path}${_queryParamsKey(response.requestOptions.queryParameters)}';
      prefs.setString(key, jsonEncode(response.data));
    }
    handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // If the error is network related, try to serve from cache
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.unknown) {
      
      final key = '$_cachePrefix${err.requestOptions.path}${_queryParamsKey(err.requestOptions.queryParameters)}';
      final cachedData = prefs.getString(key);
      
      if (cachedData != null) {
        try {
          final decodedData = jsonDecode(cachedData);
          return handler.resolve(
            Response(
              requestOptions: err.requestOptions,
              data: decodedData,
              statusCode: 200,
              statusMessage: 'Served from local cache',
            ),
          );
        } catch (_) {
          // If decoding fails, let the error propagate
        }
      }
    }
    handler.next(err);
  }

  bool _shouldCache(String path) {
    // SECURITY & FRESHNESS: Never cache admin or staff-specific return paths
    if (path.contains('/returns/admin') || path.contains('/staff/pos')) {
      return false;
    }
    
    // Check if the path is in our cacheable list (exact or startWith)
    return _cacheablePaths.any((p) => path.startsWith(p));
  }

  String _queryParamsKey(Map<String, dynamic>? params) {
    if (params == null || params.isEmpty) return '';
    // Simple sort for consistent keys
    final sortedKeys = params.keys.toList()..sort();
    final combined = sortedKeys.map((k) => '$k=${params[k]}').join('&');
    return '?$combined';
  }
}
