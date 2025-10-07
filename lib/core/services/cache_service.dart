import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String _cachePrefix = 'cache_';
  static const Duration _defaultExpiry = Duration(hours: 24);

  // Save data to cache
  Future<void> save({
    required String key,
    required dynamic data,
    Duration? expiry,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cachePrefix + key;
      
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'expiry': (expiry ?? _defaultExpiry).inMilliseconds,
      };
      
      await prefs.setString(cacheKey, jsonEncode(cacheData));
    } catch (e) {
      // Fail silently for cache operations
    }
  }

  // Get data from cache
  Future<T?> get<T>({
    required String key,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cachePrefix + key;
      
      final cacheString = prefs.getString(cacheKey);
      if (cacheString == null) return null;
      
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      
      // Check if cache is expired
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > expiry) {
        await clear(key);
        return null;
      }
      
      return fromJson(cacheData['data']);
    } catch (e) {
      return null;
    }
  }

  // Get list data from cache
  Future<List<T>?> getList<T>({
    required String key,
    required T Function(dynamic) fromJson,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cachePrefix + key;
      
      final cacheString = prefs.getString(cacheKey);
      if (cacheString == null) return null;
      
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      
      // Check if cache is expired
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      if (cacheAge > expiry) {
        await clear(key);
        return null;
      }
      
      final dataList = cacheData['data'] as List;
      return dataList.map((item) => fromJson(item)).toList();
    } catch (e) {
      return null;
    }
  }

  // Clear specific cache
  Future<void> clear(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cachePrefix + key;
      await prefs.remove(cacheKey);
    } catch (e) {
      // Fail silently
    }
  }

  // Clear all cache
  Future<void> clearAll() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      
      for (final key in keys) {
        if (key.startsWith(_cachePrefix)) {
          await prefs.remove(key);
        }
      }
    } catch (e) {
      // Fail silently
    }
  }

  // Check if cache exists and is valid
  Future<bool> hasValid(String key) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheKey = _cachePrefix + key;
      
      final cacheString = prefs.getString(cacheKey);
      if (cacheString == null) return false;
      
      final cacheData = jsonDecode(cacheString) as Map<String, dynamic>;
      final timestamp = cacheData['timestamp'] as int;
      final expiry = cacheData['expiry'] as int;
      
      final cacheAge = DateTime.now().millisecondsSinceEpoch - timestamp;
      return cacheAge <= expiry;
    } catch (e) {
      return false;
    }
  }
}
