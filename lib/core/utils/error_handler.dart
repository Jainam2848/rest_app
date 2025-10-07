import 'dart:io';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../services/api_service.dart';

class ErrorHandler {
  // Parse and format error messages
  static String parseError(dynamic error) {
    if (error is ApiException) {
      return error.message;
    }
    
    if (error is PostgrestException) {
      return _parsePostgrestError(error);
    }
    
    if (error is AuthException) {
      return _parseAuthError(error);
    }
    
    if (error is StorageException) {
      return 'Storage error: ${error.message}';
    }
    
    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }
    
    return 'An unexpected error occurred. Please try again.';
  }

  // Parse Postgrest errors
  static String _parsePostgrestError(PostgrestException error) {
    switch (error.code) {
      case '23505':
        return 'This item already exists.';
      case '23503':
        return 'Cannot delete: item is referenced by other records.';
      case '42501':
        return 'You do not have permission to perform this action.';
      case 'PGRST301':
        return 'Item not found.';
      default:
        return error.message;
    }
  }

  // Parse Auth errors
  static String _parseAuthError(AuthException error) {
    final message = error.message.toLowerCase();
    
    if (message.contains('invalid login credentials')) {
      return 'Invalid email or password.';
    }
    
    if (message.contains('email not confirmed')) {
      return 'Please verify your email address.';
    }
    
    if (message.contains('user already registered')) {
      return 'An account with this email already exists.';
    }
    
    if (message.contains('invalid email')) {
      return 'Please enter a valid email address.';
    }
    
    if (message.contains('password')) {
      return 'Password must be at least 6 characters.';
    }
    
    return error.message;
  }

  // Show error snackbar
  static void showErrorSnackbar(BuildContext context, dynamic error) {
    final message = parseError(error);
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Show success snackbar
  static void showSuccessSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // Show info snackbar
  static void showInfoSnackbar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
