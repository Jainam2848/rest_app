import 'package:supabase_flutter/supabase_flutter.dart';

class ApiService {
  final SupabaseClient _supabase = Supabase.instance.client;

  SupabaseClient get client => _supabase;

  // Generic query method with error handling
  Future<List<T>> query<T>({
    required String table,
    required T Function(Map<String, dynamic>) fromJson,
    String? orderBy,
    bool ascending = true,
    int? limit,
    Map<String, dynamic>? filters,
  }) async {
    try {
      dynamic query = _supabase.from(table).select();

      // Apply filters
      if (filters != null) {
        filters.forEach((key, value) {
          if (value != null) {
            query = query.eq(key, value);
          }
        });
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return (response as List).map((json) => fromJson(json as Map<String, dynamic>)).toList();
    } on PostgrestException catch (e) {
      throw ApiException('Database error: ${e.message}', code: e.code);
    } catch (e) {
      throw ApiException('Failed to fetch data: $e');
    }
  }

  // Generic get by ID method
  Future<T?> getById<T>({
    required String table,
    required String id,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _supabase
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();

      if (response == null) return null;
      return fromJson(response);
    } on PostgrestException catch (e) {
      throw ApiException('Database error: ${e.message}', code: e.code);
    } catch (e) {
      throw ApiException('Failed to fetch item: $e');
    }
  }

  // Generic insert method
  Future<T> insert<T>({
    required String table,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _supabase
          .from(table)
          .insert(data)
          .select()
          .single();

      return fromJson(response);
    } on PostgrestException catch (e) {
      throw ApiException('Database error: ${e.message}', code: e.code);
    } catch (e) {
      throw ApiException('Failed to insert data: $e');
    }
  }

  // Generic update method
  Future<T> update<T>({
    required String table,
    required String id,
    required Map<String, dynamic> data,
    required T Function(Map<String, dynamic>) fromJson,
  }) async {
    try {
      final response = await _supabase
          .from(table)
          .update(data)
          .eq('id', id)
          .select()
          .single();

      return fromJson(response);
    } on PostgrestException catch (e) {
      throw ApiException('Database error: ${e.message}', code: e.code);
    } catch (e) {
      throw ApiException('Failed to update data: $e');
    }
  }

  // Generic delete method
  Future<void> delete({
    required String table,
    required String id,
  }) async {
    try {
      await _supabase
          .from(table)
          .delete()
          .eq('id', id);
    } on PostgrestException catch (e) {
      throw ApiException('Database error: ${e.message}', code: e.code);
    } catch (e) {
      throw ApiException('Failed to delete item: $e');
    }
  }

  // Upload file to storage
  Future<String> uploadFile({
    required String bucket,
    required String path,
    required dynamic file,
  }) async {
    try {
      await _supabase.storage.from(bucket).upload(path, file);
      
      final url = _supabase.storage.from(bucket).getPublicUrl(path);
      return url;
    } on StorageException catch (e) {
      throw ApiException('Storage error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to upload file: $e');
    }
  }

  // Delete file from storage
  Future<void> deleteFile({
    required String bucket,
    required String path,
  }) async {
    try {
      await _supabase.storage.from(bucket).remove([path]);
    } on StorageException catch (e) {
      throw ApiException('Storage error: ${e.message}');
    } catch (e) {
      throw ApiException('Failed to delete file: $e');
    }
  }
}

// Custom exception class
class ApiException implements Exception {
  final String message;
  final String? code;

  ApiException(this.message, {this.code});

  @override
  String toString() => message;
}
